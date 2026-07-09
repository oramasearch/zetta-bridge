# Orama Zetta — headless Linux/amd64 image.
#
# Builds the single `zetta` binary (headless core + the SDL3/ImGui headed UI — there is no
# headless-only build target yet) from the local, fully-checked-out submodule source, and runs it
# with `--headless`. SAFE local build: touches no source-repo remote, so it cannot trigger any CI.
#
# Build (from modules/zetta-bridge, context = the zetta source):
#   docker buildx build --platform linux/amd64 \
#     -f build/images/zetta-headless/Dockerfile \
#     -t oramasearch/zetta:headless-v1-sandbox --push modules/zetta
#
# The runtime never initializes SDL (headless), so the runtime image needs no X11/GL — only the
# OpenSSL 3 + C++ runtime. See docs/projects/one-orama/zetta-headless-reference.md (in orama-bridge).

# ---------- build stage ----------
FROM ubuntu:24.04 AS build
ENV DEBIAN_FRONTEND=noninteractive

# Clang 17+ is required for C++26; install clang-19 from the official LLVM apt channel. Plus the
# documented Ubuntu build deps (scripts/install-deps.sh) — including SDL3's X11/Wayland/GL/audio
# headers, which the shipped binary links even though headless never uses them. OpenSSL 3 is required
# (inter-node mTLS + cert minting).
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates wget gnupg lsb-release software-properties-common \
      build-essential cmake ninja-build git ccache lld \
      zlib1g-dev libssl-dev \
      libx11-dev libxext-dev libxrandr-dev libxi-dev libxcursor-dev \
      libxfixes-dev libxkbcommon-dev libwayland-dev wayland-protocols \
      libgl1-mesa-dev libegl1-mesa-dev libdbus-1-dev libudev-dev \
      libpipewire-0.3-dev libpulse-dev libasound2-dev \
 && wget -qO /tmp/llvm.sh https://apt.llvm.org/llvm.sh && chmod +x /tmp/llvm.sh && /tmp/llvm.sh 19 \
 && apt-get install -y --no-install-recommends libc++-19-dev libc++abi-19-dev \
 && rm -rf /var/lib/apt/lists/*

# Ubuntu 24.04 ships CMake 3.28, which does NOT know cxx_std_26 for Clang 19 (target_compile_features
# rejects it). Install a newer CMake that supports C++26 as a compile feature.
ARG CMAKE_VERSION=3.31.5
RUN wget -qO /tmp/cmake.sh "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.sh" \
 && sh /tmp/cmake.sh --skip-license --prefix=/usr/local && rm -f /tmp/cmake.sh && cmake --version

WORKDIR /src
# The submodules are already checked out locally (capy, corosio, automerge-cpp + its nested
# upstream/automerge + upstream/json, beast2, http, oramacore-cpp) — no git/SSH needed in the build.
COPY . /src

# CPU-only (CUDA off), tests off (skips GoogleTest fetch + the test targets). FetchContent pulls SDL3,
# ImGui, json-schema-validator, and Boost 1.91 into build/_deps at configure time (needs network).
# Build uses ALL cores (Ninja defaults to nproc; -j is pinned explicitly).
RUN cmake -S . -B build -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DZETTA_BUILD_TESTS=OFF \
      -DZETTA_ENABLE_CUDA=OFF \
      -DCMAKE_C_COMPILER=clang-19 \
      -DCMAKE_CXX_COMPILER=clang++-19 \
 && cmake --build build --target zetta -j "$(nproc)" \
 && { strip build/bin/zetta || true; }

# ---------- runtime stage ----------
FROM ubuntu:24.04 AS runtime
ENV DEBIAN_FRONTEND=noninteractive
# Runtime libs only: OpenSSL 3 + the C++ runtime. (If `ldd` shows libc++, add libc++1-19/libc++abi1-19
# from the LLVM channel — this first cut assumes the default libstdc++ toolchain.)
RUN apt-get update && apt-get install -y --no-install-recommends \
      libssl3 libstdc++6 ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && useradd -m -u 10001 -s /usr/sbin/nologin zetta \
 && mkdir -p /data && chown zetta:zetta /data

COPY --from=build /src/build/bin/zetta /usr/local/bin/zetta

USER zetta
WORKDIR /data
VOLUME ["/data"]
# 7777 = peer replication + signal (mTLS); 4800 = MCP + REST + serving (one HTTP port).
EXPOSE 7777 4800
ENTRYPOINT ["zetta"]
CMD ["--headless", "--data-dir", "/data", "--listen", "0.0.0.0:7777", "--mcp-listen", "0.0.0.0:4800"]
