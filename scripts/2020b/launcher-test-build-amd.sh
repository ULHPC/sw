#!/bin/bash -l
# Time-stamp: <Thu 2021-07-22 12:09 svarrette>
#####################################################################################################
# RESIF 3.0 Building Apps Slurm launcher - Testing Default CPU Builds against prod 2020b software set
#####################################################################################################
#
#SBATCH -J RESIF-Test-2020b-CPU
#SBATCH --dependency singleton
###SBATCH --mail-type=FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
###SBATCH --mail-user=hpc-team@uni.lu
#SBATCH --time=1-0:00:00
#SBATCH --partition=batch
#SBATCH --qos urgent
###SBATCH --exclusive
#SBATCH -C epyc
#__________________________
#SBATCH -N 1
#SBATCH --ntasks-per-node 8
#SBATCH -c 16
#__________________________
#SBATCH -o logs/%x-%j.out
mkdir -p logs

### Local variables
### Guess the run directory
# - either the script directory upon interactive jobs
# - OR the submission directory upon passive/batch jobs
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -n "${SLURM_SUBMIT_DIR}" ]; then
    [[ "${SCRIPT_DIR}" == *"slurmd"* ]] && TOP_DIR=${SLURM_SUBMIT_DIR} || TOP_DIR=$(realpath -es "${SCRIPT_DIR}/../..")
else
    TOP_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && git rev-parse --show-toplevel)"
fi
# Common functions, variables etc.
INCLUDE_DIR=$(realpath -es "${TOP_DIR}/scripts/include")
[ ! -d "${INCLUDE_DIR}" ]           && echo "Cannot find include directory: exiting" && exit 1
[ -f "${INCLUDE_DIR}/common.bash" ] && source ${INCLUDE_DIR}/common.bash
VERSION=2020b
if [ -f "${SETTINGS_DIR}/${VERSION}/aion.sh" ]; then
    source ${SETTINGS_DIR}/${VERSION}/aion.sh
fi
launcher=${TOP_DIR}/scripts/launcher-test-build-amd.sh
[ ! -f "${launcher}" ] && print_error_and_exit "Unable to find generic testing launcher '${launcher}'"

${launcher} --use ${VERSION} --env ${VERSION} $*
