# Usage: source settings/<version>/aion.sh
#
# Example for interactive test
#   ./scripts/get-interactive-job
#    source settings/<version>/aion.sh
#    echo $EASYBUILD_PREFIX

TOP_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && git rev-parse --show-toplevel)"

export LOCAL_RESIF_ENVIRONMENT=2021b

if [ -f "${TOP_DIR}/settings/aion.sh" ]; then
    . ${TOP_DIR}/settings/aion.sh
fi
if [[ "$(whoami)" == 'resif' ]]; then
    cat <<EOF
/!\\ WARNING
/!\\ WARNING: NEVER run test builds as resif '$(whoami)'
/!\\ WARNING
EOF
    exit 1
fi
