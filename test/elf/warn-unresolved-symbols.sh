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
int foo();
int main() {
  foo();
}
EOF

! $CC -B. -o $t/exe $t/a.o 2>&1 \
  | grep -q 'undefined symbol:.*foo'

$CC -B. -o $t/exe $t/a.o -Wl,-warn-unresolved-symbols 2>&1 \
  | grep -q 'undefined symbol:.*foo'

! $CC -B. -o $t/exe $t/a.o -Wl,-warn-unresolved-symbols \
  --error-unresolved-symbols 2>&1 \
  | grep -q 'undefined symbol:.*foo'

echo OK
