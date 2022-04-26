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

# musl does not support GNU-style init/fini priorities
echo 'int main() {}' | $CC -o $t/exe -xc -
readelf --dynamic $t/exe | grep -q ld-musl && { echo skipped; exit; }

cat <<'EOF' | $CC -c -o $t/a.o -xc -
#include <stdio.h>
__attribute__((constructor(10000))) void init4() { printf("1"); }
EOF

cat <<'EOF' | $CC -c -o $t/b.o -xc -
#include <stdio.h>
__attribute__((constructor(1000))) void init3() { printf("2"); }
EOF

cat <<'EOF' | $CC -c -o $t/c.o -xc -
#include <stdio.h>
__attribute__((constructor)) void init1() { printf("3"); }
EOF

cat <<'EOF' | $CC -c -o $t/d.o -xc -
#include <stdio.h>
__attribute__((constructor)) void init2() { printf("4"); }
EOF

cat <<'EOF' | $CC -c -o $t/e.o -xc -
#include <stdio.h>
__attribute__((destructor(10000))) void fini4() { printf("5"); }
EOF

cat <<'EOF' | $CC -c -o $t/f.o -xc -
#include <stdio.h>
__attribute__((destructor(1000))) void fini3() { printf("6"); }
EOF

cat <<'EOF' | $CC -c -o $t/g.o -xc -
#include <stdio.h>
__attribute__((destructor)) void fini1() { printf("7"); }
EOF

cat <<'EOF' | $CC -c -o $t/h.o -xc -
#include <stdio.h>
__attribute__((destructor)) void fini2() { printf("8"); }
EOF

cat <<EOF | $CC -c -o $t/i.o -xc -
int main() {}
EOF

$CC -B. -o $t/exe $t/a.o $t/b.o $t/c.o $t/d.o $t/e.o $t/f.o $t/g.o $t/h.o $t/i.o
$QEMU $t/exe | grep -q '21348756'

echo OK
