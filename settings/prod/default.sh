# Usage: source settings/prod/default.sh
#
# Load default settings common to ALL production release
#

export LOCAL_RESIF_ROOT_DIR=/opt/apps/resif
export EASYBUILD_CONFIGFILES=${TOP_DIR}/config/easybuild.cfg

[[ "$(whoami)" != 'resif' ]] && print_error_and_exit "NEVER run **prod** builds as $(whoami) (but as resif) and do it CAREFULLY"
