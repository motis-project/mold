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

cat <<'EOF' > $t/a.ver
{
local:
  *;
global:
  [abc][^abc][^\]a-zABC];
};
EOF

cat <<EOF | $CXX -fPIC -c -o $t/b.o -xc -
void azZ() {}
void czZ() {}
void azC() {}
void aaZ() {}
EOF

$CC -B. -shared -Wl,--version-script=$t/a.ver -o $t/c.so $t/b.o

readelf --dyn-syms $t/c.so > $t/log
grep -q ' azZ$' $t/log
grep -q ' czZ$' $t/log
! grep -q ' azC$' $t/log || false
! grep -q ' aaZ$' $t/log || false

echo OK
