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

cat <<EOF | $GCC -c -o $t/a.o -xc -
void foo() {}

__attribute__((section(".gnu.warning.foo")))
static const char foo_warning[] = "warning message";
EOF

cat <<EOF | $CC -c -o $t/b.o -xc -
void foo();

int main() { foo(); }
EOF

# Make sure that we do not copy .gnu.warning.* sections.
$CC -B. -o $t/exe $t/a.o $t/b.o
! readelf --sections $t/exe | fgrep -q .gnu.warning || false

echo OK
