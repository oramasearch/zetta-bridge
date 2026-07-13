# oramasearch/zetta-e2e — the live-cluster Zetta e2e suite baked as the image ENTRYPOINT.
#
# The suite (modules/zetta/tests/e2e/zetta-e2e.sh, in the zetta repo) drives a DEPLOYED
# node over its HTTP API (:4800) — it builds/links nothing, so this is a tiny alpine +
# curl + jq runner. Triggered by the operator's ZettaClusterE2ETest CRD, which runs the
# image's ENTRYPOINT and passes the addressing/levels/token as ZETTA_E2E_* env.
#
# The script evolves with the engine (a capability rename or a new assertion means a
# rebuild) — coverage changes touch three repos: zetta (script) -> zetta-bridge (this
# image) -> operator (CRD). Build from the zetta submodule as context:
#   docker build -t oramasearch/zetta-e2e:v1-sandbox \
#     -f build/images/zetta-e2e/Dockerfile modules/zetta
FROM alpine:3.20
RUN apk add --no-cache curl jq
COPY tests/e2e/zetta-e2e.sh /usr/local/bin/zetta-e2e
RUN chmod +x /usr/local/bin/zetta-e2e
ENTRYPOINT ["/usr/local/bin/zetta-e2e"]
