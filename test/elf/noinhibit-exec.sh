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

cat <<EOF | $CC -o $t/a.o -c -xc - -fno-PIC
int main() {}
EOF

$CC -B. -shared -o $t/b.so $t/a.o

! $CC -B. -o $t/b.so $t/a.o -Wl,-require-defined=no-such-sym >& $t/log1 || false
grep -q 'undefined symbol: no-such-sym' $t/log1

$CC -B. -shared -o $t/b.o $t/a.o -Wl,-require-defined=no-such-sym -Wl,-noinhibit-exec >& $t/log2
grep -q 'undefined symbol: no-such-sym' $t/log2

echo OK
