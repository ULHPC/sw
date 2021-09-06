# Usage: source settings/prod/aion.sh
#
# Example for interactive test
#   ./scripts/get-interactive-job
#    source settings/prod/aion.sh
#    echo $EASYBUILD_PREFIX

TOP_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && git rev-parse --show-toplevel)"

export LOCAL_RESIF_SYSTEM_NAME=aion

if [ -f "${TOP_DIR}/settings/prod/default.sh" ]; then
    . ${TOP_DIR}/settings/prod/default.sh
fi

if [ -f "${TOP_DIR}/settings/${LOCAL_RESIF_SYSTEM_NAME}.sh" ]; then
    . ${TOP_DIR}/settings/${LOCAL_RESIF_SYSTEM_NAME}.sh
fi
