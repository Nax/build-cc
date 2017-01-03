# cross-compiler

A shell script that automates the creation of a binutils/gcc cross toolchain.

# Usage

```sh
# Download the script
curl -#LO "https://raw.githubusercontent.com/Nax/cross-compiler/master/bin/cross-compiler"
# Make it executable
chmod +x cross-compiler
# Run it
./cross-compiler x86_64-elf
```

# Options

This script supports a few options:

* `--prefix <prefix>` Install the cross compiler at the specified directory. Defaults to /opt/cross.
* `--languages <languages>` A comma separated list of languages the toolchain must support. Defaults to c,c++.
* `--efi` Inject PE targets into the binutils build, thus allowing the toolchain to be used to create (U)EFI applications.

# Examples

```sh
# Create an x86_64 elf toolchain, efi-compatible
./cross-compiler --efi x86_64-elf

# Create an i386 elf toolchain, with C and go support, installed in /usr/local
./cross-compiler --prefix /usr/local --languages c,go i386-elf

# Create a x86_64 elf toolchain, as well as an i386 pe toolchain
./cross-compiler x86_64-elf i386-pe
```

# License

This software is distributed under the GNU General Public License version 2 (**GPLv2**)
