# Yocto Sysroot

A hacky Yocto sysroot in Bazel to hermetically compile for X86 and Aarch64 (Raspberry Pis).

## Features

- LLVM (clang, libc++, compiler-rt) and Musl based
- Vulkan
- Wayland

### Platforms

- X86_64: Skylake
- Aarch64: RaspberryPi 3

## Making the SDKs

```bash
# Build the image to run Yocto in
./scripts/build-container
# Make the Yocto sysroot tarballs
./in-docker build-sdks
```

## TODOs

- Enable LTO
- Figure out PGO
