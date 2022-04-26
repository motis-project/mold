#include "mold.h"

namespace mold::macho {

// Returns [hi:lo] bits of val.
static u64 bits(u64 val, u64 hi, u64 lo) {
  return (val >> lo) & (((u64)1 << (hi - lo + 1)) - 1);
}

static u64 page(u64 val) {
  return val & 0xffff'ffff'ffff'f000;
}

static u64 encode_page(u64 val) {
  return (bits(val, 13, 12) << 29) | (bits(val, 32, 14) << 5);
}

template <>
void StubsSection<ARM64>::copy_buf(Context<ARM64> &ctx) {
  u32 *buf = (u32 *)(ctx.buf + this->hdr.offset);

  for (i64 i = 0; i < syms.size(); i++) {
    static const u32 insn[] = {
      0x90000010, // adrp x16, $ptr@PAGE
      0xf9400210, // ldr  x16, [x16, $ptr@PAGEOFF]
      0xd61f0200, // br   x16
    };

    static_assert(sizeof(insn) == ARM64::stub_size);

    u64 la_addr = ctx.lazy_symbol_ptr.hdr.addr + ARM64::word_size * i;
    u64 this_addr = this->hdr.addr + ARM64::stub_size * i;

    memcpy(buf, insn, sizeof(insn));
    buf[0] |= encode_page(page(la_addr) - page(this_addr));
    buf[1] |= bits(la_addr, 11, 3) << 10;
    buf += 3;
  }
}

template <>
void StubHelperSection<ARM64>::copy_buf(Context<ARM64> &ctx) {
  u32 *start = (u32 *)(ctx.buf + this->hdr.offset);
  u32 *buf = start;

  static const u32 insn0[] = {
    0x90000011, // adrp x17, $__dyld_private@PAGE
    0x91000231, // add  x17, x17, $__dyld_private@PAGEOFF
    0xa9bf47f0, // stp	x16, x17, [sp, #-16]!
    0x90000010, // adrp x16, $dyld_stub_binder@PAGE
    0xf9400210, // ldr  x16, [x16, $dyld_stub_binder@PAGEOFF]
    0xd61f0200, // br   x16
  };

  static_assert(sizeof(insn0) == ARM64::stub_helper_hdr_size);
  memcpy(buf, insn0, sizeof(insn0));

  u64 dyld_private = get_symbol(ctx, "__dyld_private")->get_addr(ctx);
  buf[0] |= encode_page(page(dyld_private) - page(this->hdr.addr));
  buf[1] |= bits(dyld_private, 11, 0) << 10;

  u64 stub_binder = get_symbol(ctx, "dyld_stub_binder")->get_addr(ctx);
  buf[3] |= encode_page(page(stub_binder) - page(this->hdr.addr - 12));
  buf[4] |= bits(stub_binder, 11, 0) << 10;

  buf += 6;

  for (i64 i = 0; i < ctx.stubs.syms.size(); i++) {
    static const u32 insn[] = {
      0x18000050, // ldr  w16, addr
      0x14000000, // b    stubHelperHeader
      0x00000000, // addr: .long <idx>
    };

    static_assert(sizeof(insn) == ARM64::stub_helper_size);

    memcpy(buf, insn, sizeof(insn));
    buf[1] |= bits((start - buf - 1) * 4, 27, 2);
    buf[2] = ctx.stubs.bind_offsets[i];
    buf += 3;
  }
}

static i64 read_addend(u8 *buf, const MachRel &r) {
  if (r.p2size == 2)
    return *(i32 *)(buf + r.offset);
  if (r.p2size == 3)
    return *(i64 *)(buf + r.offset);
  unreachable();
}

static Relocation<ARM64>
read_reloc(Context<ARM64> &ctx, ObjectFile<ARM64> &file,
           const MachSection &hdr, MachRel *rels, i64 &idx) {
  i64 addend = 0;

  switch (rels[idx].type) {
  case ARM64_RELOC_UNSIGNED:
  case ARM64_RELOC_SUBTRACTOR:
    addend = read_addend((u8 *)file.mf->data + hdr.offset, rels[idx]);
    break;
  case ARM64_RELOC_ADDEND:
    addend = rels[idx++].offset;
    break;
  }

  MachRel &r = rels[idx];
  Relocation<ARM64> rel{r.offset, (u8)r.type, (u8)r.p2size, (bool)r.is_pcrel};

  if (r.is_extern) {
    rel.sym = file.syms[r.idx];
    rel.addend = addend;
    return rel;
  }

  u32 addr;
  if (r.is_pcrel)
    addr = hdr.addr + r.offset + addend;
  else
    addr = addend;

  Subsection<ARM64> *target = file.find_subsection(ctx, addr);
  if (!target)
    Fatal(ctx) << file << ": bad relocation: " << r.offset;

  rel.subsec = target;
  rel.addend = addr - target->input_addr;
  return rel;
}

template <>
std::vector<Relocation<ARM64>>
read_relocations(Context<ARM64> &ctx, ObjectFile<ARM64> &file,
                 const MachSection &hdr) {
  std::vector<Relocation<ARM64>> vec;

  MachRel *rels = (MachRel *)(file.mf->data + hdr.reloff);
  for (i64 i = 0; i < hdr.nreloc; i++)
    vec.push_back(read_reloc(ctx, file, hdr, rels, i));
  return vec;
}

template <>
void Subsection<ARM64>::scan_relocations(Context<ARM64> &ctx) {
  for (Relocation<ARM64> &r : get_rels()) {
    Symbol<ARM64> *sym = r.sym;
    if (!sym)
      continue;

    switch (r.type) {
    case ARM64_RELOC_GOT_LOAD_PAGE21:
    case ARM64_RELOC_GOT_LOAD_PAGEOFF12:
    case ARM64_RELOC_POINTER_TO_GOT:
      sym->flags |= NEEDS_GOT;
      break;
    case ARM64_RELOC_TLVP_LOAD_PAGE21:
    case ARM64_RELOC_TLVP_LOAD_PAGEOFF12:
      sym->flags |= NEEDS_THREAD_PTR;
      break;
    }

    if (sym->file && sym->file->is_dylib()) {
      sym->flags |= NEEDS_STUB;
      ((DylibFile<ARM64> *)sym->file)->is_needed = true;
    }
  }
}

template <>
void Subsection<ARM64>::apply_reloc(Context<ARM64> &ctx, u8 *buf) {
  std::span<Relocation<ARM64>> rels = get_rels();

  for (i64 i = 0; i < rels.size(); i++) {
    Relocation<ARM64> &r = rels[i];

    if (r.sym && !r.sym->file) {
      Error(ctx) << "undefined symbol: " << isec.file << ": " << *r.sym;
      continue;
    }

    u64 val = 0;

    switch (r.type) {
    case ARM64_RELOC_UNSIGNED:
    case ARM64_RELOC_BRANCH26:
    case ARM64_RELOC_PAGE21:
    case ARM64_RELOC_PAGEOFF12:
      val = r.sym ? r.sym->get_addr(ctx) : r.subsec->get_addr(ctx);
      break;
    case ARM64_RELOC_SUBTRACTOR: {
      Relocation<ARM64> s = rels[++i];
      assert(s.type == ARM64_RELOC_UNSIGNED);
      u64 val1 = r.sym ? r.sym->get_addr(ctx) : r.subsec->get_addr(ctx);
      u64 val2 = s.sym ? s.sym->get_addr(ctx) : s.subsec->get_addr(ctx);
      val = val2 - val1;
      break;
    }
    case ARM64_RELOC_GOT_LOAD_PAGE21:
    case ARM64_RELOC_GOT_LOAD_PAGEOFF12:
    case ARM64_RELOC_POINTER_TO_GOT:
      val = r.sym->get_got_addr(ctx);
      break;
    case ARM64_RELOC_TLVP_LOAD_PAGE21:
    case ARM64_RELOC_TLVP_LOAD_PAGEOFF12:
      val = r.sym->get_tlv_addr(ctx);
      break;
    default:
      Fatal(ctx) << isec << ": unknown reloc: " << (int)r.type;
    }

    val += r.addend;

    switch (r.type) {
    case ARM64_RELOC_UNSIGNED:
    case ARM64_RELOC_SUBTRACTOR:
    case ARM64_RELOC_POINTER_TO_GOT:
      if (r.is_pcrel)
        val -= get_addr(ctx) + r.offset;

      if (r.p2size == 2)
        *(i32 *)(buf + r.offset) = val;
      else if (r.p2size == 3)
        *(i64 *)(buf + r.offset) = val;
      else
        unreachable();
      break;
    case ARM64_RELOC_BRANCH26:
      if (r.is_pcrel)
        val -= get_addr(ctx) + r.offset;
      *(u32 *)(buf + r.offset) |= bits(val, 27, 2);
      break;
    case ARM64_RELOC_PAGE21:
    case ARM64_RELOC_GOT_LOAD_PAGE21:
    case ARM64_RELOC_TLVP_LOAD_PAGE21:
      assert(r.is_pcrel);
      *(u32 *)(buf + r.offset) |=
        encode_page(page(val) - page(get_addr(ctx) + r.offset));
      break;
    case ARM64_RELOC_PAGEOFF12:
    case ARM64_RELOC_GOT_LOAD_PAGEOFF12:
    case ARM64_RELOC_TLVP_LOAD_PAGEOFF12: {
      if (r.is_pcrel)
        val -= get_addr(ctx) + r.offset;

      u32 insn = *(u32 *)(buf + r.offset);
      i64 scale = 0;
      if ((insn & 0x3b000000) == 0x39000000)
        scale = insn >> 30;
      *(u32 *)(buf + r.offset) |= bits(val, 11, scale) << 10;
      break;
    }
    default:
      Fatal(ctx) << isec << ": unknown reloc: " << (int)r.type;
    }
  }
}

} // namespace mold::macho
