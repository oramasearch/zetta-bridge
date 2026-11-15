# zetta-bridge — image build tooling

Dockerfiles that build the Orama Zetta component images from the **local submodule source** and push
them to **private Docker Hub** (`oramasearch/*`). Same pattern as
[`orama-cloud-v1-bridge/build/images`](https://github.com/oramasearch/orama-cloud-v1-bridge/tree/main/build/images):
**safe by design** — a local `docker build` against the submodule source touches no source-repo remote,
so it cannot trigger any CI; the Dockerfiles live here in the bridge, never in `oramasearch/zetta`.

| Image | Repo | Dockerfile | Source | Notes |
|---|---|---|---|---|
| Zetta (headless) | `oramasearch/zetta` | [`zetta-headless/Dockerfile`](zetta-headless/Dockerfile) | `modules/zetta` | The single `zetta` binary run with `--headless`. C++26 (clang-19) + CMake ≥3.30 (`cxx_std_26`). The build still compiles SDL3/ImGui (no headless-only target yet); the runtime image needs no display libs. |
| Zetta e2e | `oramasearch/zetta-e2e` | [`zetta-e2e/Dockerfile`](zetta-e2e/Dockerfile) | `modules/zetta` | Alpine + curl + jq baking `tests/e2e/zetta-e2e.sh` as the ENTRYPOINT — the live-cluster e2e suite (drives a deployed node's HTTP API; builds nothing). Triggered by the operator's `ZettaClusterE2ETest` CRD. Rebuild whenever the script changes (it evolves with the engine — e.g. a capability rename). |

Every base image is pinned by digest (`image:tag@sha256:…`, lake#1003): a moved upstream tag never changes what is built. Move a pin only by reading the tag's new index digest.

## Build + push

Requires Docker + `docker login` (Docker Hub). The build is a **native `linux/amd64`** compile — do it
on an amd64 host (QEMU emulation on Apple Silicon hits `Illegal instruction` and is far too slow for a
C++26 build). All Zetta submodules must be checked out recursively (`git submodule update --init
--recursive`) — the Dockerfile `COPY`s them; no git/SSH is needed inside the build.

```bash
# from zetta-bridge/ , context = the zetta source
DOCKER_BUILDKIT=0 docker build \
  -f build/images/zetta-headless/Dockerfile \
  -t oramasearch/zetta:headless-v1-sandbox \
  modules/zetta
docker push oramasearch/zetta:headless-v1-sandbox
```

The operator's `OramaZettaCluster` CRD pulls `oramasearch/zetta:headless-v1-sandbox` by default. See the
plan of record: [`orama-bridge` `docs/projects/one-orama`](https://github.com/oramasearch/orama-bridge/tree/main/docs/projects/one-orama).

## Notes / gotchas

- **CMake version:** Ubuntu 24.04 ships CMake 3.28, which does **not** know `cxx_std_26` for Clang 19
  (`target_compile_features` errors). The Dockerfile installs CMake 3.31 into the build stage.
- **libc++:** the runtime binary links only `libssl`/`libcrypto` (verified via `ldd`); no libc++ runtime
  package is needed.
- **Headless-only build:** there is no `zetta-headless` CMake target yet, so the image builds the full
  binary (incl. the SDL3/ImGui GUI) and runs it with `--headless`. A slim headless target is a
  follow-up Zetta code change.
