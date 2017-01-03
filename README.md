# build-cc

A shell script that automates the creation of a binutils/gcc cross toolchain.

# Usage

```sh
# Download the script
curl -#LO "https://raw.githubusercontent.com/Nax/build-cc/master/bin/build-cc"
# Make it executable
chmod +x build-cc
# Run it
./build-cc x86_64-elf
```

# Options

This script supports a few options:

* `--prefix <prefix>` Install the cross compiler at the specified directory. Defaults to /opt/cross.
* `--languages <languages>` A comma separated list of languages the toolchain must support. Defaults to c,c++.
* `--efi` Inject PE targets into the binutils build, thus allowing the toolchain to be used to create (U)EFI applications.

# Examples

```sh
# Create an x86_64 elf toolchain, efi-compatible
./build-cc --efi x86_64-elf

# Create an i386 elf toolchain, with C and go support, installed in /usr/local
./build-cc --prefix /usr/local --languages c,go i386-elf

# Create a x86_64 elf toolchain, as well as an i386 pe toolchain
./build-cc x86_64-elf i386-pe
```

# License

This software is distributed under the GNU General Public License version 2 (**GPLv2**)
