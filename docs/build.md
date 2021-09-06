# User Software builds

Slurm launchers are provided under `scripts/`  to facilitate software builds.
For convenience, a GNU screen configuration file `config/screenrc` is provided to quickly bootstrap the appropriate tabs:

```bash
screen -c config/screenrc
# 'SW' tab meant for git / sync operations. To enable the ssh agent:
#    eval "$(ssh-agent)"
#    ssh-add ~/.ssh/id_rsa
#    make up
#    make fork-easyconfigs-update
# 'broadwell' tab for associated build. Ex interactive job:
#    ./scripts/get-interactive-job
# 'skylake' tab for associated build. Ex interactive job:
#    ./scripts/get-interactive-job-skylake
# 'gpu' tab for associated build. Ex interactive job:
#    ./scripts/get-interactive-job-gpu
# 'epyc' tab  for aion builds
#    ssh aion
#    ./scripts/get-interactive-job
```

Don't forget to kill your ssh agent when you have finish: `eval "$(ssh-agent -k)"`

You are encouraged to submit/run your builds in each appropriate `<arch>` tab, where you can follow the logs of a given passive build with:

```bash
tail -s1 -f logs/<JOB-NAME>-<jobid>.out   # -s1 to force refresh every second
```

In general, the following launcher scripts are provided, either for testings purposes (under project `sw`), or for production builds (as `resif` user).

| Script                                      | Cluster | Arch.     | Description              | Partition | Settings                     |
|---------------------------------------------|---------|-----------|--------------------------|-----------|------------------------------|
| `launcher-{test,prod}-build-cpu.sh`         | iris    | broadwell | Intel CPU default builds | `batch`   | `settings/[...]/iris.sh`     |
| `launcher-{test,prod}-build-cpu-skylake.sh` | iris    | skylake   | Intel CPU Skylake Builds | `batch`   | `settings/[...]/iris.sh`     |
| `launcher-{test,prod}-build-gpu.sh`         | iris    | skylake   | Nvidia GPU Builds        | `gpu`     | `settings/[...]/iris-gpu.sh` |

## Get an interactive jobs

For a given arch, you **MUST** use the script `scripts/get-interactive-job*` to get the appropriate compute node for 2h

```bash
$ ./scripts/get-interactive-job -h
  get-interactive-job:
      Get an interactive job for 'broadwell' node to test a RESIF build.
      By default, this will reserve one **full** node (i.e. 1 task over 28 threads)
USAGE
  ./scripts/get-interactive-job [-n] [-c 1]

OPTIONS:
  -n --dry-run: Dry run mode
  -c <N>: ask <N> core (thread) instead of 28 (default) -- may be scheduled faster

# Get an interactive job for default arch (broadwell on iris)
$ ./scripts/get-interactive-job
## OR, for Intel skylake
$ ./scripts/get-interactive-job-skylake
## OR, for GPU nodes:
$ ./scripts/get-interactive-job-gpu
```

## (Eventually) Install/update EB

Use the interactive jobs to install/update EB to the latest version using `scripts/setup.h` **AFTER** sourcing the appropriate settings

```bash
### Iris broadwell or Aion epyc
$ ./scripts/get-interactive-job -c1
$ source settings/[prod/]${ULHPC_CLUSTER}.sh
$ ./scripts/setup.sh -h    # check $EASYBUILD_PREFIX
$ ./scripts/setup.sh -n
$ ./scripts/setup.sh

### Iris skylake
$ ./scripts/get-interactive-job-skylake.sh -c1
$ source settings/[prod/]${ULHPC_CLUSTER}.sh
$ ./scripts/setup.sh -h    # check $EASYBUILD_PREFIX
$ ./scripts/setup.sh -n
$ ./scripts/setup.sh

### Iris GPU
$ ./scripts/get-interactive-job-gpu.sh -c1
$ source settings/[prod/]${ULHPC_CLUSTER}-gpu.sh
$ ./scripts/setup.sh -h    # check $EASYBUILD_PREFIX
$ ./scripts/setup.sh -n
$ ./scripts/setup.sh
```



## Testing Builds (project `sw`)

You can test builds under `/work/projects/sw/resif` (`$LOCAL_RESIF_ROOT_DIR`) under your ULHPC account (assuming you belong to the group `sw`) with the launcher scripts `scripts/launcher-test-build-*`.

Software and modules will be installed under the `local` software set (`$LOCAL_RESIF_ENVIRONMENT`) i.e. under `/work/projects/sw/resif/iris/local/<arch>`.
_Note:_ The build command is `sg sw -c "eb [...] -r --rebuild"` (to enforce group ownership to the `sw` project -- see [docs](https://hpc-docs.uni.lu/data/project/)).

| Mode        | Arch.       | Launcher                                       | Settings                      |
|-------------|-------------|------------------------------------------------|-------------------------------|
| Local Tests | `broadwell` | `./scripts/launcher-test-build-cpu.sh`         | `source settings/iris.sh`     |
| Local Tests | `skylake`   | `./scripts/launcher-test-build-cpu-skylake.sh` | `source settings/iris.sh`     |
| Local Tests | `gpu`       | `./scripts/launcher-test-build-gpu.sh`         | `source settings/iris-gpu.sh` |

Example of help usage:

```
$ ./scripts/launcher-test-build-cpu.sh -h
NAME
  launcher-test-build-cpu.sh: RESIF 3.0 launcher for ULHPC User Software building
          Based on UL HPC Module Bundles ULHPC-[<topic>-]<version>.eb
          Default CPU Builds compliant with all Intel archictectures in place
USAGE
  [sbatch] ./scripts/launcher-test-build-cpu.sh [-n] [-D] [ toolchains | bd | bio | cs | dl | math | perf | tools | visu ]
  [sbatch] ./scripts/launcher-test-build-cpu.sh [-n] [-D] path/to/file.eb

  Default bundle version:  - see easyconfigs/u/ULHPC-*
  List of ULHPC Module Bundles: toolchains bd bio cs dl math perf tools visu

OPTIONS:
  -d --debug:   Debug mode
  -n --dry-run: Dry run mode
  -D --dry-run-short Print build overview incl. dependencies but do not build
  -e  <ENV>:    Set **local** RESIF environment to <ENV> (Default: )"
  -u --use <version>: use the modules from the *prod* environment <version>
  -v <version>: Set Bundle version (default: '')
```

Each of these scripts supports two main usage (use `-n` for dry runs beforehand to `echo` each command instead of ececuting them):

* passing as argument a bundle name (Ex: `toolchains`, `bio`, `cs` etc.) to launch the build of the associate ULHPC bundle _i.e._ `ULHPC-<name>-<version>.eb`
* passing as argument a path to an easyconfigs you want to build
* __For interactive runs, you need to source the appropriate settings before__

These launchers are simple wrapper around the following commands:

```
source settings/iris[...].sh
eb <file>.eb -r --rebuild -D  # Dry-run, report dependencies
sg sw -c "eb <file>.eb -r --rebuild"
```

On `iris`, the commands are embeded via `sg` to force the execution within the group `sw` i.e. as follows: `sg sw -c "eb [...]"`

```bash
# Interactive tests (broadwell)
(access)$> si -C broadwell -N 1 --ntasks-per-node 1 -c 28
(node)$> source settings/iris.sh
(node)$> eb --version
(node)$> eb -S [...]
(node)$> ./scripts/launcher-test-build-cpu.sh [toolchains | bio | ...]
# Passible jobs - (default) builds for Intel (broadwell)
(access)$> sbatch ./scripts/launcher-test-build-cpu.sh [toolchains | bio | ...]
# AND/OR Skylake optimized builds
(access)$> sbatch ./scripts/launcher-test-build-cpu-skylake.sh [toolchains | bio | ...]
# AND/OR GPU optimized builds
(access)$> sbatch ./scripts/launcher-test-build-gpu.sh [gpu]
```

Slurm Logs are located under `logs/` directory -- use `tail -s1 -f logs/[...]` to follow them live when tied to a passive job running.
Easybuild-related logs are placed under `logs/easybuild/`

```bash
(access)$> tail -s1 -f logs/<jobname>-<jobid>.out   # Slurm logs, EB logs under logs/easybuild
```

You may want at some point to clean the logs:

```bash
make clean
```

### Testing build against production release

Once a given version of the ULHPC software set is released to production (Ex: 2019b), it is likely that some users may request the addition of a missing software assuming an easyconfig exists.
Instead of trying the builds directly in production, you **MUST** first test it under the `sw` project.

You may want to test a build **against** a production software set (Ex: 2019b) in which case you **MUST** use the `-v <version>` option:

```
[sbatch] ./scripts/launcher-test-build-{cpu,cpu-skylake,gpu}.sh -v 2019b [...]
```
You can also decide to target a private environment with `-e <name>` (Ex: 2019b) to ensure the builds goes into a dedicated (separated) directory, note however that **you need to install EB into this directory** (see below).

To facilitate such tests, dedicated launchers scripts have been created under `./scripts/<version>/launcher-test-build-*`

| Mode                            | Arch.       | Launcher                                                 | Settings                                |
|---------------------------------|-------------|----------------------------------------------------------|-----------------------------------------|
| Local Tests `<version>` release | `broadwell` | `./scripts/<version>/launcher-test-build-cpu.sh`         | `source settings/<version>/iris.sh`     |
| Local Tests `<version>` release | `skylake`   | `./scripts/<version>/launcher-test-build-cpu-skylake.sh` | `source settings/<version>/iris.sh`     |
| Local Tests `<version>` release | `gpu`       | `./scripts/<version>/launcher-test-build-gpu.sh`         | `source settings/<version>/iris-gpu.sh` |

Example: testing for QuantumEXPRESSO:

```
### Ex: broadwell
# SW tabs: update to latest easyconfigs and settings
$ make up    # ULHPC/sw repo
$ make fork-easyconfigs-update    # local fork of easyconfigs

### broadwell tab
$ ./scripts/get-interactive-job
$ source settings/2019b/iris.sh
# check suggested EB
$ ./scripts/suggest-easyconfigs Quantum
#[...]
# ... potential exact match for 2019b toolchain
# QuantumESPRESSO-6.5-intel-2019b.eb
# QuantumESPRESSO-6.6-foss-2019b.eb
# QuantumESPRESSO-6.6-intel-2019b.eb
# QuantumESPRESSO-6.7-foss-2019b.eb
# QuantumESPRESSO-6.7-intel-2019b.eb
# QuantumESPRESSO-6.7-iomkl-2019b.eb

# check existing (missing) dependencies **against** 2019b: use scripts/2019b/launcher-test-build*
$ ./scripts/2019b/launcher-test-build-cpu.sh -D QuantumESPRESSO-6.7-foss-2019b.eb
#[...]
# ==> using/prepend (production) modules from '2019b' release for resif arch 'broadwell'
# Updated  MODULEPATH=/opt/apps/resif/iris/2019b/broadwell/modules/all:/work/projects/sw/resif/iris/2019b/broadwell/modules/all
#
# Due to MODULEPATH changes, the following have been reloaded:
#   1) tools/EasyBuild/4.3.3
# #[...]
#  * [x] /opt/apps/resif/iris/2019b/broadwell/software/EasyBuild/4.3.3/easybuild/easyconfigs/f/foss/foss-2019b.eb (module: toolchain/foss/2019b)
#  * [ ] /opt/apps/resif/iris/2019b/broadwell/software/EasyBuild/4.3.3/easybuild/easyconfigs/e/ELPA/ELPA-2019.11.001-foss-2019b.eb (module: math/ELPA/2019.11.001-foss-2019b)
#  * [ ] /opt/apps/resif/iris/2019b/broadwell/software/EasyBuild/4.3.3/easybuild/easyconfigs/q/QuantumESPRESSO/QuantumESPRESSO-6.7-foss-2019b.eb (module: chem/QuantumESPRESSO/6.7-foss-2019b)

# Repeat to test the build
$ ./scripts/2019b/launcher-test-build-cpu.sh QuantumESPRESSO-6.7-foss-2019b.eb
```

You probably want to repeat in passive mode for `skylake`:

```bash
### skylake tabs
# adapt expected run time
$ sbatch -t 01:00:00 ./scripts/2019b/launcher-test-build-cpu-skylake.sh QuantumESPRESSO-6.7-foss-2019b.eb
```

If it builds successfully, you probably want to

1. complete and commit the appropriate ULHPC bundle: Ex: `easyconfigs/u/ULHPC-<type>/ULHPC-<type>-2019b.eb`
2. repeat the **prod** build as `resif`, after pulling use the script `./scripts/prod/launcher-prod-build-[...] -v 2019b <type>`
    - see below

### Install/Update Easybuild for a given environment

You should do it in interactive jobs by sourcing the appropriate settings and running `./script/setup.sh [-h] [-n]`

```bash
### Ex: Testing environment (project sw) against the 2019b release
# Broadwell tab
$ ./scripts/get-interactive-job -c1
$ source settings/2019b/iris.sh
----------------------------------------
LOCAL_RESIF_ENVIRONMENT = 2019b
LOCAL_RESIF_SYSTEM_NAME = iris
SYS_ARCH                = broadwell
LOCAL_RESIF_ARCH        = broadwell
LOCAL_RESIF_ROOT_DIR    = /work/projects/sw/resif
----------------------------------------
EASYBUILD_PREFIX               = /work/projects/sw/resif/iris/2019b/broadwell
[...]
/!\ WARNING: Module tools/EasyBuild NOT FOUND

# double-check $EASYBUILD_PREFIX
$ ./scripts/setup.sh -h    # check CAREFULLY EASYBUILD_PREFIX
$ ./scripts/setup.sh -n    # dry-run
$ ./scripts/setup.sh
$ exit

### /!\ IMPORTANT: repeat for each architecture: skylake and gpu
# Skylake tabs
$ ./scripts/get-interactive-job-skylake -c1
$ source settings/2019b/iris.sh
TOP_DIR           = /mnt/irisgpfs/users/svarrette/git/gitlab.uni.lu/ULHPC/sw
----------------------------------------
LOCAL_RESIF_ENVIRONMENT = 2019b
LOCAL_RESIF_SYSTEM_NAME = iris
SYS_ARCH                = skylake
LOCAL_RESIF_ARCH        = skylake
LOCAL_RESIF_ROOT_DIR    = /work/projects/sw/resif
----------------------------------------
EASYBUILD_PREFIX               = /work/projects/sw/resif/iris/2019b/skylake
[...]
/!\ WARNING: Module tools/EasyBuild NOT FOUND

# double-check $EASYBUILD_PREFIX
$ ./scripts/setup.sh -h    # check CAREFULLY EASYBUILD_PREFIX
$ ./scripts/setup.sh -n    # dry-run
$ ./scripts/setup.sh
$ exit

# GPU tab
$ ./scripts/get-interactive-job-gpu -c1
$ source settings/2019b/iris-gpu.sh
TOP_DIR           = /mnt/irisgpfs/users/svarrette/git/gitlab.uni.lu/ULHPC/sw
----------------------------------------
LOCAL_RESIF_ENVIRONMENT = 2019b
LOCAL_RESIF_SYSTEM_NAME = iris
SYS_ARCH                = skylake
LOCAL_RESIF_ARCH        = gpu
LOCAL_RESIF_ROOT_DIR    = /work/projects/sw/resif
----------------------------------------
EASYBUILD_PREFIX               = /work/projects/sw/resif/iris/2019b/gpu
[...]
/!\ WARNING: Module tools/EasyBuild NOT FOUND

# double-check $EASYBUILD_PREFIX
$ ./scripts/setup.sh -h    # check CAREFULLY EASYBUILD_PREFIX
$ ./scripts/setup.sh -n    # dry-run
$ ./scripts/setup.sh
$ exit
```

## Production builds (`resif` user)

**Production** builds **MUST** be run as `resif` using the launcher scripts under `scripts/prod/*`.
In particular, to generate builds for the `<version>` software set:

```bash
# /!\ ADAPT <version>
[sbatch] ./scripts/prod/launcher-resif-prod-build-{cpu,cpu-skylake,gpu}.sh -v <version> [...]
```

Software and modules will be installed under `/opt/apps/resif` (`$LOCAL_RESIF_ROOT_DIR`) -- See [Technical Docs](https://hpc-docs.uni.lu/environment/modules/#ulhpc-modulepath).

![](https://hpc-docs.uni.lu/environment/images/ULHPC-software-stack.png)

You **MUST BE VERY CAREFUL** when running these scripts as they alter the production environment.

| Mode                  | Arch.       | Launcher                                                         | Settings                                     |
|-----------------------|-------------|------------------------------------------------------------------|----------------------------------------------|
| **Prod** build `aion` | `epyc`      | `./scripts/prod/launcher-prod-build-amd.sh         -v <version>` | `source settings/prod/<version>/aion.sh`     |
| **Prod** build `iris` | `broadwell` | `./scripts/prod/launcher-prod-build-cpu.sh         -v <version>` | `source settings/prod/<version>/iris.sh`     |
| **Prod** build `iris` | `skylake`   | `./scripts/prod/launcher-prod-build-cpu-skylake.sh -v <version>` | `source settings/prod/<version>/iris.sh`     |
| **Prod** build `iris` | `gpu`       | `./scripts/prod/launcher-prod-build-gpu.sh         -v <version>` | `source settings/prod/<version>/iris-gpu.sh` |

### Preliminary: configure `ULHPC/sw` repository for the `resif` user

For a production release, it is necessary to configure the `ULHPC/sw` repository under the `resif` user.

* Update the `resif` ULHPC user (also on gitlab/github)
* configure access to the repo on git (NOT with deployed key, but as user)
* Follow-up [setup](setup.md) instructions:
   - install direnv
   - create virtualenv: `python3 -m venv ~/venv/resif3`
   - clone `ULHPC/sw` repo and setup bash and local fork of the Easyconfigs repository

```bash
ssh resif@iris-cluster
mkdir git/gitlab.uni.lu/ULHPC
cd git/gitlab.uni.lu/ULHPC
git clone ssh://git@gitlab.uni.lu:8022/ULHPC/sw.git
cd sw
python3 -m venv ~/venv/resif3
make setup
make setup-direnv
direnv allow .
make setup-python
```
Post-check iris: you need also to prepare the `/opt/apps/resif/licenses_keys.yaml` as per [hook configurations](environment.md)

### Production Builds on `aion`

In the appropriate screen/tmux tabs:

```bash
sbatch ./scripts/prod/launcher-prod-build-amd.sh  -v <version>  [ toolchains | bd | bio | cs | dl | math | tools ]
tail -s1 -f logs/RESIF-Prod-CPU-epyc-<jobid>.out
```

### Production Builds on `iris`

In the appropriate screen/tmux tabs:

```bash
# Broadwell
sbatch ./scripts/prod/launcher-prod-build-cpu.sh  -v <version>  [ toolchains | bd | bio | cs | dl | math | tools ]
tail -s1 -f logs/RESIF-Prod-CPU-broadwell-<jobid>.out
# Skylake
sbatch ./scripts/prod/launcher-prod-build-cpu-skylake.sh  -v <version>  [ toolchains | bd | bio | cs | dl | math | tools ]
tail -s1 -f logs/RESIF-Prod-CPU-skylake-<jobid>.out
# GPU
sbatch ./scripts/prod/launcher-prod-build-gpu.sh  -v <version>
tail -s1 -f logs/RESIF-Prod-GPU-<jobid>.out
```

## Post-installation

Some software require a manual post-install run as root.

### Singularity

```bash
# next steps after installation
# INSTALLATION_PATH=your_installation_path
# chown root:root $INSTALLATION_PATH/Singularity/*/etc/singularity/singularity.conf
# chown root:root $INSTALLATION_PATH/Singularity/*/etc/singularity/capability.json
# chown root:root $INSTALLATION_PATH/Singularity/*/etc/singularity/ecl.toml
# chown root:root $INSTALLATION_PATH/Singularity/*/libexec/singularity/bin/*-suid
# chmod 4755 $INSTALLATION_PATH/Singularity/*/libexec/singularity/bin/*-suid
# chmod +s $INSTALLATION_PATH/Singularity/*/libexec/singularity/bin/*-suid
```
