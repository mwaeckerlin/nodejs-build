#!/usr/bin/env bash
# Build contract: the build image builds Node.js applications, the way the
# README shows it.
#
# `node` and `npm` run as the build user; and the compiled way of the README
# works end to end: a child image compiles a script with nexe against the
# Node.js the image prepared, the result runs on the mwaeckerlin/nodejs runtime
# base with the binary as its entrypoint.
#
# Usage: tests/build-contract.sh IMAGE

set -uo pipefail

IMAGE="${1:?usage: tests/build-contract.sh IMAGE}"
CHILD="${IMAGE%%:*}-build-contract-child"
CONTEXT=$(mktemp -d)
trap 'rm -rf "${CONTEXT}"; docker image rm -f "${CHILD}" > /dev/null 2>&1' EXIT

PASS=0
FAIL=0
declare -a FAILED_NAMES

_pass() { PASS=$((PASS + 1)); echo "  PASS  $1"; }
_fail() { FAIL=$((FAIL + 1)); FAILED_NAMES+=("$1"); echo "  FAIL  $1: $2"; }

echo "==> Build contract: Node.js build image"

if ! docker image inspect "${IMAGE}" > /dev/null 2>&1; then
    _fail "${IMAGE}_image_exists" "image not built — run 'npm run build' first"
else
    for tool in node npm nexe; do
        if docker run --rm --pull=never "${IMAGE}" sh -c "command -v ${tool}" > /dev/null 2>&1; then
            _pass "tool_${tool}"
        else
            _fail "tool_${tool}" "not installed"
        fi
    done

    printf 'console.log("compiled " + (6 * 7))\n' > "${CONTEXT}/main.js"
    cat > "${CONTEXT}/Dockerfile" <<EOF
FROM ${IMAGE} AS build
ADD --chown=\${BUILD_USER} main.js main.js
RUN nexe --build --python=\$(which python3) -o app main.js

FROM mwaeckerlin/nodejs AS production
COPY --from=build /app/app /app/app
ENTRYPOINT ["/app/app"]
CMD []
EOF
    if BUILD=$(docker build --quiet -t "${CHILD}" "${CONTEXT}" 2>&1); then
        OUT=$(docker run --rm --pull=never "${CHILD}" 2>&1)
        if [[ "${OUT}" == "compiled 42" ]]; then
            _pass "compiled_app_runs_on_runtime_base"
        else
            _fail "compiled_app_runs_on_runtime_base" "${OUT}"
        fi
    else
        _fail "compiled_app_runs_on_runtime_base" "child image does not build: ${BUILD}"
    fi
fi

echo ""
echo "==> Build contract results: ${PASS} passed, ${FAIL} failed"
if [[ ${FAIL} -gt 0 ]]; then
    echo "==> Failed contracts: ${FAILED_NAMES[*]}"
    exit 1
fi
