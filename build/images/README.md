# zetta-bridge — image build tooling

Dockerfiles that build the Orama Zetta component images from the **local submodule source** and push
them to **private Docker Hub** (`oramasearch/*`). Same pattern as
[`orama-cloud-v1-bridge/build/images`](https://github.com/oramasearch/orama-cloud-v1-bridge/tree/main/build/images):
**safe by design** — a local `docker build` against the submodule source touches no source-repo remote,
so it cannot trigger any CI; the Dockerfiles live here in the bridge, never in `oramasearch/zetta`.

| Image | Repo | Dockerfile | Source | Notes |
|---|---|---|---|---|
| Zetta (headless) | `oramasearch/zetta` | [`zetta-headless/Dockerfile`](zetta-headless/Dockerfile) | `modules/zetta` | The single `zetta` binary run with `--headless`. C++26 (clang-19) + CMake ≥3.30 (`cxx_std_26`). The build still compiles SDL3/ImGui (no headless-only target yet); the runtime image needs no display libs. |
| Zetta e2e runner | `oramasearch/zetta-e2e` | [`zetta-e2e/Dockerfile`](zetta-e2e/Dockerfile) | `modules/zetta` | Alpine + `curl` + `jq` + the e2e script (`tests/e2e/zetta-e2e.sh`). No compile — builds fast for any arch. Run in-cluster by the operator's `ZettaClusterE2ETest` CRD against a deployed `OramaZettaCluster`; drives the node's `:4800` API (test levels 2 + 3). |

## Build + push

Use **[`build.sh`](build.sh)** — the same manifest-driven pattern as
[`orama-cloud-v1-bridge/build/images`](https://github.com/oramasearch/orama-cloud-v1-bridge/tree/main/build/images):
it builds each component from its submodule source with `docker buildx`, pushes to the **private**
`oramasearch/*` repo (create it private first — see the `dockerhub-ops` skill), and records a
reproducibility row (`source@commit` + image digest) into [`build-manifest.tsv`](build-manifest.tsv).
Don't hand-run `docker build`/`buildx` — go through the script so the manifest stays honest.

```bash
# from zetta-bridge/  (run `docker login` first; recurse submodules for the engine build)
./build/images/build.sh --push zetta-e2e                 # the e2e runner (amd64, any host)
./build/images/build.sh --push zetta-headless            # the C++26 engine — NATIVE amd64 only
./build/images/build.sh                                  # build all locally (--load), no push
REGISTRY=oramasearch TAG=v1-sandbox ./build/images/build.sh --push zetta-e2e zetta-headless
```

- **`zetta-e2e`** → `oramasearch/zetta-e2e:v1-sandbox` — Alpine + `curl`/`jq` + the baked suite; no
  compile, so it builds for `linux/amd64` anywhere. Pulled by the operator's `ZettaClusterE2ETest` CRD.
- **`zetta-headless`** → `oramasearch/zetta:headless-v1-sandbox` — the C++26 engine. This is a **native
  `linux/amd64`** compile: run it on the amd64 build box (QEMU emulation on Apple Silicon hits
  `Illegal instruction` and is far too slow). Recurse submodules first (`git submodule update --init
  --recursive modules/zetta`) — the Dockerfile `COPY`s them. Pulled by the `OramaZettaCluster` CRD.

Plan of record: [`orama-bridge` `docs/projects/one-orama`](https://github.com/oramasearch/orama-bridge/tree/main/docs/projects/one-orama).

## Notes / gotchas

- **CMake version:** Ubuntu 24.04 ships CMake 3.28, which does **not** know `cxx_std_26` for Clang 19
  (`target_compile_features` errors). The Dockerfile installs CMake 3.31 into the build stage.
- **libc++:** the runtime binary links only `libssl`/`libcrypto` (verified via `ldd`); no libc++ runtime
  package is needed.
- **Headless-only build:** there is no `zetta-headless` CMake target yet, so the image builds the full
  binary (incl. the SDL3/ImGui GUI) and runs it with `--headless`. A slim headless target is a
  follow-up Zetta code change.
