# Usage: source settings/prod/iris.sh
#
# Example for interactive test
#   ./scripts/get-interactive-job[-skylake]
#    source settings/prod/iris.sh
#    echo $EASYBUILD_PREFIX

TOP_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && git rev-parse --show-toplevel)"

export LOCAL_RESIF_SYSTEM_NAME=iris

if [ -f "${TOP_DIR}/settings/prod/default.sh" ]; then
    . ${TOP_DIR}/settings/prod/default.sh
fi

if [ -f "${TOP_DIR}/settings/iris.sh" ]; then
    . ${TOP_DIR}/settings/iris.sh
fi
