# Usage: source settings/iris-gpu.sh
#

TOP_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && git rev-parse --show-toplevel)"

export LOCAL_RESIF_ARCH=gpu

if [ -f "${TOP_DIR}/settings/iris.sh" ]; then
    . ${TOP_DIR}/settings/iris.sh
fi

# Allow also CPU builds from skylake
# module use $(echo $EASYBUILD_PREFIX | sed 's/gpu/skylake/')
