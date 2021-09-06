# Usage: source settings/<version>/iris-gpu.sh
#
# Example for interactive test (default: resif broadwell build)
#   ./scripts/get-interactive-job-gpu
#    source settings/<version>/iris-gpu.sh
#    echo $EASYBUILD_PREFIX

TOP_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && git rev-parse --show-toplevel)"

export LOCAL_RESIF_ARCH=gpu

if [ -f "${TOP_DIR}/settings/2021a/iris.sh" ]; then
    . ${TOP_DIR}/settings/2021a/iris.sh
fi
