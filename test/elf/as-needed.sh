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

cat <<EOF | $CC -o $t/a.o -c -xc -
void fn1();
int main() {
  fn1();
}
EOF

cat <<EOF | $CC -o $t/b.so -shared -fPIC -Wl,-soname,libfoo.so -xc -
int fn1() { return 42; }
EOF

cat <<EOF | $CC -o $t/c.so -shared -fPIC -Wl,-soname,libbar.so -xc -
int fn2() { return 42; }
EOF

$CC -B. -o $t/exe $t/a.o -Wl,--no-as-needed $t/b.so $t/c.so

readelf --dynamic $t/exe > $t/readelf
fgrep -q 'Shared library: [libfoo.so]' $t/readelf
fgrep -q 'Shared library: [libbar.so]' $t/readelf

$CC -B. -o $t/exe $t/a.o -Wl,--as-needed $t/b.so $t/c.so

readelf --dynamic $t/exe > $t/readelf
fgrep -q 'Shared library: [libfoo.so]' $t/readelf
! fgrep -q 'Shared library: [libbar.so]' $t/readelf || false

echo OK
