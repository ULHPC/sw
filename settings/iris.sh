# Usage: source settings/iris.sh
#

TOP_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && git rev-parse --show-toplevel)"

export LOCAL_RESIF_SYSTEM_NAME=${LOCAL_RESIF_SYSTEM_NAME:=iris}
export LOCAL_RESIF_ROOT_DIR=${LOCAL_RESIF_ROOT_DIR:=/work/projects/sw/resif}

# Detect AVX512 cabability proper to skylake processors
[ -f /proc/cpuinfo ]  && AVX512=$(cat /proc/cpuinfo | grep flags | head -n1 | grep avx512)
[ -n "${AVX512}" ] && DEFAULT_ARCH=skylake || DEFAULT_ARCH=broadwell
export LOCAL_RESIF_ARCH=${LOCAL_RESIF_ARCH:=${DEFAULT_ARCH}}    # Or, Rely on GLOBAL RESIF_ARCH ?

if [ -f "${TOP_DIR}/settings/default.sh" ]; then
    . ${TOP_DIR}/settings/default.sh
fi

# export PYENV_ROOT="$HOME/git/github.com/pyenv/pyenv"
# if [ -f "${PYENV_ROOT}/bin/pyenv" ]; then
#    export PATH="$PYENV_ROOT/bin:$PATH"
#    if [ -n "$(which pyenv)" ]; then
#        eval "$(pyenv init -)"
#        eval "$(pyenv virtualenv-init -)"
#    fi
#    pyenv activate $(head .python-virtualenv)
# fi

# Now you don't need pyenv any more on iris/aion as python3 is natively provided on access and compute nodes.
if [ -z "${VIRTUAL_ENV}" ] && [ -d "$HOME/venv/resif3" ]; then
    echo "=> activate resif3 virtual env"
    source ~/venv/resif3/bin/activate
fi

# Enable bash completion for eb
if [ -n "$(which eb 2>/dev/null)" ]; then
    source `dirname $(which eb)`/minimal_bash_completion.bash
    source `dirname $(which eb)`/optcomplete.bash
    source `dirname $(which eb)`/eb_bash_completion.bash
    complete -F _eb eb
fi

export INTEL_LICENSE_FILE="/opt/apps/licenses/intel/license.lic"
# See hooks/ulhpc.py - YAML file hosting the site licences
export LICENSES_YAML_FILE="${LOCAL_RESIF_ROOT_DIR}/licenses_keys.yaml"
