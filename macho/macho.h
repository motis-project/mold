#pragma once

#include "../big-endian.h"

#include <cassert>
#include <cstdint>
#include <cstring>
#include <string_view>

namespace mold::macho {

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;

typedef int8_t i8;
typedef int16_t i16;
typedef int32_t i32;
typedef int64_t i64;

static constexpr u32 FAT_MAGIC = 0xcafebabe;

static constexpr u32 MH_OBJECT = 0x1;
static constexpr u32 MH_EXECUTE = 0x2;
static constexpr u32 MH_FVMLIB = 0x3;
static constexpr u32 MH_CORE = 0x4;
static constexpr u32 MH_PRELOAD = 0x5;
static constexpr u32 MH_DYLIB = 0x6;
static constexpr u32 MH_DYLINKER = 0x7;
static constexpr u32 MH_BUNDLE = 0x8;
static constexpr u32 MH_DYLIB_STUB = 0x9;
static constexpr u32 MH_DSYM = 0xa;
static constexpr u32 MH_KEXT_BUNDLE = 0xb;

static constexpr u32 MH_NOUNDEFS = 0x1;
static constexpr u32 MH_INCRLINK = 0x2;
static constexpr u32 MH_DYLDLINK = 0x4;
static constexpr u32 MH_BINDATLOAD = 0x8;
static constexpr u32 MH_PREBOUND = 0x10;
static constexpr u32 MH_SPLIT_SEGS = 0x20;
static constexpr u32 MH_LAZY_INIT = 0x40;
static constexpr u32 MH_TWOLEVEL = 0x80;
static constexpr u32 MH_FORCE_FLAT = 0x100;
static constexpr u32 MH_NOMULTIDEFS = 0x200;
static constexpr u32 MH_NOFIXPREBINDING = 0x400;
static constexpr u32 MH_PREBINDABLE = 0x800;
static constexpr u32 MH_ALLMODSBOUND = 0x1000;
static constexpr u32 MH_SUBSECTIONS_VIA_SYMBOLS = 0x2000;
static constexpr u32 MH_CANONICAL = 0x4000;
static constexpr u32 MH_WEAK_DEFINES = 0x8000;
static constexpr u32 MH_BINDS_TO_WEAK = 0x10000;
static constexpr u32 MH_ALLOW_STACK_EXECUTION = 0x20000;
static constexpr u32 MH_ROOT_SAFE = 0x40000;
static constexpr u32 MH_SETUID_SAFE = 0x80000;
static constexpr u32 MH_NO_REEXPORTED_DYLIBS = 0x100000;
static constexpr u32 MH_PIE = 0x200000;
static constexpr u32 MH_DEAD_STRIPPABLE_DYLIB = 0x400000;
static constexpr u32 MH_HAS_TLV_DESCRIPTORS = 0x800000;
static constexpr u32 MH_NO_HEAP_EXECUTION = 0x1000000;
static constexpr u32 MH_APP_EXTENSION_SAFE = 0x02000000;
static constexpr u32 MH_NLIST_OUTOFSYNC_WITH_DYLDINFO = 0x04000000;
static constexpr u32 MH_SIM_SUPPORT = 0x08000000;

static constexpr u32 VM_PROT_READ = 0x1;
static constexpr u32 VM_PROT_WRITE = 0x2;
static constexpr u32 VM_PROT_EXECUTE = 0x4;
static constexpr u32 VM_PROT_NO_CHANGE = 0x8;
static constexpr u32 VM_PROT_COPY = 0x10;
static constexpr u32 VM_PROT_WANTS_COPY = 0x10;

static constexpr u32 LC_REQ_DYLD = 0x80000000;

static constexpr u32 LC_SEGMENT = 0x1;
static constexpr u32 LC_SYMTAB = 0x2;
static constexpr u32 LC_SYMSEG = 0x3;
static constexpr u32 LC_THREAD = 0x4;
static constexpr u32 LC_UNIXTHREAD = 0x5;
static constexpr u32 LC_LOADFVMLIB = 0x6;
static constexpr u32 LC_IDFVMLIB = 0x7;
static constexpr u32 LC_IDENT = 0x8;
static constexpr u32 LC_FVMFILE = 0x9;
static constexpr u32 LC_PREPAGE = 0xa;
static constexpr u32 LC_DYSYMTAB = 0xb;
static constexpr u32 LC_LOAD_DYLIB = 0xc;
static constexpr u32 LC_ID_DYLIB = 0xd;
static constexpr u32 LC_LOAD_DYLINKER = 0xe;
static constexpr u32 LC_ID_DYLINKER = 0xf;
static constexpr u32 LC_PREBOUND_DYLIB = 0x10;
static constexpr u32 LC_ROUTINES = 0x11;
static constexpr u32 LC_SUB_FRAMEWORK = 0x12;
static constexpr u32 LC_SUB_UMBRELLA = 0x13;
static constexpr u32 LC_SUB_CLIENT = 0x14;
static constexpr u32 LC_SUB_LIBRARY = 0x15;
static constexpr u32 LC_TWOLEVEL_HINTS = 0x16;
static constexpr u32 LC_PREBIND_CKSUM = 0x17;
static constexpr u32 LC_LOAD_WEAK_DYLIB = (0x18 | LC_REQ_DYLD);
static constexpr u32 LC_SEGMENT_64 = 0x19;
static constexpr u32 LC_ROUTINES_64 = 0x1a;
static constexpr u32 LC_UUID = 0x1b;
static constexpr u32 LC_RPATH = (0x1c | LC_REQ_DYLD);
static constexpr u32 LC_CODE_SIGNATURE = 0x1d;
static constexpr u32 LC_SEGMENT_SPLIT_INFO = 0x1e;
static constexpr u32 LC_REEXPORT_DYLIB = (0x1f | LC_REQ_DYLD);
static constexpr u32 LC_LAZY_LOAD_DYLIB = 0x20;
static constexpr u32 LC_ENCRYPTION_INFO = 0x21;
static constexpr u32 LC_DYLD_INFO = 0x22;
static constexpr u32 LC_DYLD_INFO_ONLY = (0x22 | LC_REQ_DYLD);
static constexpr u32 LC_LOAD_UPWARD_DYLIB = (0x23 | LC_REQ_DYLD);
static constexpr u32 LC_VERSION_MIN_MACOSX = 0x24;
static constexpr u32 LC_VERSION_MIN_IPHONEOS = 0x25;
static constexpr u32 LC_FUNCTION_STARTS = 0x26;
static constexpr u32 LC_DYLD_ENVIRONMENT = 0x27;
static constexpr u32 LC_MAIN = (0x28 | LC_REQ_DYLD);
static constexpr u32 LC_DATA_IN_CODE = 0x29;
static constexpr u32 LC_SOURCE_VERSION = 0x2A;
static constexpr u32 LC_DYLIB_CODE_SIGN_DRS = 0x2B;
static constexpr u32 LC_ENCRYPTION_INFO_64 = 0x2C;
static constexpr u32 LC_LINKER_OPTION = 0x2D;
static constexpr u32 LC_LINKER_OPTIMIZATION_HINT = 0x2E;
static constexpr u32 LC_VERSION_MIN_TVOS = 0x2F;
static constexpr u32 LC_VERSION_MIN_WATCHOS = 0x30;
static constexpr u32 LC_NOTE = 0x31;
static constexpr u32 LC_BUILD_VERSION = 0x32;
static constexpr u32 LC_DYLD_EXPORTS_TRIE = (0x33 | LC_REQ_DYLD);
static constexpr u32 LC_DYLD_CHAINED_FIXUPS = (0x34 | LC_REQ_DYLD);

static constexpr u32 SG_HIGHVM = 0x1;
static constexpr u32 SG_FVMLIB = 0x2;
static constexpr u32 SG_NORELOC = 0x4;
static constexpr u32 SG_PROTECTED_VERSION_1 = 0x8;
static constexpr u32 SG_READ_ONLY = 0x10;

static constexpr u32 S_REGULAR = 0x0;
static constexpr u32 S_ZEROFILL = 0x1;
static constexpr u32 S_CSTRING_LITERALS = 0x2;
static constexpr u32 S_4BYTE_LITERALS = 0x3;
static constexpr u32 S_8BYTE_LITERALS = 0x4;
static constexpr u32 S_LITERAL_POINTERS = 0x5;
static constexpr u32 S_NON_LAZY_SYMBOL_POINTERS = 0x6;
static constexpr u32 S_LAZY_SYMBOL_POINTERS = 0x7;
static constexpr u32 S_SYMBOL_STUBS = 0x8;
static constexpr u32 S_MOD_INIT_FUNC_POINTERS = 0x9;
static constexpr u32 S_MOD_TERM_FUNC_POINTERS = 0xa;
static constexpr u32 S_COALESCED = 0xb;
static constexpr u32 S_GB_ZEROFILL = 0xc;
static constexpr u32 S_INTERPOSING = 0xd;
static constexpr u32 S_16BYTE_LITERALS = 0xe;
static constexpr u32 S_DTRACE_DOF = 0xf;
static constexpr u32 S_LAZY_DYLIB_SYMBOL_POINTERS = 0x10;
static constexpr u32 S_THREAD_LOCAL_REGULAR = 0x11;
static constexpr u32 S_THREAD_LOCAL_ZEROFILL = 0x12;
static constexpr u32 S_THREAD_LOCAL_VARIABLES = 0x13;
static constexpr u32 S_THREAD_LOCAL_VARIABLE_POINTERS = 0x14;
static constexpr u32 S_THREAD_LOCAL_INIT_FUNCTION_POINTERS = 0x15;
static constexpr u32 S_INIT_FUNC_OFFSETS = 0x16;

static constexpr u32 S_ATTR_LOC_RELOC = 0x000001;
static constexpr u32 S_ATTR_EXT_RELOC = 0x000002;
static constexpr u32 S_ATTR_SOME_INSTRUCTIONS = 0x000004;

static constexpr u32 S_ATTR_DEBUG = 0x020000;
static constexpr u32 S_ATTR_SELF_MODIFYING_CODE = 0x040000;
static constexpr u32 S_ATTR_LIVE_SUPPORT = 0x080000;
static constexpr u32 S_ATTR_NO_DEAD_STRIP = 0x100000;
static constexpr u32 S_ATTR_STRIP_STATIC_SYMS = 0x200000;
static constexpr u32 S_ATTR_NO_TOC = 0x400000;
static constexpr u32 S_ATTR_PURE_INSTRUCTIONS = 0x800000;

static constexpr u32 CPU_TYPE_X86_64 = 0x1000007;
static constexpr u32 CPU_TYPE_ARM64 = 0x100000c;

static constexpr u32 CPU_SUBTYPE_X86_64_ALL = 3;
static constexpr u32 CPU_SUBTYPE_ARM64_ALL = 0;

static constexpr u32 REBASE_TYPE_POINTER = 1;
static constexpr u32 REBASE_TYPE_TEXT_ABSOLUTE32 = 2;
static constexpr u32 REBASE_TYPE_TEXT_PCREL32 = 3;

static constexpr u32 REBASE_OPCODE_MASK = 0xf0;
static constexpr u32 REBASE_IMMEDIATE_MASK = 0x0f;
static constexpr u32 REBASE_OPCODE_DONE = 0x00;
static constexpr u32 REBASE_OPCODE_SET_TYPE_IMM = 0x10;
static constexpr u32 REBASE_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB = 0x20;
static constexpr u32 REBASE_OPCODE_ADD_ADDR_ULEB = 0x30;
static constexpr u32 REBASE_OPCODE_ADD_ADDR_IMM_SCALED = 0x40;
static constexpr u32 REBASE_OPCODE_DO_REBASE_IMM_TIMES = 0x50;
static constexpr u32 REBASE_OPCODE_DO_REBASE_ULEB_TIMES = 0x60;
static constexpr u32 REBASE_OPCODE_DO_REBASE_ADD_ADDR_ULEB = 0x70;
static constexpr u32 REBASE_OPCODE_DO_REBASE_ULEB_TIMES_SKIPPING_ULEB = 0x80;

static constexpr u32 BIND_TYPE_POINTER = 1;
static constexpr u32 BIND_TYPE_TEXT_ABSOLUTE32 = 2;
static constexpr u32 BIND_TYPE_TEXT_PCREL32 = 3;

static constexpr u32 BIND_SPECIAL_DYLIB_SELF = 0;
static constexpr u32 BIND_SPECIAL_DYLIB_MAIN_EXECUTABLE = -1;
static constexpr u32 BIND_SPECIAL_DYLIB_FLAT_LOOKUP = -2;
static constexpr u32 BIND_SPECIAL_DYLIB_WEAK_LOOKUP = -3;

static constexpr u32 BIND_SYMBOL_FLAGS_WEAK_IMPORT = 0x1;
static constexpr u32 BIND_SYMBOL_FLAGS_NON_WEAK_DEFINITION = 0x8;

static constexpr u32 BIND_OPCODE_MASK = 0xF0;
static constexpr u32 BIND_IMMEDIATE_MASK = 0x0F;
static constexpr u32 BIND_OPCODE_DONE = 0x00;
static constexpr u32 BIND_OPCODE_SET_DYLIB_ORDINAL_IMM = 0x10;
static constexpr u32 BIND_OPCODE_SET_DYLIB_ORDINAL_ULEB = 0x20;
static constexpr u32 BIND_OPCODE_SET_DYLIB_SPECIAL_IMM = 0x30;
static constexpr u32 BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM = 0x40;
static constexpr u32 BIND_OPCODE_SET_TYPE_IMM = 0x50;
static constexpr u32 BIND_OPCODE_SET_ADDEND_SLEB = 0x60;
static constexpr u32 BIND_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB = 0x70;
static constexpr u32 BIND_OPCODE_ADD_ADDR_ULEB = 0x80;
static constexpr u32 BIND_OPCODE_DO_BIND = 0x90;
static constexpr u32 BIND_OPCODE_DO_BIND_ADD_ADDR_ULEB = 0xA0;
static constexpr u32 BIND_OPCODE_DO_BIND_ADD_ADDR_IMM_SCALED = 0xB0;
static constexpr u32 BIND_OPCODE_DO_BIND_ULEB_TIMES_SKIPPING_ULEB = 0xC0;
static constexpr u32 BIND_OPCODE_THREADED = 0xD0;
static constexpr u32 BIND_SUBOPCODE_THREADED_SET_BIND_ORDINAL_TABLE_SIZE_ULEB = 0x00;
static constexpr u32 BIND_SUBOPCODE_THREADED_APPLY = 0x01;

static constexpr u32 EXPORT_SYMBOL_FLAGS_KIND_MASK = 0x03;
static constexpr u32 EXPORT_SYMBOL_FLAGS_KIND_REGULAR = 0x00;
static constexpr u32 EXPORT_SYMBOL_FLAGS_KIND_THREAD_LOCAL = 0x01;
static constexpr u32 EXPORT_SYMBOL_FLAGS_KIND_ABSOLUTE = 0x02;
static constexpr u32 EXPORT_SYMBOL_FLAGS_WEAK_DEFINITION = 0x04;
static constexpr u32 EXPORT_SYMBOL_FLAGS_REEXPORT = 0x08;
static constexpr u32 EXPORT_SYMBOL_FLAGS_STUB_AND_RESOLVER = 0x10;

static constexpr u32 DICE_KIND_DATA = 1;
static constexpr u32 DICE_KIND_JUMP_TABLE8 = 2;
static constexpr u32 DICE_KIND_JUMP_TABLE16 = 3;
static constexpr u32 DICE_KIND_JUMP_TABLE32 = 4;
static constexpr u32 DICE_KIND_ABS_JUMP_TABLE32 = 5;

static constexpr u32 N_UNDF = 0;
static constexpr u32 N_ABS = 1;
static constexpr u32 N_INDR = 5;
static constexpr u32 N_PBUD = 6;
static constexpr u32 N_SECT = 7;

static constexpr u32 N_GSYM = 0x20;
static constexpr u32 N_FNAME = 0x22;
static constexpr u32 N_FUN = 0x24;
static constexpr u32 N_STSYM = 0x26;
static constexpr u32 N_LCSYM = 0x28;
static constexpr u32 N_BNSYM = 0x2e;
static constexpr u32 N_AST = 0x32;
static constexpr u32 N_OPT = 0x3c;
static constexpr u32 N_RSYM = 0x40;
static constexpr u32 N_SLINE = 0x44;
static constexpr u32 N_ENSYM = 0x4e;
static constexpr u32 N_SSYM = 0x60;
static constexpr u32 N_SO = 0x64;
static constexpr u32 N_OSO = 0x66;
static constexpr u32 N_LSYM = 0x80;
static constexpr u32 N_BINCL = 0x82;
static constexpr u32 N_SOL = 0x84;
static constexpr u32 N_PARAMS = 0x86;
static constexpr u32 N_VERSION = 0x88;
static constexpr u32 N_OLEVEL = 0x8A;
static constexpr u32 N_PSYM = 0xa0;
static constexpr u32 N_EINCL = 0xa2;
static constexpr u32 N_ENTRY = 0xa4;
static constexpr u32 N_LBRAC = 0xc0;
static constexpr u32 N_EXCL = 0xc2;
static constexpr u32 N_RBRAC = 0xe0;
static constexpr u32 N_BCOMM = 0xe2;
static constexpr u32 N_ECOMM = 0xe4;
static constexpr u32 N_ECOML = 0xe8;
static constexpr u32 N_LENG = 0xfe;
static constexpr u32 N_PC = 0x30;

static constexpr u32 REFERENCE_TYPE = 0xf;
static constexpr u32 REFERENCE_FLAG_UNDEFINED_NON_LAZY = 0;
static constexpr u32 REFERENCE_FLAG_UNDEFINED_LAZY = 1;
static constexpr u32 REFERENCE_FLAG_DEFINED = 2;
static constexpr u32 REFERENCE_FLAG_PRIVATE_DEFINED = 3;
static constexpr u32 REFERENCE_FLAG_PRIVATE_UNDEFINED_NON_LAZY = 4;
static constexpr u32 REFERENCE_FLAG_PRIVATE_UNDEFINED_LAZY = 5;

static constexpr u32 REFERENCED_DYNAMICALLY = 0x0010;

static constexpr u32 N_NO_DEAD_STRIP = 0x0020;
static constexpr u32 N_DESC_DISCARDED = 0x0020;
static constexpr u32 N_WEAK_REF = 0x0040;
static constexpr u32 N_WEAK_DEF = 0x0080;
static constexpr u32 N_REF_TO_WEAK = 0x0080;
static constexpr u32 N_ARM_THUMB_DEF = 0x0008;
static constexpr u32 N_SYMBOL_RESOLVER = 0x0100;
static constexpr u32 N_ALT_ENTRY = 0x0200;

static constexpr u32 PLATFORM_MACOS = 1;
static constexpr u32 PLATFORM_IOS = 2;
static constexpr u32 PLATFORM_TVOS = 3;
static constexpr u32 PLATFORM_WATCHOS = 4;
static constexpr u32 PLATFORM_BRIDGEOS = 5;
static constexpr u32 PLATFORM_MACCATALYST = 6;
static constexpr u32 PLATFORM_IOSSIMULATOR = 7;
static constexpr u32 PLATFORM_TVOSSIMULATOR = 8;
static constexpr u32 PLATFORM_WATCHOSSIMULATOR = 9;
static constexpr u32 PLATFORM_DRIVERKIT = 10;

static constexpr u32 TOOL_CLANG = 1;
static constexpr u32 TOOL_SWIFT = 2;
static constexpr u32 TOOL_LD = 3;

static constexpr u32 ARM64_RELOC_UNSIGNED = 0;
static constexpr u32 ARM64_RELOC_SUBTRACTOR = 1;
static constexpr u32 ARM64_RELOC_BRANCH26 = 2;
static constexpr u32 ARM64_RELOC_PAGE21 = 3;
static constexpr u32 ARM64_RELOC_PAGEOFF12 = 4;
static constexpr u32 ARM64_RELOC_GOT_LOAD_PAGE21 = 5;
static constexpr u32 ARM64_RELOC_GOT_LOAD_PAGEOFF12 = 6;
static constexpr u32 ARM64_RELOC_POINTER_TO_GOT = 7;
static constexpr u32 ARM64_RELOC_TLVP_LOAD_PAGE21 = 8;
static constexpr u32 ARM64_RELOC_TLVP_LOAD_PAGEOFF12 = 9;
static constexpr u32 ARM64_RELOC_ADDEND = 10;

static constexpr u32 X86_64_RELOC_UNSIGNED = 0;
static constexpr u32 X86_64_RELOC_SIGNED = 1;
static constexpr u32 X86_64_RELOC_BRANCH = 2;
static constexpr u32 X86_64_RELOC_GOT_LOAD = 3;
static constexpr u32 X86_64_RELOC_GOT = 4;
static constexpr u32 X86_64_RELOC_SUBTRACTOR = 5;
static constexpr u32 X86_64_RELOC_SIGNED_1 = 6;
static constexpr u32 X86_64_RELOC_SIGNED_2 = 7;
static constexpr u32 X86_64_RELOC_SIGNED_4 = 8;
static constexpr u32 X86_64_RELOC_TLV = 9;

struct FatHeader {
  ubig32 magic;
  ubig32 nfat_arch;
};

struct FatArch {
  ubig32 cputype;
  ubig32 cpusubtype;
  ubig32 offset;
  ubig32 size;
  ubig32 align;
};

struct MachHeader {
  u32 magic;
  u32 cputype;
  u32 cpusubtype;
  u32 filetype;
  u32 ncmds;
  u32 sizeofcmds;
  u32 flags;
  u32 reserved;
};

struct LoadCommand {
  u32 cmd;
  u32 cmdsize;
};

struct SegmentCommand {
  std::string_view get_segname() const {
    return {segname, strnlen(segname, sizeof(segname))};
  }

  u32 cmd;
  u32 cmdsize;
  char segname[16];
  u64 vmaddr;
  u64 vmsize;
  u64 fileoff;
  u64 filesize;
  u32 maxprot;
  u32 initprot;
  u32 nsects;
  u32 flags;
};

struct MachSection {
  void set_segname(std::string_view name) {
    assert(name.size() <= sizeof(segname));
    memcpy(segname, name.data(), name.size());
  }

  std::string_view get_segname() const {
    return {segname, strnlen(segname, sizeof(segname))};
  }

  void set_sectname(std::string_view name) {
    assert(name.size() <= sizeof(sectname));
    memcpy(sectname, name.data(), name.size());
  }

  std::string_view get_sectname() const {
    return {sectname, strnlen(sectname, sizeof(sectname))};
  }

  bool match(std::string_view segname, std::string_view sectname) const {
    return get_segname() == segname && get_sectname() == sectname;
  }

  char sectname[16];
  char segname[16];
  u64 addr;
  u64 size;
  u32 offset;
  u32 p2align;
  u32 reloff;
  u32 nreloc;
  u32 type : 8;
  u32 attr : 24;
  u32 reserved1;
  u32 reserved2;
  u32 reserved3;
};

struct DylibCommand {
  u32 cmd;
  u32 cmdsize;
  u32 nameoff;
  u32 timestamp;
  u32 current_version;
  u32 compatibility_version;
};

struct DylinkerCommand {
  u32 cmd;
  u32 cmdsize;
  u32 nameoff;
};

struct SymtabCommand {
  u32 cmd;
  u32 cmdsize;
  u32 symoff;
  u32 nsyms;
  u32 stroff;
  u32 strsize;
};

struct DysymtabCommand {
  u32 cmd;
  u32 cmdsize;
  u32 ilocalsym;
  u32 nlocalsym;
  u32 iextdefsym;
  u32 nextdefsym;
  u32 iundefsym;
  u32 nundefsym;
  u32 tocoff;
  u32 ntoc;
  u32 modtaboff;
  u32 nmodtab;
  u32 extrefsymoff;
  u32 nextrefsyms;
  u32 indirectsymoff;
  u32 nindirectsyms;
  u32 extreloff;
  u32 nextrel;
  u32 locreloff;
  u32 nlocrel;
};

struct VersionMinCommand {
  u32 cmd;
  u32 cmdsize;
  u32 version;
  u32 sdk;
};

struct DyldInfoCommand {
  u32 cmd;
  u32 cmdsize;
  u32 rebase_off;
  u32 rebase_size;
  u32 bind_off;
  u32 bind_size;
  u32 weak_bind_off;
  u32 weak_bind_size;
  u32 lazy_bind_off;
  u32 lazy_bind_size;
  u32 export_off;
  u32 export_size;
};

struct UUIDCommand {
  u32 cmd;
  u32 cmdsize;
  u8 uuid[16];
};

struct RpathCommand {
  u32 cmd;
  u32 cmdsize;
  u32 path_off;
};

struct LinkEditDataCommand {
  u32 cmd;
  u32 cmdsize;
  u32 dataoff;
  u32 datasize;
};

struct BuildToolVersion {
  u32 tool;
  u32 version;
};

struct BuildVersionCommand {
  u32 cmd;
  u32 cmdsize;
  u32 platform;
  u32 minos;
  u32 sdk;
  u32 ntools;
};

struct EntryPointCommand {
  u32 cmd;
  u32 cmdsize;
  u64 entryoff;
  u64 stacksize;
};

struct SourceVersionCommand {
  u32 cmd;
  u32 cmdsize;
  u64 version;
};

struct DataInCodeEntry {
  u32 offset;
  u16 length;
  u16 kind;
};

// This struct is named `n_list` on BSD and macOS.
struct MachSym {
  bool is_undef() const {
    return type == N_UNDF && !is_common();
  }

  bool is_common() const {
    return type == N_UNDF && ext && value;
  }

  u32 stroff;
  u8 ext : 1;
  u8 type : 3;
  u8 pext : 1;
  u8 stub : 3;
  u8 sect;
  union {
    u16 desc;
    struct {
      u16 : 8;
      u16 p2align : 4;
      u16 : 4;
    };
  };
  u64 value;
};

// This struct is named `relocation_info` on BSD and macOS.
struct MachRel {
  u32 offset;
  u32 idx : 24;
  u32 is_pcrel : 1;
  u32 p2size : 2;
  u32 is_extern : 1;
  u32 type : 4;
};

// __TEXT,__unwind_info section contents

static constexpr u32 UNWIND_SECTION_VERSION = 1;
static constexpr u32 UNWIND_SECOND_LEVEL_REGULAR = 2;
static constexpr u32 UNWIND_SECOND_LEVEL_COMPRESSED = 3;
static constexpr u32 UNWIND_PERSONALITY_MASK = 0x30000000;

struct UnwindSectionHeader {
  u32 version;
  u32 encoding_offset;
  u32 encoding_count;
  u32 personality_offset;
  u32 personality_count;
  u32 page_offset;
  u32 page_count;
};

struct UnwindFirstLevelPage {
  u32 func_addr;
  u32 page_offset;
  u32 lsda_offset;
};

struct UnwindSecondLevelPage {
  u32 kind;
  u16 page_offset;
  u16 page_count;
  u16 encoding_offset;
  u16 encoding_count;
};

struct UnwindLsdaEntry {
  u32 func_addr;
  u32 lsda_addr;
};

struct UnwindPageEntry {
  u32 func_addr : 24;
  u32 encoding : 8;
};

// __LD,__compact_unwind section contents

struct CompactUnwindEntry {
  u64 code_start;
  u32 code_len;
  u32 encoding;
  u64 personality;
  u64 lsda;
};

// __LINKEDIT,__code_signature

static constexpr u32 CSMAGIC_EMBEDDED_SIGNATURE = 0xfade0cc0;
static constexpr u32 CS_SUPPORTSEXECSEG = 0x20400;
static constexpr u32 CSMAGIC_CODEDIRECTORY = 0xfade0c02;
static constexpr u32 CSSLOT_CODEDIRECTORY = 0;
static constexpr u32 CS_ADHOC = 0x00000002;
static constexpr u32 CS_LINKER_SIGNED = 0x00020000;
static constexpr u32 CS_EXECSEG_MAIN_BINARY = 1;
static constexpr u32 CS_HASHTYPE_SHA256 = 2;

struct CodeSignatureHeader {
  ubig32 magic;
  ubig32 length;
  ubig32 count;
};

struct CodeSignatureBlobIndex {
  ubig32 type;
  ubig32 offset;
  u32 padding;
};

struct CodeSignatureDirectory {
  ubig32 magic;
  ubig32 length;
  ubig32 version;
  ubig32 flags;
  ubig32 hash_offset;
  ubig32 ident_offset;
  ubig32 n_special_slots;
  ubig32 n_code_slots;
  ubig32 code_limit;
  u8 hash_size;
  u8 hash_type;
  u8 platform;
  u8 page_size;
  ubig32 spare2;
  ubig32 scatter_offset;
  ubig32 team_offset;
  ubig32 spare3;
  ubig64 code_limit64;
  ubig64 exec_seg_base;
  ubig64 exec_seg_limit;
  ubig64 exec_seg_flags;
};

struct ARM64 {
  static constexpr u32 cputype = CPU_TYPE_ARM64;
  static constexpr u32 cpusubtype = CPU_SUBTYPE_ARM64_ALL;
  static constexpr u32 abs_rel = ARM64_RELOC_UNSIGNED;
  static constexpr u32 word_size = 8;
  static constexpr u32 stub_size = 12;
  static constexpr u32 stub_helper_hdr_size = 24;
  static constexpr u32 stub_helper_size = 12;
};

struct X86_64 {
  static constexpr u32 cputype = CPU_TYPE_X86_64;
  static constexpr u32 cpusubtype = CPU_SUBTYPE_X86_64_ALL;
  static constexpr u32 abs_rel = X86_64_RELOC_UNSIGNED;
  static constexpr u32 word_size = 8;
  static constexpr u32 stub_size = 6;
  static constexpr u32 stub_helper_hdr_size = 16;
  static constexpr u32 stub_helper_size = 10;
};

} // namespace mold::macho
