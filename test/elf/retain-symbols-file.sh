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

cat <<EOF | $CC -c -o $t/a.o -xc -
static void foo() {}
void bar() {}
void baz() {}
int main() { foo(); }
EOF

cat <<EOF > $t/symbols
foo
baz
EOF

$CC -B. -o $t/exe $t/a.o -Wl,--retain-symbols-file=$t/symbols
readelf --symbols $t/exe > $t/log

! grep -qw foo $t/log || false
! grep -qw bar $t/log || false
! grep -qw main $t/log || false

grep -qw baz $t/log

echo OK
