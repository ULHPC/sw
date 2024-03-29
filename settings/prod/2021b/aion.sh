# Usage: source settings/prod/<version>/aion.sh
#
# Example for interactive test
#   ./scripts/get-interactive-job
#    source settings/prod/<version>/aion.sh
#    echo $EASYBUILD_PREFIX

TOP_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && git rev-parse --show-toplevel)"

export LOCAL_RESIF_ENVIRONMENT=2021b

if [ -f "${TOP_DIR}/settings/prod/aion.sh" ]; then
    . ${TOP_DIR}/settings/prod/aion.sh
fi
