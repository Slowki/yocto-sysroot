SUMMARY = "A minimal base image"

IMAGE_FEATURES = " \
    dbg-pkgs \
    dev-pkgs \
    staticdev-pkgs \
    tools-debug \
"

TARGET_TOOLCHAIN_LANGS = " \
    go \
    rust \
"

IMAGE_FSTYPES = "tar.gz"
PREFERRED_PROVIDER_virtual/kernel = "linux-dummy"
NO_RECOMMENDATIONS = "1"

IMAGE_BUILDINFO_FILE = ""

TOOLCHAIN_TARGET_TASK:append = " \
    compiler-rt-dev \
    libcxx-dev \
    lldb \
    vulkan-headers \
    vulkan-loader \
    wayland-dev \
    zlib-dev \
"

IMAGE_INSTALL:append = " \
    compiler-rt	\
    compiler-rt-dev \
    go-runtime \
    go-runtime-dev \
    libcxx \
    libcxx-dev \
    libsqlite3-dev \
    libsqlite3-staticdev \
    libstd-rs \
    libxkbcommon \
    lldb \
    libegl-mesa \
    libegl-mesa-dev \
    libgl-mesa-dev \
    mesa \
    mesa-dev \
    mesa-vulkan-drivers \
    openssl \
    openssl-dev \
    openssl-staticdev \
    sqlite3 \
    vulkan-headers \
    vulkan-loader \
    wayland \
    wayland-dev \
    wayland-protocols \
    zlib \
    zlib-dev \
    zstd \
    zstd-dev \
    zstd-staticdev \
"

TOOLCHAIN_HOST_TASK:remove = "\
    nativesdk-qemu \
    nativesdk-qemu-helper \
"

TOOLCHAIN_HOST_TASK:append = "\
    nativesdk-python3-core \
    nativesdk-python3-modules \
    nativesdk-python3-misc \
    nativesdk-clang \
    nativesdk-clang-dev \
    nativesdk-compiler-rt \
    nativesdk-compiler-rt-dev \
    nativesdk-compiler-rt-sanitizers \
    nativesdk-compiler-rt-sanitizers-dev \
    nativesdk-libcxx \
    nativesdk-libcxx-dev \
    nativesdk-lldb \
    nativesdk-lldb-server \
    nativesdk-wayland \
    nativesdk-wayland-dev \
    nativesdk-wayland-tools \
    nativesdk-zlib \
    nativesdk-zlib-dev \
"

def create_wrapper_scripts(image_rootfs: str) -> None:
    """Create wrapper scripts which invoke tools using the correct ld-linux binary."""
    import os
    import textwrap
    from pathlib import Path

    WRAPPER = textwrap.dedent("""\
    #!/bin/bash -e
    
    set -uo pipefail
    
    readonly SCRIPT_DIR=$(cd -- "$(dirname -- "${{BASH_SOURCE[0]}}")" &> /dev/null && pwd)
    SYSROOT="$SCRIPT_DIR/.."
    # TODO detect platform for wrapper
    readonly DEFAULT_INTERPRETER_PATH="$SYSROOT/lib/ld-musl-x86_64.so.1"

    if [[ -f "$DEFAULT_INTERPRETER_PATH" ]]; then
        INTERPRETER_PATH="$DEFAULT_INTERPRETER_PATH"
    else
        # If the interpreter cannot be found then try to do a runfiles lookup
        f=bazel_tools/tools/bash/runfiles/runfiles.bash
        source "${{RUNFILES_DIR:-/dev/null}}/$f" 2>/dev/null || \
            source "$(grep -sm1 "^$f " "${{RUNFILES_MANIFEST_FILE:-/dev/null}}" | cut -f2- -d' ')" 2>/dev/null || \
            source "$0.runfiles/$f" 2>/dev/null || \
            source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
            source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
            {{ echo>&2 "ERROR: cannot find $f"; exit 1; }}; f=; set -e
        
        INTERPRETER_PATH="$(rlocation "$(runfiles_current_repository)/lib/ld-musl-x86_64.so.1")"
        SYSROOT="$(dirname "$INTERPRETER_PATH")/.."
    fi

    export PYTHONHOME="$SYSROOT/usr"

    exec "$SYSROOT/lib/ld-musl-x86_64.so.1" \\
        --library-path "$SYSROOT/lib:$SYSROOT/usr/lib" \\
        --argv0 "$SYSROOT/wrappers/{basename}" \\
        -- "$SYSROOT/{path}" "$@"
    """)

    dest_dir = Path(image_rootfs)
    wrapper_dir = dest_dir / "wrappers"
    wrapper_dir.mkdir(exist_ok=True)
    for file in (dest_dir / "usr/bin").glob("*"):
        destination = wrapper_dir / file.name
        wrapper_script = WRAPPER.format(path=file.relative_to(dest_dir), basename=file.name)
        destination.write_text(wrapper_script)
        os.chmod(destination, 0o755)

python do_rootfs:append() {
    create_wrapper_scripts(d.getVar("IMAGE_ROOTFS"))
}

inherit core-image
