#!/bin/sh

set -e

thread_count=4

prefix="/opt/cross"
efi=false
languages=c,c++
targets=""

binutils_version=2.25
mpfr_version=3.1.3
gmp_version=6.0.0a
mpc_version=1.0.3
gcc_version=5.1.0

script="$0"
params="$@"

# Parse options
while [ ! -z "$1" ]; do
  case "$1" in
    '--efi')
      efi=true ;;
    '--prefix')
      shift
      if [ -z "$1" ]; then
        echo "--prefix should be followed by a value"
        exit 1
      fi
      prefix="$1" ;;
    '--languages')
      shift
      if [ -z "$1" ]; then
        echo "--languages should be followed by a value"
        exit 1
      fi
      languages="$1" ;;
    *)
      targets="$targets $1" ;;
  esac
  shift
done

if [ -z "$targets" ]; then
  echo "usage: ./cross-compiler.sh [--prefix prefix] [--languages languages] [--efi] target [target...]"
  echo
  echo
  echo "About the options:"
  echo
  echo "--efi                     Inject PE targets into binutils, making the toolset suitable for (U)EFI development"
  echo "--prefix <prefix>         Install the cross-compiler inside the specified directory. Defaults to /opt/cross"
  echo "--languages <languages>   A list of comma separated languages that the toolset will support. Defaults to c,c++"
  echo 
  echo
  echo "About this script:"
  echo "    This script was created by Nax."
  echo "    This is Free Software, published under the GNU General Public License version 2 (GPLv2)"
  exit
fi

# Check if root is needed to install at the required prefix.
# If that's the case, reload the script as root.
if ! mkdir -p "$prefix" > /dev/null 2>&1 || [ ! -w "$prefix" ]; then
  exec sudo -- "$script" $params
fi

cd /tmp
tmpdir=$(mktemp -d "cross-compiler-XXXXXXXXXX")
cd $tmpdir

echo "Downloading binutils"
curl -#L "https://ftp.gnu.org/gnu/binutils/binutils-$binutils_version.tar.bz2" -o binutils.tar.bz2
mkdir -p binutils
tar xjf binutils.tar.bz2 -C binutils --strip=1
echo

echo "Downloading gcc"
curl -#L "https://ftp.gnu.org/gnu/gcc/gcc-$gcc_version/gcc-$gcc_version.tar.bz2" -o gcc.tar.bz2
mkdir -p gcc
tar xjf gcc.tar.bz2 -C gcc --strip=1
echo

echo "Downloading mpfr"
curl -#L "https://ftp.gnu.org/gnu/mpfr/mpfr-$mpfr_version.tar.bz2" -o mpfr.tar.bz2
mkdir -p gcc/mpfr
tar xjf mpfr.tar.bz2 -C gcc/mpfr --strip=1
echo

echo "Downloading gmp"
curl -#L "https://ftp.gnu.org/gnu/gmp/gmp-$gmp_version.tar.bz2" -o gmp.tar.bz2
mkdir -p gcc/gmp
tar xjf gmp.tar.bz2 -C gcc/gmp --strip=1
echo

echo "Downloading mpc"
curl -#L "https://ftp.gnu.org/gnu/mpc/mpc-$mpc_version.tar.bz2" -o mpc.tar.bz2
mkdir -p gcc/mpc
tar xjf mpc.tar.bz2 -C gcc/mpc --strip=1
echo

for target in $targets; do
  cp -r binutils binutils-$target
  cd binutils-$target
  binutils_conf=""
  if $efi; then
    binutils_conf="--enable-targets=i386-pe,x86_64-pe"
  fi
  ./configure --prefix="$prefix" --target="$target" --disable-nls --enable-64-bit-bfd $binutils_conf
  make -j$thread_count all
  make install
  cd ..
  
  cp -r gcc gcc-$target
  cd gcc-$target
  ./configure --prefix="$prefix" --target="$target" --enable-languages=$languages --disable-multilib --disable-nls
  make -j$thread_count all-gcc
  make install-gcc
  cd ..
done

rm -rf "$tmpdir"

echo "Done !"
echo "Make sure to add the following to your PATH"
echo
echo "    $prefix/bin"
