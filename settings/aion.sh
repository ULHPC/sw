# Usage: source settings/aion.sh
#

TOP_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && git rev-parse --show-toplevel)"

export LOCAL_RESIF_SYSTEM_NAME=${LOCAL_RESIF_SYSTEM_NAME:=aion}
export LOCAL_RESIF_ROOT_DIR=${LOCAL_RESIF_ROOT_DIR:=/work/projects/sw/resif}
export LOCAL_RESIF_ARCH=${LOCAL_RESIF_ARCH:=epyc}    # Or, Rely on GLOBAL RESIF_ARCH ?

if [ -f "${TOP_DIR}/settings/default.sh" ]; then
    . ${TOP_DIR}/settings/default.sh
fi

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
