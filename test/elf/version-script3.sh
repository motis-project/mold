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

cat <<EOF > $t/a.ver
ver1 {
  global: f*o;
  local: *;
};

ver2 {
  global: b*;
};
EOF

cat <<EOF | $CC -B. -xc -shared -o $t/b.so -Wl,-version-script,$t/a.ver -
void foo() {}
void bar() {}
void baz() {}
EOF

cat <<EOF | $CC -xc -c -o $t/c.o -
void foo();
void bar();
void baz();

int main() {
  foo();
  bar();
  baz();
  return 0;
}
EOF

$CC -B. -o $t/exe $t/c.o $t/b.so
$QEMU $t/exe

readelf --dyn-syms $t/exe > $t/log
fgrep -q 'foo@ver1' $t/log
fgrep -q 'bar@ver2' $t/log
fgrep -q 'baz@ver2' $t/log

echo OK
