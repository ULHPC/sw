#!/bin/bash -l
# Time-stamp: <Wed 2021-04-14 17:29 svarrette>
##############################################################################################
# Easyconfigs Pull-request management - Rebuild from PR and Upload test report from CPU build
##############################################################################################
#SBATCH -J RebuildFromPR-TestReport
###SBATCH --dependency singleton
#SBATCH --time=4:00:00
#SBATCH --partition=batch
#SBATCH --exclusive
#__________________________
#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH -c 28
#__________________________
#SBATCH -o logs/%x-%j.out
mkdir -p logs

### Guess the run directory
# - either the script directory upon interactive jobs
# - OR the submission directory upon passive/batch jobs
# - OR use git root directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -n "${SLURM_SUBMIT_DIR}" ]; then
    [[ "${SCRIPT_DIR}" == *"slurmd"* ]] && TOP_DIR=${SLURM_SUBMIT_DIR} || TOP_DIR=$(realpath -es "${SCRIPT_DIR}/..")
else
    TOP_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && git rev-parse --show-toplevel)"
fi
SETTINGS_DIR=$(realpath -es "${TOP_DIR}/settings")

### Local variables
CMD_PREFIX=
PR=

################################################################################
print_error_and_exit() { echo "*** ERROR *** $*"; exit 1; }
usage() {
    cat <<EOF
NAME
  $(basename $0) -- Easyconfigs Pull-request management
           Rebuild from PR and Upload test report
USAGE
  [sbatch] [-C broadwell | skylake] $0 <PR-ID>
  # Example: $0 10294

  To do it manually in an interactive job:
    si -N 1 --ntasks-per-node 1 -c 28
    source settings/iris.sh
    eb --from-pr <PR-ID> --rebuild --upload-test-report
EOF
}

################################################################################
# Check for options
while [ $# -ge 1 ]; do
    case $1 in
        -h | --help) usage; exit 0;;
        -n | --noop | --dry-run) CMD_PREFIX=echo;;
        *) PR=$1;;
    esac
    shift
done
[ ! -d "${SETTINGS_DIR}" ] && print_error_and_exit "Cannot find settings directory"
[ -z "${PR}" ]             && print_error_and_exit "Usage: $0 <PR-ID>"
[[ $PR != ?(-)+([0-9]) ]]  && print_error_and_exit "Pull-request ID should be a number"

module purge || print_error_and_exit "Unable to find the module command"
if [ -f "${SETTINGS_DIR}/iris.sh" ]; then
    . ${SETTINGS_DIR}/iris.sh
fi

cat <<EOF
====================================================================================
=> Rebuild from PR #'${PR}' and uploading the test report
====================================================================================
### Starting timestamp (s): $(date +%s)
EOF
# Debug
scontrol show job $SLURM_JOBID;

${CMD_PREFIX} sg sw -c "eb --from-pr ${PR} --rebuild --upload-test-report"

echo "### Ending timestamp (s): $(date +%s)"
