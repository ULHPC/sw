#!/bin/bash -l
# Time-stamp: <Tue 2022-04-05 09:16 svarrette>
############################################################################
# RESIF 3.0 Building Apps Slurm launcher - CPU Skylake Builds
############################################################################
#
#SBATCH -J RESIF-Test-CPU-Skylake
#SBATCH --dependency singleton
###SBATCH --mail-type=FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
###SBATCH --mail-user=hpc-team@uni.lu
#SBATCH --time=1-0:00:00
#SBATCH --partition=batch
#SBATCH --qos urgent
###SBATCH --exclusive
#SBATCH -C skylake
#__________________________
#SBATCH -N 1
#SBATCH --ntasks-per-node 4
#SBATCH -c 7
#__________________________
#SBATCH -o logs/%x-%j.out
mkdir -p logs

### Local variables
### Guess the run directory
# - either the script directory upon interactive jobs
# - OR the submission directory upon passive/batch jobs
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -n "${SLURM_SUBMIT_DIR}" ]; then
    [[ "${SCRIPT_DIR}" == *"slurmd"* ]] && TOP_DIR=${SLURM_SUBMIT_DIR} || TOP_DIR=$(realpath -es "${SCRIPT_DIR}/..")
else
    TOP_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && git rev-parse --show-toplevel)"
fi
# Common functions, variables etc.
INCLUDE_DIR=$(realpath -es "${TOP_DIR}/scripts/include")
[ ! -d "${INCLUDE_DIR}" ]           && echo "Cannot find include directory: exiting" && exit 1
[ -f "${INCLUDE_DIR}/common.bash" ] && source ${INCLUDE_DIR}/common.bash

parse_command_line $*

module purge || print_error_and_exit "Unable to find the module command"
if [ -f "${SETTINGS_DIR}/iris.sh" ]; then
    source ${SETTINGS_DIR}/iris.sh
fi
use_swset_modules ${USE_SWSET_VERSION}
module load tools/EasyBuild || print_error_and_exit "Unable to load EB module 'tools/EasyBuild'"

run_build
