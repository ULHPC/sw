# Usage: source settings/default.sh
#
if [ -f '/sys/devices/cpu/caps/pmu_name' ]; then
    export SYS_ARCH=$(cat /sys/devices/cpu/caps/pmu_name)
else
    export SYS_ARCH=$(uname -m)
fi

function check_module_cmd() {
    if ! c=$(command -v module); then
        echo "'module' command not found -- exiting"
        return 0
    fi
}

if [ -n "$(git rev-parse --show-toplevel 2>/dev/null)" ]; then
    TOP_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && git rev-parse --show-toplevel)"
else
    TOP_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd)"
fi

# RESIF Environment
export LOCAL_RESIF_ENVIRONMENT=${LOCAL_RESIF_ENVIRONMENT:=local}
export LOCAL_RESIF_SYSTEM_NAME=${LOCAL_RESIF_SYSTEM_NAME:=}
export LOCAL_RESIF_ARCH=${LOCAL_RESIF_ARCH:=}
export LOCAL_RESIF_ROOT_DIR=${LOCAL_RESIF_ROOT_DIR:=${TOP_DIR}/apps}

# Easybuild stuff:

# EASYBUILD_PREFIX: ${LOCAL_RESIF_ROOT_DIR}/<cluster>/<environment>/<arch>
_EB_PREFIX="${LOCAL_RESIF_ROOT_DIR}"
[ -n "${LOCAL_RESIF_SYSTEM_NAME}" ] && _EB_PREFIX="${_EB_PREFIX}/${LOCAL_RESIF_SYSTEM_NAME}"
_EB_PREFIX="${_EB_PREFIX}/${LOCAL_RESIF_ENVIRONMENT}"
[ -n "${LOCAL_RESIF_ARCH}" ]        && _EB_PREFIX="${_EB_PREFIX}/${LOCAL_RESIF_ARCH}"
export EASYBUILD_PREFIX="${_EB_PREFIX}"
export EASYBUILD_MODULES_TOOL=${EASYBUILD_MODULES_TOOL:=Lmod}
export EASYBUILD_MODULE_NAMING_SCHEME=CategorizedModuleNamingScheme
# Set path to custom easyconfig files, order is important, and trailing ':' is key
# See https://easybuild.readthedocs.io/en/latest/Using_the_EasyBuild_command_line.html#robot-search-path-prepend-append
export EASYBUILD_ROBOT_PATHS=${TOP_DIR}/easyconfigs:${DEFAULT_ROBOT_PATHS}:${HOME}/git/github.com/ULHPC/easybuild-easyconfigs/easybuild/easyconfigs
unset  EASYBUILD_ROBOT
_EB_SOURCEPATH="${LOCAL_RESIF_ROOT_DIR}/sources:${EASYBUILD_PREFIX}/sources:${TOP_DIR}/sources"
if [ -d /opt/apps/sources ]; then
    [[ "$(whoami)" == 'resif' ]] && _EB_SOURCEPATH=/opt/apps/sources:${_EB_SOURCEPATH} || _EB_SOURCEPATH=${_EB_SOURCEPATH}:/opt/apps/sources
fi
export EASYBUILD_SOURCEPATH=${_EB_SOURCEPATH}
export EASYBUILD_CONFIGFILES=${EASYBUILD_CONFIGFILES:=${TOP_DIR}/config/easybuild.cfg}
case "$LOCAL_RESIF_ROOT_DIR" in
    # Specific config allowing for group writable and set-gid bit
    *projects/sw/*) export EASYBUILD_CONFIGFILES=${TOP_DIR}/config/easybuild-shared-project-builds.cfg
esac

export EASYBUILD_TMP_LOGDIR=${TOP_DIR}/logs/easybuild

export EASYBUILD_HOOKS=${TOP_DIR}/hooks/ulhpc.py


# Make EB output appear immediately
export PYTHONUNBUFFERED=1

# Github integration
export EASYBUILD_GITHUB_USER=ULHPC
export EASYBUILD_GIT_WORKING_DIRS_PATH=$HOME/git/github.com/ULHPC

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    RAMdisk=/dev/shm
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    RAMdisk=/Volumes/shm
fi
[ -d "${RAMdisk}" ] && export EASYBUILD_BUILDPATH=$RAMdisk


# Modules
export LOCAL_MODULES=${EASYBUILD_PREFIX}/modules/all

# LMod specific on Mac
if [[ "$(uname)" == 'Darwin' ]]; then
    # Check if Lmod is installed
    if lmod_prefix=$(brew --prefix lmod 2> /dev/null); then
        source ${lmod_prefix}/init/profile
    else
        echo "/!\\ LMod is not found/installed -- consider running 'brew install lmod'"
    fi
    export MODULEPATH=${LOCAL_MODULES}
fi
check_module_cmd

# Useful aliases / commands
alias ma="module avail"
function ml() {
    for m in $*; do
        echo "=> loading module $m"
        module load $m
    done
    module list
}
function mu(){
   module use $LOCAL_MODULES
   module load tools/EasyBuild
}

# Load easybuild
export MODULEPATH=${LOCAL_MODULES}

# EB bash completion
# source ${EBROOTEASYBUILD}/bin/minimal_bash_completion.bash
# source ${EBROOTEASYBUILD}/bin/optcomplete.bash
# source ${EBROOTEASYBUILD}/bin/eb_bash_completion.bash
# complete -F _eb eb

# Local customization that may override all defaults
for f in $(find ${TOP_DIR}/settings/custom/  -name '*.sh' -print); do
    echo "=> loading custom settings 'settings/custom/$(basename ${f})'"
    [ -f "${f}" ] && source "$f"
done
# Debug time...
if [ -n "${DEBUG}" ]; then
    cat <<EOF
TOP_DIR           = ${TOP_DIR}
----------------------------------------
LOCAL_RESIF_ENVIRONMENT = ${LOCAL_RESIF_ENVIRONMENT}
LOCAL_RESIF_SYSTEM_NAME = ${LOCAL_RESIF_SYSTEM_NAME}
SYS_ARCH                = ${SYS_ARCH}
LOCAL_RESIF_ARCH        = ${LOCAL_RESIF_ARCH}
LOCAL_RESIF_ROOT_DIR    = ${LOCAL_RESIF_ROOT_DIR}
----------------------------------------
EASYBUILD_PREFIX               = ${EASYBUILD_PREFIX}
EASYBUILD_MODULES_TOOL         = ${EASYBUILD_MODULES_TOOL}
EASYBUILD_MODULE_NAMING_SCHEME = ${EASYBUILD_MODULE_NAMING_SCHEME}
EASYBUILD_ROBOT_PATHS          = ${EASYBUILD_ROBOT_PATHS}
EASYBUILD_BUILDPATH            = ${EASYBUILD_BUILDPATH}
EASYBUILD_SOURCEPATH           = ${EASYBUILD_SOURCEPATH}
EASYBUILD_CONFIGFILES          = ${EASYBUILD_CONFIGFILES}
EASYBUILD_TMP_LOGDIR           = ${EASYBUILD_TMP_LOGDIR}
----------------------------------------
LOCAL_MODULES     = ${LOCAL_MODULES}
MODULEPATH        = ${MODULEPATH}
EOF
#    sleep 1
#    eb --show-config
fi

module load tools/EasyBuild 2>/dev/null && eb --show-config || echo "/!\ WARNING: Module tools/EasyBuild NOT FOUND "
