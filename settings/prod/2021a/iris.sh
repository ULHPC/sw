# Usage: source settings/prod/<version>/iris.sh
#
# Example for interactive test (default: resif broadwell build)
#   ./scripts/get-interactive-job[-skylake]
#    source settings/prod/<version>/iris.sh
#    echo $EASYBUILD_PREFIX

TOP_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && git rev-parse --show-toplevel)"

export LOCAL_RESIF_ENVIRONMENT=2021a

if [ -f "${TOP_DIR}/settings/prod/iris.sh" ]; then
    . ${TOP_DIR}/settings/prod/iris.sh
fi
