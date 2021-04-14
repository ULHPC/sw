# Usage: source settings/<version>/iris.sh
#
# Example for interactive test (default: resif broadwell build)
#   ./scripts/get-interactive-job[-skylake]
#    source settings/<version>/iris.sh
#    echo $EASYBUILD_PREFIX

TOP_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && git rev-parse --show-toplevel)"

export LOCAL_RESIF_ENVIRONMENT=2019b

if [ -f "${TOP_DIR}/settings/iris.sh" ]; then
    . ${TOP_DIR}/settings/iris.sh
fi
if [[ "$(whoami)" == 'resif' ]]; then
    cat <<EOF
/!\\ WARNING
/!\\ WARNING: NEVER run test builds as resif '$(whoami)'
/!\\ WARNING
EOF
    exit 1
fi
