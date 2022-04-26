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

# Verify that mold does not crash if no object file is included
# in the output. The resulting executable doesn't contain any
# meaningful code or data, so this is an edge case, though.

cat <<EOF | $CC -x assembler -c -o $t/a.o -
.globl foo
foo:
EOF

rm -f $t/a.a
ar rcs $t/a.a $t/a.o

"$mold" -o $t/exe $t/a.a

echo OK
