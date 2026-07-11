#!/usr/bin/env bash
set -euo pipefail

# Build (and optionally push) the Orama Zetta component images from local submodule source.
#
# SAFE BY DESIGN — builds are LOCAL: they touch no prod-repo remote, so they can NOT trigger
# any CI/CD in oramasearch/zetta. This script never commits to, tags, or dispatches workflows
# in the source repo; the Dockerfiles it uses live here in the bridge, never in the source repo.
# Pushes go to PRIVATE Docker Hub repos under $REGISTRY with a sandbox $TAG.
#
# Usage:
#   ./build.sh [--push] [component ...]        # default: all components, build only (--load)
#   REGISTRY=oramasearch TAG=v1-sandbox ./build.sh --push zetta-e2e
#
# Components:
#   zetta-headless  the C++26 engine (oramasearch/zetta:headless-v1-sandbox) — a NATIVE amd64
#                   build; run it on the amd64 build box (QEMU emulation breaks the C++26 build).
#   zetta-e2e       the e2e runner (oramasearch/zetta-e2e:v1-sandbox) — Alpine + curl + jq + the
#                   baked suite; no compile, so it builds for amd64 on any host.
#
# Requires: docker (buildx). For --push: run `docker login` (Docker Hub) first, and create the
# PRIVATE repo first (see the dockerhub-ops skill — push defaults to public otherwise).

BRIDGE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$BRIDGE_ROOT"

REGISTRY="${REGISTRY:-oramasearch}"
TAG="${TAG:-v1-sandbox}"
PLATFORM="${PLATFORM:-linux/amd64}"   # the cluster nodes are amd64

PUSH=0
COMPONENTS=()
for a in "$@"; do
  case "$a" in
    --push) PUSH=1 ;;
    -*) echo "unknown flag: $a" >&2; exit 2 ;;
    *) COMPONENTS+=("$a") ;;
  esac
done

# name | image repo | build context | dockerfile | extra build args | tag override
# (the engine image is tagged headless-<TAG>; the e2e runner uses the default TAG.)
manifest() {
  cat <<EOF
zetta-headless|zetta|modules/zetta|build/images/zetta-headless/Dockerfile||headless-${TAG}
zetta-e2e|zetta-e2e|modules/zetta|build/images/zetta-e2e/Dockerfile||
EOF
}

want() {
  [ ${#COMPONENTS[@]} -eq 0 ] && return 0
  for c in "${COMPONENTS[@]}"; do [ "$c" = "$1" ] && return 0; done
  return 1
}

built=()
rows=()
while IFS='|' read -r name repo ctx dockerfile extra tagoverride; do
  [ -z "$name" ] && continue
  want "$name" || continue
  tag="${tagoverride:-$TAG}"
  image="${REGISTRY}/${repo}:${tag}"
  echo "==> ${name} -> ${image}"
  echo "    context=${ctx}  dockerfile=${dockerfile}"
  if [ ! -e "$ctx" ]; then
    echo "    !! source missing: ${ctx} (run 'git submodule update --init --recursive ${ctx}')" >&2
    exit 1
  fi
  # shellcheck disable=SC2086
  if docker buildx version >/dev/null 2>&1; then
    out="--load"; [ $PUSH -eq 1 ] && out="--push"
    docker buildx build --platform "$PLATFORM" -t "$image" -f "$dockerfile" $extra $out "$ctx"
  else
    # No buildx plugin (e.g. the native amd64 build box): plain build for the host arch + explicit push.
    docker build -t "$image" -f "$dockerfile" $extra "$ctx"
    [ $PUSH -eq 1 ] && docker push "$image"
  fi
  built+=("$image")
  # Reproducibility record: the exact source commit + (when pushed) the image digest, so a
  # rebuild from the same submodule SHA + pinned base images reproduces the same image.
  src_sha=$(git -C "$ctx" rev-parse --short HEAD 2>/dev/null || echo unknown)
  if [ $PUSH -eq 1 ]; then
    # Prefer the format template; fall back to awk-extracting the Digest: line on docker
    # versions where imagetools ignores --format (keeps the manifest a clean single line).
    digest=$(docker buildx imagetools inspect "$image" --format '{{.Manifest.Digest}}' 2>/dev/null)
    case "$digest" in
      sha256:*) : ;;
      *) digest=$(docker buildx imagetools inspect "$image" 2>/dev/null | awk '/^Digest:/{print $2; exit}') ;;
    esac
    case "$digest" in sha256:*) : ;; *) digest=$(docker inspect --format '{{index .RepoDigests 0}}' "$image" 2>/dev/null | sed 's/.*@//') ;; esac
    [ -n "$digest" ] || digest='?'
  else
    digest='(local, not pushed)'
  fi
  rows+=("$(printf '%s\t%s\t%s@%s\t%s\t%s' "$name" "$image" "$ctx" "$src_sha" "$digest" "$PLATFORM")")
done < <(manifest)

# Merge this run's rows into build-manifest.tsv (update rebuilt components, keep the rest).
MANIFEST="${BRIDGE_ROOT}/build/images/build-manifest.tsv"
tmp="$(mktemp)"
if [ -f "$MANIFEST" ]; then
  while IFS= read -r line; do
    case "$line" in '#'*|'component'*|'') continue;; esac
    comp="${line%%$'\t'*}"; keep=1
    for r in "${rows[@]}"; do [ "${r%%$'\t'*}" = "$comp" ] && keep=0 && break; done
    [ $keep = 1 ] && printf '%s\n' "$line" >> "$tmp"
  done < "$MANIFEST"
fi
printf '%s\n' "${rows[@]}" >> "$tmp"
{
  printf '# Build reproducibility record — rebuild: build/images/build.sh --push <components> (base images are digest-pinned).\n'
  printf 'component\timage\tsource@commit\tdigest\tplatform\n'
  sort "$tmp"
} > "$MANIFEST"
rm -f "$tmp"

echo ""
echo "Built ${#built[@]} image(s):"
printf '  %s\n' "${built[@]}"
echo "Reproducibility manifest: ${MANIFEST}"
if [ $PUSH -eq 0 ] && [ ${#built[@]} -gt 0 ]; then
  echo ""
  echo "Not pushed. To push to PRIVATE Docker Hub repos (run 'docker login' first):"
  echo "  REGISTRY=${REGISTRY} TAG=${TAG} $0 --push ${COMPONENTS[*]:-}"
fi
