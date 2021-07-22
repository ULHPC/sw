# Time-stamp: <Thu 2021-04-08 11:12 svarrette>
################################################################################
# Common RESIF 3.0 functions
#
# Usage:
#   TOP_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && git rev-parse --show-toplevel)"
#   source ${TOP_DIR}/scripts/includes/common.bash

SETTINGS_DIR=$(realpath -es "${TOP_DIR}/settings")
ULHPC_EASYCONFIGS_DIR=$(realpath -es "${TOP_DIR}/easyconfigs/u/")
case ${LOCAL_RESIF_ENVIRONMENT} in
    20*) VERSION=${LOCAL_RESIF_ENVIRONMENT};;
    *)   VERSION=;;
esac
ULHPC_MODULE_BUNDLES="toolchains $(ls -d ${ULHPC_EASYCONFIGS_DIR}/ULHPC-* | grep -v -E 'toolchains|gpu' | cut -d '-' -f 2 | xargs echo)"
CMD_PREFIX=
DRY_RUN_SHORT=
USE_SWSET_VERSION=

################################################################################
print_error_and_exit() { echo "*** ERROR *** $*"; exit 1; }
usage() {
    local help_for_prod_script=$1
    case "$(basename $0)$LOCAL_RESIF_ARCH" in
        *skylake*) usage_desc="Skylake-optimized CPU Builds";;
        *gpu*)
            ULHPC_MODULE_BUNDLES="$(ls -d ${ULHPC_EASYCONFIGS_DIR}/ULHPC-gpu* | sed 's/.*ULHPC-//' | xargs echo)";
            usage_desc="GPU Accelerated Software Builds with {foss,intel}cuda/PGI toolchains";;
        *)       usage_desc="Default CPU Builds compliant with all Intel archictectures in place";;
    esac
    cat <<EOF
NAME
  $(basename $0): RESIF 3.0 launcher for ULHPC User Software building
          Based on UL HPC Module Bundles ULHPC-[<topic>-]<version>.eb
          ${usage_desc}
EOF
    if [ -n "${help_for_prod_script}" ]; then
        cat <<EOF
          **Production** build to be launched as 'resif' user for a given release
USAGE
  [sbatch] $0 -v <version> [-n] [-D] [ ${ULHPC_MODULE_BUNDLES// / | } ]
  [sbatch] $0 -v <version> [-n] [-D] path/to/file.eb
EOF
    else
        cat <<EOF
USAGE
  [sbatch] $0 [-n] [-D] [ ${ULHPC_MODULE_BUNDLES// / | } ]
  [sbatch] $0 [-n] [-D] path/to/file.eb

  Default bundle version: ${VERSION} - see easyconfigs/u/ULHPC-*
EOF
    fi
    cat <<EOF
  List of ULHPC Module Bundles: ${ULHPC_MODULE_BUNDLES}

OPTIONS:
  -d --debug:   Debug mode
  -n --dry-run: Dry run mode
  -D --dry-run-short Print build overview incl. dependencies but do not build
EOF
    [ -z "${help_for_prod_script}" ] && \
        cat <<EOF
  -e  <ENV>:    Set **local** RESIF environment to <ENV> (Default: ${LOCAL_RESIF_ENVIRONMENT})"
  -u --use <version>: use the modules from the *prod* environment <version>
EOF
    cat <<EOF
  -v <version>: Set Bundle version (default: '${VERSION}')

EOF
}
print_debug_info(){
    cat <<EOF
------------ Directories -----------
TOP_DIR      = ${TOP_DIR}
SCRIPT_DIR   = ${SCRIPT_DIR}
INCLUDE_DIR  = ${INCLUDE_DIR}
SETTINGS_DIR = ${SETTINGS_DIR}
------------ Slurm  -----------
$([ -n "${SLURM_JOBID}" ] && scontrol show job ${SLURM_JOBID})
--------------- RESIF/EasyBuild ---------------
LOCAL_RESIF_ENVIRONMENT=${LOCAL_RESIF_ENVIRONMENT}
ULHPC_EASYCONFIGS_DIR = ${ULHPC_EASYCONFIGS_DIR}
ULHPC Modules Bundles (version ${VERSION}) list:
   - ${ULHPC_MODULE_BUNDLES}
EBFILE = ${EBFILE}

$(eb --version)
$(eb --show-config)
EOF
}

parse_command_line()
{
    while [ "$1" != "" ]; do
        case $1 in
            -h | --help)  usage; exit 0;;
            -d | --debug) DEBUG=$1;;
            -D | --dry-run-short)    DRY_RUN_SHORT=$1;;
            -e | --env*)  shift; export LOCAL_RESIF_ENVIRONMENT=$1;;
            -i | --info)  print_debug_info; eb --show-config; exit 0;;
            -n | --noop | --dry-run) CMD_PREFIX=echo;;
            -u | --use) shift;       USE_SWSET_VERSION=$1;;
            -v | --version) shift;   VERSION=$1;;
            -x | --execute) CMD_PREFIX=;;
            toolchains | bio | bd | cs | dl | math | perf | tools | visu)
                [ "${LOCAL_RESIF_ARCH}" != "gpu" ] && ULHPC_MODULE_BUNDLES=$1;;
            gpu)
                [ "${LOCAL_RESIF_ARCH}" == "gpu" ] && ULHPC_MODULE_BUNDLES=$1;;
            *.eb)
                ULHPC_MODULE_BUNDLES=''; EBFILE=$1;;
            *) OPTS=$*; break;;
        esac
        shift
    done
    [[ "$(whoami)" == 'resif' ]] && \
        print_error_and_exit "You should not use this script as 'resif' user meant for **prod** builds (under scripts/prod/)"

}

parse_command_line_prod()
{
    while [ "$1" != "" ]; do
        case $1 in
            -h | --help)  usage 'prod_build'; exit 0;;
            -d | --debug) DEBUG=$1;;
            -D | --dry-run-short)    DRY_RUN_SHORT=$1;;
            -i | --info)  print_debug_info; eb --show-config; exit 0;;
            -n | --noop | --dry-run) CMD_PREFIX=echo;;
            -v | --version) shift;   VERSION=$1;;
            -x | --execute) CMD_PREFIX=;;
            toolchains | bio | bd | cs | dl | math | perf | tools | visu)
                [ "${LOCAL_RESIF_ARCH}" != "gpu" ] && ULHPC_MODULE_BUNDLES=$1;;
            gpu)
                [ "${LOCAL_RESIF_ARCH}" == "gpu" ] && ULHPC_MODULE_BUNDLES=$1;;
            *.eb)
                ULHPC_MODULE_BUNDLES=''; EBFILE=$1;;
            *) OPTS=$*; break;;
        esac
        shift
    done
    # Safeguards productions builds
    [[ "$(whoami)" != 'resif' ]] && \
        print_error_and_exit "NEVER run **prod** builds as '$(whoami)' (but as resif) and do it CAREFULLY"
}



# ###
# # load_settings <name>
# ##
# load_settings() {
#     local f=${1:=iris.sh}
#     [ ! -d "${SETTINGS_DIR}" ] && print_error_and_exit "Cannot find settings directory"
#     module purge || print_error_and_exit "Unable to find the module command"
#     if [ -f "${SETTINGS_DIR}/${f}" ]; then
#         echo "=> loading/sourcing ${f} setting"
#         source ${SETTINGS_DIR}/${f}
#     fi
# }

###
# module use from given version of software set released
# Usage: use_swset_modules <version>
##
use_swset_modules()
{
    local version=${1:=${USE_SWSET_VERSION}}
    local global_eb_prefix=/opt/apps/resif/${ULHPC_CLUSTER:=iris}/${version}

    if [ -n "${version}" ]; then
        echo "==> using/prepend (production) modules from '${version}' release for resif arch '${LOCAL_RESIF_ARCH}'"
        _MODULEPATH="${global_eb_prefix}/${LOCAL_RESIF_ARCH}/modules/all"
        if [ "${LOCAL_RESIF_ARCH}" == 'gpu' ]; then
            echo "    -  using also (production) CPU modules from '${version}' release for skylake"
            _MODULEPATH="${_MODULEPATH}:${global_eb_prefix}/skylake/modules/all"
        fi
        export MODULEPATH=${_MODULEPATH}:${MODULEPATH}
        echo "Updated  MODULEPATH=${MODULEPATH}"
    fi
}

run_build() {
    #print_debug_info
    if [ -z "${EBFILE}" ]; then
        LABEL="ULHPC Bundle modules (version ${VERSION}) for environment ${RESIF_ENVIRONMENT}"
    else
        LABEL="${EBFILE}"
    fi
    [ -n "${DRY_RUN_SHORT}" ] && action="Checking dependencies for" || action="Building"
    cat <<EOF
====================================================================================
=> ${action} ${LABEL}
====================================================================================
### Starting timestamp (s): $(date +%s)
EOF

    [ -n "${DEBUG}" ] && print_debug_info || { [ -n "${SLURM_JOBID}" ] && scontrol show job $SLURM_JOBID; }

    if [ -n "${ULHPC_MODULE_BUNDLES}" ]; then
        for t in ${ULHPC_MODULE_BUNDLES}; do
            f="ULHPC-${t}-${VERSION}.eb"
            cat <<EOF
======== Building ULHPC ${t} Module Bundle '${f}' =======
=> checking dependencies
EOF
            ${CMD_PREFIX} eb ${f} ${OPTS} -r --rebuild -D || print_error_and_exit "Command 'eb ${EBFILE} -Dr' failed"
            if [ -z "${DRY_RUN_SHORT}" ]; then
                echo "=> [Re]building $(basename $f)"
                case $LOCAL_RESIF_ROOT_DIR in
                    *projects/sw/*) ${CMD_PREFIX} sg sw -c "eb ${f} ${OPTS} -r --rebuild";;   # Enforce using the 'sw' group
                    *)              ${CMD_PREFIX} eb ${f} ${OPTS} -r --rebuild;;
                esac
            fi
        done
    fi
    if [ -n "${EBFILE}" ]; then
        ${CMD_PREFIX} eb ${EBFILE} ${OPTS} -r --rebuild -D || print_error_and_exit "Command 'eb ${EBFILE} -Dr' failed"
        if [ -z "${DRY_RUN_SHORT}" ]; then
            case $LOCAL_RESIF_ROOT_DIR in
                *projects/sw/*) ${CMD_PREFIX} sg sw -c "eb ${EBFILE} ${OPTS} -r --rebuild";;   # Enforce using the 'sw' group
                *)              ${CMD_PREFIX} eb ${EBFILE} ${OPTS} -r --rebuild;;
            esac
        fi
    fi

    echo "### Ending timestamp (s): $(date +%s)"
}
