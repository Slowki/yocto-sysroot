IMAGE_INSTALL:append = " \
    clang \
    clang-dev \
    clang-format \
    clang-tidy \
    clang-tools \
    compiler-rt-sanitizers \
    compiler-rt-sanitizers-dev \
    libpython3 \
    libpython3-staticdev \
    lldb \
    lldb-server \
    packagegroup-go-sdk-target \
    python3 \
    python3-core \
    python3-dev \
    python3-misc \
    python3-modules \
    python3-pip \
    python3-venv \
    python3-wheel \
    spirv-tools \
    vulkan-tools \
    wayland-tools \
"

inherit custom-image-base
