#!/bin/bash
export LC_ALL=C
set -e
CC="${CC:-cc}"
CXX="${CXX:-c++}"
GCC="${GCC:-gcc}"
GXX="${GXX:-g++}"
OBJDUMP="${OBJDUMP:-objdump}"
MACHINE="${MACHINE:-$(uname -m)}"
testname=$(basename "$0" .sh)
echo -n "Testing $testname ... "
cd "$(dirname "$0")"/../..
mold="$(pwd)/mold"
t=out/test/elf/$testname
mkdir -p $t

# Skip if libc is musl
echo 'int main() {}' | $CC -o $t/exe -xc -
readelf --dynamic $t/exe | grep -q ld-musl && { echo OK; exit; }

# Skip if target is not x86-64
[ $MACHINE = x86_64 ] || { echo skipped; exit; }

cat <<'EOF' | $CC -c -o $t/a.o -x assembler -
.globl fn
fn:
  movabs main, %rax
  ret
EOF

cat <<EOF | $CC -c -o $t/b.o -fPIC -xc -
void fn();
int main() { fn(); }
EOF

$CC -B. -o $t/exe $t/a.o $t/b.o -pie -Wl,-warn-textrel >& $t/log
grep -q 'relocation against symbol `main'\'' in read-only section' $t/log
grep -q 'creating a DT_TEXTREL in an output file' $t/log

echo OK
