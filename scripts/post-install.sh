#! /bin/bash
# Time-stamp: <Wed 2022-04-13 16:51 svarrette>
################################################################################
# post-install - post install operations (typically requiring root priviledges)
################################################################################
# cosmetics
BOLD="\033[1m"
COLOR_RESET="\033[0m"

# Local variables
TOP_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && git rev-parse --show-toplevel)"
CMD_PREFIX=echo

INSTALL_PATH=${LOCAL_RESIF_ROOT_DIR}
CLUSTER="iris aion"
TOOLCHAIN_VERSION=${RESIF_VERSION_DEVEL:=2021a}
ARCH=

# Comma-separated list of apps to consider (kept empty by default)
APPS=
SUPPORTED_APPS_LIST=ansys,singularity,stata

################################################################################
info()  { echo -e "${BOLD}$*${COLOR_RESET}"; }
error() { echo -e "${BOLD}*** ERROR *** $*${COLOR_RESET}"; }
warning() { echo -e "${BOLD}/!\\ WARNING:${COLOR_RESET} $*"; }
print_error_and_exit() { error $*; exit 1; }
usage() {
    cat <<EOF
NAME
  $(basename $0): Post-install operations to be performed with root priviledges
  after RESIF 3.0 builds (Singularity binaries mode changes, Licences correction etc.)

USAGE
  [sudo] $0 [-x] [-d /path/to/root/install/dir] [-v VERSION]  { test | prod } [<app>]

OPTIONS
  -n --dry-run:    Dry run mode (default mode)
  -a --all         Post install on **all** supported apps:
                   ${SUPPORTED_APPS_LIST}
  --arch ARCH   Specify RESIF architecture to consider (default: all)
  -c --cluster {iris,aion} Specify cluster
  -d DIR:          Set root directory where operations will be performed.
  -g --group
  -v VERSION:      Force action on swset/toolchain version VERSION (default: ${TOOLCHAIN_VERSION})
  -x --execute     Really run the commands

EXAMPLE
  Update testing directories under /work/projects/sw/resif for software set 2020b
      [sudo] $0 [-g] -v 2020b test -g    # Dry-run
      [sudo] $0 [-g] -v 2020b test -g -x

  Update production environnment under /opt/apps/resif for software set 2020b
      [sudo] $0 -v 2020b prod    [<app>]       # Dry-run
      [sudo] $0 -v 2020b prod -x [<app>]

  Correct ANSYS licences in the production environnement
      [sudo] $0 -v 2020b prod    ansys      # Dry-run
      [sudo] $0 -v 2020b prod -x ansys

  Post install Singularity (set-uid etc.) in the production environnement
      [sudo] $0 -v 2020b prod -g       # Dry-run
      [sudo] $0 -v 2020b prod -g -x

  Correct Stata licences in the production environnement
      [sudo] $0 -v 2020b prod    stata      # Dry-run
      [sudo] $0 -v 2020b prod -x stata
EOF
}

# FIXME: factorise path checks
###
# Manually ensure group-writable directory
##
post_install_testing_directory_group_writable() {
    [ -z "$1" ] && print_error_and_exit "[$FUNCNAME] missing pattern argument"
    local path=$1
    [ ! -d "${path}" ] && print_error_and_exit "Unable to find directory '${path}'"
    if [[ "${path}" =~ "/work/projects/sw/resif"* ]]; then
        info "    -> post-install group-writable on (shared) testing directory"
        ${CMD_PREFIX} find $path -type d  -exec chmod g+w {} \;
    fi
}

###
# Post install ANSYS - copy licence to $EBROOTANSYS/shared_files/licensing/ansyslmd.ini
##
post_install_ansys() {
    [ -z "$1" ] && print_error_and_exit "[$FUNCNAME] missing pattern argument"
    local path=$1
    if [ ! -d "${path}/ANSYS" ]; then
        warning "Unable to find ANSYS directory (testing '${path}/ANSYS')..."
        warning "thus **ignoring** post installation"
        return
    fi
    local licence_path='/opt/apps/licenses/ansys/ansyslmd.ini'
    if [ ! -f "${licence_path}" ]; then
        warning "Unable to find ANSYS licence (testing '${licence_path}')..."
        warning "thus **ignoring** post installation"
        return
    fi
    info "       -> Update ANSYS licence (copied from ${licence_path})"
    ${CMD_PREFIX} cp $licence_path $path/ANSYS/*/shared_files/licensing/ansyslmd.ini
}


###
# Post install singularity.
# Usage: post_install_singularity /path/to/software/install/directory/before/Singularity
##
post_install_singularity() {
    [ -z "$1" ] && print_error_and_exit "[$FUNCNAME] missing pattern argument"
    local path=$1
    if [ ! -d "${path}/Singularity" ]; then
        warning "Unable to find Singularity directory (testing '${path}/Singularity')..."
        warning "thus **ignoring** post installation"
        return
    fi
    info "    -> post-install on Singulary under ${path}/Singularity"
    ${CMD_PREFIX} chown root:root $path/Singularity/*/etc/singularity/singularity.conf
    ${CMD_PREFIX} chown root:root $path/Singularity/*/etc/singularity/capability.json
    ${CMD_PREFIX} chown root:root $path/Singularity/*/etc/singularity/ecl.toml
    ${CMD_PREFIX} chown root:root $path/Singularity/*/libexec/singularity/bin/*-suid
    ${CMD_PREFIX} chmod 4755 $path/Singularity/*/libexec/singularity/bin/*-suid
    ${CMD_PREFIX} chmod +s $path/Singularity/*/libexec/singularity/bin/*-suid
}


###
# Manually link Stata licence file to Stata installation path
##
post_install_stata() {
    [ -z "$1" ] && print_error_and_exit "[$FUNCNAME] missing pattern argument"
    local path=$1
    [ ! -d "${path}" ] && print_error_and_exit "Unable to find directory '${path}'"
    if [ ! -d "${path}/Stata/17" ]; then
        warning "Unable to find Stata directory (testing '${path}/Stata/17')..."
        warning "thus **ignoring** post installation"
        return
    fi
    local licence_path="/opt/apps/licenses/stata/stata.lic"
    if [ ! -f "${licence_path}" ]; then
        warning "Unable to find Stata licence (testing '${licence_path}')..."
        warning "thus **ignoring** post installation"
        return
    fi
    info "       -> Update Stata licence (symlink to ${licence_path})"
    ${CMD_PREFIX} ln --symbolic $licence_path $path/Stata/17/stata.lic
}

################################################################################
# Check for options
while [ $# -ge 1 ]; do
    case $1 in
        -h | --help) usage; exit 0;;
        -n | --noop | --dry-run) CMD_PREFIX=echo;;
        -a | --all) APPS=${SUPPORTED_APPS_LIST};;
        --arch)         shift; ARCH=$1;;
        -c | --cluster) shift; CLUSTER=$1;;
        -d | --dir)     shift; INSTALL_DIR=$1;;
        -g | --group)   CORRECT_GROUP_RIGHTS=$1;;
        -v | --version | 20*) shift; TOOLCHAIN_VERSION=$1;;
        -x | --execute) CMD_PREFIX=;;
        local) INSTALL_DIR=${TOP_DIR}/local;;
        home)  INSTALL_DIR=$HOME/.local/easybuild;;
        test*) info "Post installation on (shared) testing builds"; INSTALL_DIR=/work/projects/sw/resif;;
        prod*) info "Post installation on **production** builds";   INSTALL_DIR=/opt/apps/resif;;
        # Apps Scope to consider
        *) APPS="$*"; break;;
    esac
    shift
done
[ $UID -gt 0 ] && print_error_and_exit "You must be root to execute this script (current uid: $UID)"

#_________ debug _______
cat << EOF
CLUSTER=${CLUSTER}
TOOLCHAIN_VERSION=${TOOLCHAIN_VERSION}
INSTALL_DIR=${INSTALL_DIR}
APPS=${APPS}
EOF

#________________________ Let's go
[ -z "${INSTALL_DIR}"   ] && print_error_and_exit "You MUST define the root installation directory where to operate"
[ ! -d "${INSTALL_DIR}" ] && print_error_and_exit "Root installation directory '${INSTALL_DIR}' does NOT exists"

case ${ARCH} in
    broad*|sky*|gpu) CLUSTER=iris;;
    epyc)            CLUSTER=aion;;
esac

for c in $(echo ${CLUSTER} | tr ',' ' '); do
    info "========================================"
    # cluster...
    find ${INSTALL_DIR}/${c}/20* -type d -prune | while read -r d; do
        v=$(basename $d)
        [ -n "${TOOLCHAIN_VERSION}" ] && [ "${v}" != "${TOOLCHAIN_VERSION}" ] && continue
        info "=> cluster '${c}' over release '${v}'"
        echo "   $d"
        # ... arch
        find ${d}/* -type d -prune | while read -r root_path; do
            a=$(basename $root_path)
            [ -n "${ARCH}" ] && [ "${a}" != "${ARCH}" ] && continue
            info "   ... arch: ${a}"
            [ -n "${CORRECT_GROUP_RIGHTS}" ] && post_install_testing_directory_group_writable "${root_path}"

            software_dir=${root_path}/software
            modules_dir=${root_path}/modules
            if [ ! -d "${software_dir}" ]; then
                warning "Unable to find software directory '${software_dir}'"
                continue
            fi
            for app in $(echo ${APPS} | tr ',' ' '); do
                case "${app}" in
                    ansys)       post_install_ansys       "${software_dir}";;
                    stata)       post_install_stata       "${software_dir}";;
                    singularity) post_install_singularity "${software_dir}" ;;
                    *) warning "non-supported app for post-install: '${app}'";;
                esac
            done
        done
    done
done
