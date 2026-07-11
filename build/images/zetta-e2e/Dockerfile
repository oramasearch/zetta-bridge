# oramasearch/zetta-e2e — the Zetta end-to-end integration test runner.
#
# A tiny image carrying curl + jq + the e2e script that lives in the zetta repo
# (tests/e2e/zetta-e2e.sh). The operator's ZettaClusterE2ETest CRD runs this
# image as an in-cluster Job against a deployed OramaZettaCluster; the script
# drives the node's :4800 HTTP API and reports PASS/FAIL (non-zero exit on FAIL).
#
# Build context = the zetta submodule source (modules/zetta), so the script is
# COPY'd from the same commit the operator pins. No compile — trivial to build
# for linux/amd64 anywhere (unlike the C++ zetta-headless image).
#
# Config is passed by the operator Job as ZETTA_E2E_* env (see the script header):
#   ZETTA_E2E_BASE_URL (required), ZETTA_E2E_PEER_URLS, ZETTA_E2E_LEVELS,
#   ZETTA_E2E_TOKEN, ZETTA_E2E_DB, ZETTA_E2E_TIMEOUT/RETRIES/POLL.
FROM alpine:3.20

RUN apk add --no-cache curl jq ca-certificates

COPY tests/e2e/zetta-e2e.sh /usr/local/bin/zetta-e2e
RUN chmod +x /usr/local/bin/zetta-e2e

# The script is POSIX sh; Alpine's /bin/sh is busybox ash. It reads its config
# from the environment, so no arguments are needed.
ENTRYPOINT ["/usr/local/bin/zetta-e2e"]
