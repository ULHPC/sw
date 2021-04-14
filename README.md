![By ULHPC](https://img.shields.io/badge/by-ULHPC-blue.svg) [![Licence](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](http://www.gnu.org/licenses/gpl-3.0.html) [![GitHub issues](https://img.shields.io/github/issues/ULHPC/sw.svg)](https://github.com/ULHPC/sw/issues/) [![Github](https://img.shields.io/badge/sources-github-green.svg)](https://github.com/ULHPC/sw/) [![GitHub forks](https://img.shields.io/github/forks/ULHPC/sw?style=flat-square)](https://github.com/ULHPC/sw)

      _   _ _       _   _ ____   ____   ____  _____ ____ ___ _____   _____  ___
     | | | | |     | | | |  _ \ / ___| |  _ \| ____/ ___|_ _|  ___| |___ / / _ \
     | | | | |     | |_| | |_) | |     | |_) |  _| \___ \| || |_      |_ \| | | |
     | |_| | |___  |  _  |  __/| |___  |  _ <| |___ ___) | ||  _|    ___) | |_| |
      \___/|_____| |_| |_|_|    \____| |_| \_\_____|____/___|_|     |____(_)___/

       Copyright (c) 2020-2021 UL HPC Team <hpc-team@uni.lu>

__User Software Management for [Uni.lu HPC](https://hpc.uni.lu) Facility based on the RESIF 3.0 framework__

This is the **Public** repository exposing the main scripts, concepts and documentation facilitating the dissemination of our concepts.

## Installation / Repository Setup

To clone this repository, proceed as follows (adapt accordingly):

``` bash
$ mkdir -p ~/git/github.com/ULHPC
$ cd ~/git/github.com/ULHPC
$ git clone https://github.com/ULHPC/sw.git
```

**`/!\ IMPORTANT`**: Once cloned and after following [Preliminaries guidelines](docs/setup.md) (LMod install, virtualenv setup, Github token etc. -- see [`docs/setup.md`](docs/setup.md) and [`docs/contributing/setup-github-integration.md`](docs/contributing/setup-github-integration.md)), initiate your local copy of the repository by running:

``` bash
$ cd ~/git/github.com/ULHPC/sw
$ make setup
```

__Post setup checks (laptop)__

From that point, you should be able to load Easybuild from your laptop, and all the following commands should succeed:

``` bash
### On your laptop
source settings/default.sh
eb --version
eb --show-config
# check that you are able to interact/update the ULHPC fork copy
make fork-easyconfigs-update
# check that you can interact with github
eb --check-github   # All checks PASSed!
```

__Post setup checks (on supercomputer login node)__

When repeating the setup on the cluster, you can check that you are ready if the following commands should succeed:

``` bash
### On iris, go on a broadwell node
si -C broadwell
# OR for skylake
si -C skylake
# OR for GPU node
si-gpu

source settings/iris.sh
#.     settings/iris-gpu.sh  # on GPU
# enable SSH agent
eval "$(ssh-agent)"
ssh-add ~/.ssh/id_rsa

eb --version
eb --show-config
# check that you are able to interact/update the ULHPC fork copy
make fork-easyconfigs-update
# check that you can interact with github
eb --check-github   # ONLY new-pr and update-pr should FAIL
# reason is that most probably you don't want the ssh key on the cluster authorized
# to push on ULHPC fork
# kill agent
eval "$(ssh-agent -k)"
```

## Documentation

See [`docs/`](docs/README.md).

The documentation for this project is handled by [`mkdocs`](http://www.mkdocs.org/#installation).
You might wish to generate locally the docs:

* Install [`mkdocs`](http://www.mkdocs.org/#installation)
* Preview your documentation from the project root by running `mkdocs serve` and visit with your favorite browser the URL `http://localhost:8000`
     - Alternatively, you can run `make doc` at the root of the repository.
* (eventually) build the full documentation locally (in the `site/` directory) by running `mkdocs build`.


## User Software builds

Slurm launchers are provided under `scripts/`  to facilitate software builds.
A GNU screen configuration file is provided to quickly bootstrap the appropriate tabs:

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


### Testing Builds (project `sw`)

You can test builds under `/work/projects/sw/resif` (`$LOCAL_RESIF_ROOT_DIR`) under your ULHPC account (assuming you belong to the group `sw`) with the launcher scripts `scripts/launcher-test-build-*`.

Software and modules will be installed under the `local` software set (`$LOCAL_RESIF_ENVIRONMENT`) i.e. under `/work/projects/sw/resif/iris/local/<arch>`.
_Note:_ The build command is `sg sw -c "eb [...] -r --rebuild"` (to enforce group ownership to the `sw` project -- see [docs](https://hpc-docs.uni.lu/data/project/)).

| Mode        | Arch.       | Launcher                                       | Settings                      |
|-------------|-------------|------------------------------------------------|-------------------------------|
| Local Tests | `broadwell` | `./scripts/launcher-test-build-cpu.sh`         | `source settings/iris.sh`     |
| Local Tests | `skylake`   | `./scripts/launcher-test-build-cpu-skylake.sh` | `source settings/iris.sh`     |
| Local Tests | `gpu`       | `./scripts/launcher-test-build-gpu.sh`         | `source settings/iris-gpu.sh` |

You may want to test a build **against** a production software set (Ex: 2019b) in which case you **MUST** use the `-v <version>` option:

```
[sbatch] ./scripts/launcher-test-build-{cpu,cpu-skylake,gpu}.sh -v 2019b [...]
```
You can also decide to target a private environment with `-e <name>` (Ex: 2019b) to ensure the builds goes into a dedicated (separated) directory, note however that you need to install EB into this directory.
To facilitate such tests, dedicated launchers scripts have been created under `./scripts/<version>/launcher-test-build-*`

| Mode                            | Arch.       | Launcher                                                 | Settings                                |
|---------------------------------|-------------|----------------------------------------------------------|-----------------------------------------|
| Local Tests `<version>` release | `broadwell` | `./scripts/<version>/launcher-test-build-cpu.sh`         | `source settings/<version>/iris.sh`     |
| Local Tests `<version>` release | `skylake`   | `./scripts/<version>/launcher-test-build-cpu-skylake.sh` | `source settings/<version>/iris.sh`     |
| Local Tests `<version>` release | `gpu`       | `./scripts/<version>/launcher-test-build-gpu.sh`         | `source settings/<version>/iris-gpu.sh` |

For more details, see [`docs/build.md`](docs/build.md)

### Production builds (`resif` user)

**Production** builds **MUST** be run as `resif` using the launcher scripts under `scripts/prod/*`.
In particular, to generate builds for the `<version>` software set:

```bash
# /!\ ADAPT <version>
[sbatch] ./scripts/prod/launcher-resif-prod-build-{cpu,cpu-skylake,gpu}.sh -v <version> [...]
```

Software and modules will be installed under `/opt/apps/resif` (`$LOCAL_RESIF_ROOT_DIR`) -- See [Technical Docs](https://hpc-docs.uni.lu/environment/modules/#ulhpc-modulepath).

![](https://hpc-docs.uni.lu/environment/images/ULHPC-software-stack.png)

You **MUST BE VERY CAREFUL** when running these scripts as they alter the production environment.

| Mode           | Arch.       | Launcher                                                         | Settings                                     |
|----------------|-------------|------------------------------------------------------------------|----------------------------------------------|
| **Prod** build | `broadwell` | `./scripts/prod/launcher-prod-build-cpu.sh         -v <version>` | `source settings/prod/<version>/iris.sh`     |
| **Prod** build | `skylake`   | `./scripts/prod/launcher-prod-build-cpu-skylake.sh -v <version>` | `source settings/prod/<version>/iris.sh`     |
| **Prod** build | `gpu`       | `./scripts/prod/launcher-prod-build-gpu.sh         -v <version>` | `source settings/prod/<version>/iris-gpu.sh` |

See [`docs/build.md`](docs/build.md) for more details.

## Workflow and ULHPC Bundle Development guidelines

You first need to review the expected [Git workflow](docs/contributing/git-flow.md)

See [`docs/workflow.md`](docs/workflow.md)

## Submitting working Easyconfigs to easybuilders

See [`docs/contributing/`](docs/contributing/README.md)

To limit the explosion of custom easyconfigs as was done in the past, the key objective of this project is to **minimize** the number of custom easyconfigs to the _strict_ minimum and thus to submit a maximum of easyconfigs to the community for integration in the official [`easybuilders/easybuild-easyconfigs`](https://github.com/easybuilders/easybuild-easyconfigs) repository.
A set of helper scripts are provided to facilitate this operation.

```bash
# Creating a new pull requests ON LAPTOP
./scripts/PR-create  easyconfigs/<letter>/<software>/<filename>.eb

# Complete it with a successfull test report ON IRIS
sbatch ./scripts/PR-rebuild-upload-test-report.sh <ID>
# (eventually) Update/complete the pull-request with new version/additional EB files
eb --update-pr <ID> <file>.eb --pr-commit-msg "<message>"

# Repo cleanup upon merged pull-request
./scripts/PR-close <ID>
```

## Easyconfigs suggestion

To add a new software to one of the ULHPC bundle module, you need to find and eventually adapt an existing Easyconfig file. Searching such files can be done using either `eb -S <pattern>`, or via the provided script `./scripts/suggest-easyconfigs <pattern>` which

1. search for Easyconfigs matching the proposed pattern, sorted by increasing version (`sort -V`)
2. check among those easyconfigs is any would be available for the target toolchain as that's probably the one you should use
3. suggest a single easyconfig to try (most recent version)

Example:
``` bash
$> ./scripts/suggest-easyconfigs -h
$> ./scripts/suggest-easyconfigs PAPI
=> Searching Easyconfigs matching pattern 'PAPI'
PAPI-5.4.3-foss-2016a.eb
PAPI-5.5.1-GCCcore-6.3.0.eb
PAPI-5.5.1-GCCcore-6.4.0.eb
PAPI-5.6.0-GCCcore-6.4.0.eb
PAPI-5.7.0-GCCcore-7.3.0.eb
PAPI-5.7.0-GCCcore-8.2.0.eb
PAPI-6.0.0-GCCcore-8.3.0.eb
Total:        7 entries

... potential exact match for 2019b toolchain
PAPI-6.0.0-GCCcore-8.3.0.eb
 --> suggesting 'PAPI-6.0.0-GCCcore-8.3.0.eb'
```

## Issues / Feature request

You can submit bug / issues / feature request using the [`ULHPC/sw` Project Tracker](https://github.com/ULHPC/sw/issues)
