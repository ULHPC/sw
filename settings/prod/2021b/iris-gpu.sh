# Usage: source settings/prod/<version>/iris-gpu.sh
#
# Example for interactive test (default: resif broadwell build)
#   ./scripts/get-interactive-job-gpu
#    source settings/prod/<version>/iris-gpu.sh
#    echo $EASYBUILD_PREFIX

TOP_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && git rev-parse --show-toplevel)"

export LOCAL_RESIF_ARCH=gpu

if [ -f "${TOP_DIR}/settings/prod/2021b/iris.sh" ]; then
    . ${TOP_DIR}/settings/prod/2021b/iris.sh
fi
