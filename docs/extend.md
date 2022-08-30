# Extending an Existing Software Set

It might happen (typically from user request on Service Now adressed to the High Level Support team) that a given software is either missing in the available software sets, or provided in a version considered not enough recent for the user.

## Missing software

You should first search if an existing Easyconfig exists for the software:

```bash
# Typical check for user on ULHPC clusters
$ si    # get an interactive job
$ module load tools/EasyBuild
$ eb -S <softwarename>
```

_Alternative_ from this repository (better as it will also search in the **latest** up-to-date [`easybuild-easyconfigs`](https://github.com/ULHPC/easybuild-easyconfigs) repository):

```bash
$ si # get an interactive job
$ cd path/to/ULHPC/sw
$ make up
$ make fork-easyconfigs-update  # ensure you get latest easyconfigs
$ source setting/<cluster>[-gpu].sh    # Adapt accordingly
$ eb -S <pattern>
$ ./scripts/suggest-easyconfigs [-v <version>] <pattern>
```

Just like within the [internal workflow](workflow.md) used upon RESIF bundle design, you will be confronted to the following cases:

1. **An existing easyconfigs `<filename>.eb` exists in the official repository for the target toolchain version `<version>`**
    - Test the build, either in your home or in a shared project
        * See below instructions: use `resif-load-{home,project}-swset-{prod,devel}` helpers to set a cosistent `$EASYBUILD_PREFIX` and `$MODULEPATH`
    - _if you already plan to promote it in an existing `prod | devel` software set_, [Test the build](build.md#testing-builds-project-sw) (project `sw`) as `$(whoami)` against a given swset version `<version>`
         * `sbatch ./scripts/<version>/launcher-test-build-<cluster>[-gpu].sh [-n] [-D] <filename>.eb`
         * If successful, repeat the [procedure within a **production** build](build.md#production-builds-resif-user) (as `resif` user)  against a given swset version `<version>`
             - `sbatch ./scripts/prod/launcher-prod-build-<cluster>[-gpu].sh -v <version> [-n] [-D] <filename>.eb`


### Test a build in your home

See also [Technical documentation](https://hpc-docs.uni.lu/environment/easybuild/#ulhpc-easybuild-configuration).

**That's typically what users are expected to do!!!**
If the below procedure works for you, you shall probably report the below instructions in the ticket such that the requesting user can repeat the procedure for himself.


```bash
# BETTER work in a screen or tmux session ;)
$ si[-gpu] [-c <threads>]   # get an interactive job
$ module load tools/EasyBuild
# /!\ IMPORTANT: ensure EASYBUILD_PREFIX is correctly set to [basedir]/<cluster>/<environment>/<arch>
#                and that MODULEPATH is prefixed accordingly
$ resif-load-home-swset-{prod | devel}  # adapt environment
$ eb -S <softwarename>   # confirm <filename>.eb == <softwarename>-<v>-<toolchain>.eb
$ eb -Dr <filename>.eb   # check dependencies, normally most MUST be satisfied
$ eb -r  <filename>.eb
```

From that point, the compiled software and associated module is available in your home and can be used as follows in [launchers](https://hpc-docs.uni.lu/slurm/launchers/) etc. -- see [ULHPC launcher Examples](https://hpc-docs.uni.lu/slurm/launchers/)

```bash
#!/bin/bash -l # <--- DO NOT FORGET '-l' to facilitate further access to ULHPC modules
#SBATCH -p <partition>
#SBATCH -N 1
#SBATCH --ntasks-per-node <#sockets * s>
#SBATCH --ntasks-per-socket <s>
#SBATCH -c <thread>

print_error_and_exit() { echo "***ERROR*** $*"; exit 1; }
# Safeguard for NOT running this launcher on access/login nodes
module purge || print_error_and_exit "No 'module' command"

resif-load-home-swset-prod  # OR  resif-load-home-swset-devel
module load <softwarename>[/<version>]
[...]
```

At that point, you may consider promoting the software into the official **production** RESIF builds within the appropriate bundles.

### Test a build in the `<project>` project

Similarly to the above home builds, you should repeat the procedure this time using the helper script `resif-load-project-swset-{prod | devel}`.
Don't forget [Project Data Management instructions](https://hpc-docs.uni.lu/data/project/#project-directory-modification): to avoid quotas issues, you have to use [`sg`](https://linux.die.net/man/1/sg)

```bash
# BETTER work in a screen or tmux session ;)
$ si[-gpu] [-c <threads>]   # get an interactive job
$ module load tools/EasyBuild
# /!\ IMPORTANT: ensure EASYBUILD_PREFIX is correctly set to [basedir]/<cluster>/<environment>/<arch>
#                and that MODULEPATH is prefixed accordingly
$ resif-load-project-swset-{prod | devel} $PROJECTHOME/<project> # /!\ ADAPT environment and <project> accordingly
$ sg <project> -c "eb -S <softwarename>"   # confirm <filename>.eb == <softwarename>-<v>-<toolchain>.eb
$ sg <project> -c "eb -Dr <filename>.eb"   # check dependencies, normally most MUST be satisfied
$ sg <project> -c "eb -r  <filename>.eb"
```

From that point, the compiled software and associated module is available in the project directoryand can be used by all project members as follows in [launchers](https://hpc-docs.uni.lu/slurm/launchers/) etc. -- see [ULHPC launcher Examples](https://hpc-docs.uni.lu/slurm/launchers/)

```bash
#!/bin/bash -l # <--- DO NOT FORGET '-l' to facilitate further access to ULHPC modules
#SBATCH -p <partition>
#SBATCH -N 1
#SBATCH --ntasks-per-node <#sockets * s>
#SBATCH --ntasks-per-socket <s>
#SBATCH -c <thread>

print_error_and_exit() { echo "***ERROR*** $*"; exit 1; }demonstrate
# Safeguard for NOT running this launcher on access/login nodes
module purge || print_error_and_exit "No 'module' command"

resif-load-project-swset-prod  $PROJECTHOME/<project> # OR resif-load-project-swset-devel $PROJECTHOME/<project>
module load <softwarename>[/<version>]
[...]
```

## Promoting a software into an existing software set `<version>`

Assuming you have successfully tested the build and running of a given Easyconfig `<filename>.eb`, you can follow the regular [User sofware builds workflow](build.md):

### Test a build in the `sw` project

See [Testing builds instructions](build.md#testing-builds-project-sw) (project `sw`) as `$(whoami)` against a given swset version `<version>`

```bash
sbatch ./scripts/<version>/launcher-test-build-<cluster>[-gpu].sh [-n] [-D] <filename>.eb
```

### Make a production build (as `resif` user)

See [Production builds instructions](build.md#production-builds-resif-user) (run as `resif` user, assuming you've been authorized by ULHPC ops team).

```bash
[sbatch] ./scripts/prod/launcher-resif-prod-build-{cpu,cpu-skylake,gpu}.sh -v <version> <filename>.eb
```

### Encourage contribution to the Easybuilders community.

**Any** new easyconfig(s) is  expected to be contributed back to the Easybuilders community.

See [`contributing/`](contributing/) for more details if you have done the job. Otherwise encourage the user to do it so he/she is credited for his/her work -- in both case, it's important to thus publicly commit these contributions -- just too many [particularly incompetent] people try to get credited for works/development they are not doing ;)
