# Repository Setup and Preliminaries

This projects relies on several components you need to have installed on your system.

* [Git](https://git-scm.com/)
* __On Mac OS__: [Homebrew](http://brew.sh/) (The missing package manager for macOS)

This repository is hosted on [GitHub](https://github.com/ULHPC/sw).
Git interactions with this repository (push, pull etc.) are performed over SSH using the port 8022.

To clone this repository, proceed as follows (adapt accordingly):

```bash
$ mkdir -p ~/git/github.com/ULHPC
$ cd ~/git/github.com/ULHPC
$ git clone git@github.com:ULHPC/sw.git   # SSH clone
# OR
$ git clone https://github.com/ULHPC/sw.git
$ cd sw
# IMPORTANT: run 'make setup' only **AFTER** LMOD etc. is installed
```

## SSH cluster key authorization on Gitlab and Github

You will have to allow the **public** SSH key attached to your account on the cluster _i.e._ `~/.ssh/id_{rsa | ed25519}.pub` to clone this repository, as well as the ULHPC fork repository on Github.
If you do not yet have an existing key pair, create a new one with `ssh-keygen -t ed25519 -o -a 100` for instance.

```bash
# If not yet existing
$> ssh-keygen -t ed25519 -o -a 100
Generating public/private ed25519 key pair.
Enter file in which to save the key (~/<login>/.ssh/id_ed25519):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in ~/<login>/.ssh/id_ed25519.
Your public key has been saved in ~/<login>/.ssh/id_ed25519.pub.
The key fingerprint is:
SHA256:sdUuyil97pUQppAy7ZWsXTcEqKRjSOumFH55K2+pPkA <login>@<cluster>
The key s randomart image is:
+--[ED25519 256]--+
|         ....    |
|  .  ..o.. o     |
| . ooo+.= = +    |
| Eo ++.= B + .   |
|o.....o S o .    |
| +oo . o o o .   |
|.oo . + = . o    |
|.  o + . o .     |
|  .o*.   .o      |
+----[SHA256]-----+

# Get key content
$> cat ~/.ssh/id_ed25519.pub
ssh-ed25519 XXXX <login>@<cluster>
```

* __Gitlab__: Copy the above key as part of the Repository as **Deploy Key** (under Repository `Settings > CI/CD > Deploy Keys`)
   - Title: "`<cluster> / <login>`"
   - Key: the key content
   - Tick "`Write access allowed`"
   - "Add Key"
* Enable also this key as part of the `ULHPC/sw` repository

* __Github__: go in the [`ULHPC/easybuild-easyconfigs` Settings / Deploy keys](https://github.com/ULHPC/easybuild-easyconfigs/settings/keys) (the `easybuild-easyconfigs` fork) and [`ULHPC/sw` Settings / Deploy keys](https://github.com/ULHPC/sw/settings/keys) (public export)
   - Select "Add deploy key"
   - Title: "`<cluster> cluster / <login>`"
   - Key: the key content
   - **DO NOT** tick Allow write access (unless you want to be able to do it from the cluster)
   - "Add Key"

-------
## LMod

[Lmod](https://lmod.readthedocs.io/)  is a [Lua](http://www.lua.org/) based module system that easily handles the `MODULEPATH` Hierarchical problem.
It is drop-in replacement for TCL/C modules and reads TCL modulefiles directly.
**LMod is NOT COMPLIANT with Environment Modules [3.x or 4.X](http://modules.sourceforge.net/)**
In particular, [Lmod](https://lmod.readthedocs.io/) add many interesting features on top of the traditional implementation focusing on an easier interaction (search, load etc.) for the users and is in use on the [UL HPC facility](http://hpc.uni.lu)

* [User Guide for Lmod](https://lmod.readthedocs.io/en/latest/010_user.html)
* [Installing Lmod](https://lmod.readthedocs.io/en/latest/index.html#installing-lmod)

#### LMod Installation under Mac OS X

The best is to use [HomeBrew](http://brew.sh)

~~~bash
$> brew install lua luarocks
# Homebrew does not provide special Lua dependencies
$> luarocks-5.2 install luafilesystem
$> luarocks-5.2 install luaposi
~~~

_Note_:  You can also use `--local` option (or the `--tree <path>`) to have the LUA packages installed in `~/.luarocks` (or `<path>`). If you use `--tree <path>`, you need to update the environmental variables [`LUA_PATH` and `LUA_CPATH`](http://leafo.net/guides/customizing-the-luarocks-tree.html) as follows:

~~~bash
export LUA_PREFIX="$HOME/.local/share/luarocks"
export LUA_PATH="$LUA_PREFIX/share/lua/5.2/?.lua;$LUA_PATH"
export LUA_CPATH="$LUA_PREFIX/lib/lua/5.2/?.so;$LUA_CPATH"
~~~

Now it should be fine to install LMod:

~~~bash
$> brew install lmod
~~~

After this installation:

* `lmod` command is located in `$(brew --prefix lmod)/libexec` and you probably wants to make an **alias** for it

          alias lmod='$(brew --prefix lmod)/libexec/lmod'

* You may want to load LMOD variables from your favorite shell init script:

          source $(brew --prefix lmod)/init/$(basename $SHELL)

#### LMod install under Linux/CentOS

**Prerequisites:** You need to have the EPEL testing repositories in the sources list. (Do not enable it by default). Then install the Lmod package using this repo.

~~~bash
$> yum install epel-release -y
$> yum install --enable-repo=epel-testing Lmod
~~~

-----------------------------------------------
## Python virtualenv and packages dependencies

**You will have to create the `resif3` virtual environment with Python 3 to use this repository.**
Two options are proposed to you:

1. rely on the fact that Python 3.3 and later provide built-in support for virtual environments via the `venv` module in the standard library.
2. use the combination of [`pyenv`](https://github.com/pyenv/pyenv) and [`pyenv-virtualenv`](https://github.com/pyenv/pyenv-virtualenv)

In addition, a [direnv](https://direnv.net/) configuration file is proposed at the root of the repository to automatically create and activate (resp. deactivate) this virtual environment when entering (resp. leaving) this repository.


* **On your laptop**, you probably want to favor the Option 2 (`pyenv[-virtualenv]`), combined with [direnv](https://direnv.net/) to have the most flexible and transparent interaction with this repository
   - See [this blog post](https://varrette.gforge.uni.lu/blog/2019/09/10/using-pyenv-virtualenv-direnv/) for a general overview
* **On the cluster**, you probably want to to favor the Option 1 (`venv`).


### Direnv

[direnv](https://direnv.net/) is an extension for your shell. It augments existing shells with a new feature that can load and unload settings (activate a python virtual environment, set environment variables) depending on the current directory through a simple `.envrc` file placed at the root of the repository.

**`/!\ IMPORTANT:` Enabling `direnv` is _optional_ but STRONGLY encouraged on your local laptop**

Here the [direnv](https://direnv.net/) configuration file `.envrc` is set to automatically load the appropriate virtual environment (named `resif3` -- see `.python-virtualenv`).


#### Installation notes

* [official direnv installation notes](https://direnv.net/docs/installation.html)
    - personnal [blog post](https://varrette.gforge.uni.lu/blog/2019/09/10/using-pyenv-virtualenv-direnv/)

```bash
# Mac OS
brew install direnv
# Fedora / Ubuntu / Arch
{ dnf install | apt install | pacman -S } direnv

# Manual install with stow (CentOS)
yum install stow
mkdir -p /usr/local/stow/direnv-2.21.2/bin
curl -o /usr/local/stow/direnv-2.21.2/bin/direnv -fL https://github.com/direnv/direnv/releases/download/v2.21.2/direnv.linux-amd64
chmod +x /usr/local/stow/direnv-2.21.2/bin/direnv
cd /usr/local/stow/
stow direnv-2.21.2    # Now check /usr/local/bin/direnv
```

#### Direnv setup

Once [direnv](https://direnv.net/) is installed, then use:

```bash
make setup-direnv
```

to create the appropriate setup under `~/.config/direnv` i.e.

1. setup `${XDG_CONFIG_HOME}/direnv/init.sh` which you can source in your favorite shell configuration (`.bashrc`, `.zshrc`...) to enable  [direnv](https://direnv.net/) on your system
    - reference file: [`direnv/init.sh`](https://github.com/Falkor/dotfiles/blob/master/direnv/init.sh)
2. setup `${XDG_CONFIG_HOME}/direnv/direnvrc` which **override** the default [direnv-stdlib](https://github.com/direnv/direnv/blob/master/stdlib.sh)  and is **mandatory** to allow for the `.envrc` configuration of this repository to work
    - reference file: [`direnv/direnvrc`](https://github.com/Falkor/dotfiles/blob/master/direnv/direnvrc)
3. provides a sample `.envrc` file you may want to use for your other projects.

As suggested, you will have to adapt (and source) your favorite shell configuration.
The following should permit to cover also `pyenv[-virtualenv]` (put it typically at the end of your `.bashrc` / `.zshrc`) -- assuming `$XDG_CONFIG_HOME` is defined.

``` bash
# XDG  Base Directory Specification
# See https://specifications.freedesktop.org/basedir-spec/latest/
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
[...]
for f in $XDG_CONFIG_HOME/*/init.sh; do
  . ${f}
done
```

_Note_ Direnv is now installed also on `iris` cluster, so you may want to enable it also on your account.


### Pyenv

[pyenv](https://github.com/pyenv/pyenv) lets you easily switch between multiple versions of Python. It's simple, unobtrusive, and combined with [`pyenv-virtualenv`](https://github.com/pyenv/pyenv-virtualenv) (a pyenv plugin to manage virtualenv (a.k.a. python-virtualenv)), it permits to transparently manage python virtual environments for you.

* __Installation notes__: see again [this blog post](https://varrette.gforge.uni.lu/blog/2019/09/10/using-pyenv-virtualenv-direnv/).

```bash
# Mac OS
brew install pyenv pyenv-virtualenv
# Linux
curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
```

Now you can run the following command to setup your local machine in a compliant way:

```
make setup-pyenv
```

As suggested, you will have to adapt (and source) our favorite shell configuration (see above).

Then you can install the appropriate Python version defined in `.python-version`

```bash
pyenv install --list
pyenv install $(head .python-version)
pyenv versions
```

### Python 3 venv module

The default direnv expects you to have the virtual environment set in `~/venv/resif3`:

```bash
python3 -m venv ~/venv/resif3
source ~/venv/resif3/bin/activate
pip install --upgrade pip
```

## Python dependencies installation

Whatever option you choose, you should now be able to install the required packages within the `resif3` virtual environment using:

    pip install -r requirements.txt

__OR__, simply run:

```
make setup-python
```

### Example setup on `iris` cluster

**PENDING REVIEW -- pyenv is no longer required**

You will have to create the dedicated virtualenv that will be used:

* install `pyenv`
* install `pyenv-virtualenv`
* create the appropriate virtualenv `resif3`

```bash
### By default using the system python
# get interactive job
$> si

# Install pyenv
# See https://github.com/pyenv/pyenv#basic-github-checkout
$> git clone https://github.com/pyenv/pyenv.git ~/git/github.com/pyenv/pyenv
# Default bash config -- see ~/.config/shell/custom/pyenv.sh
$> cat pyenv.sh
# Initialization of the pyenv and pyenv-virtualenv
# - pyenv: https://github.com/pyenv/pyenv
# - pyenv-virtualenv: https://github.com/pyenv/pyenv-virtualenv

export PYENV_ROOT="$HOME/git/github.com/pyenv/pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if [ -n "$(which pyenv 2>/dev/null)" ]; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"

  export PYENV_VIRTUALENV_DISABLE_PROMPT=1
fi

$> source ~/.config/shell/custom/pyenv.sh
$> pyenv install $(head .python-version)

# Install pyenv-virtualenvs
# See https://github.com/pyenv/pyenv-virtualenv
git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
eval "$(pyenv virtualenv-init -)"

# Create appropriate virtualenv
pyenv virtualenv $(head .python-version) $(head .python-virtualenv)

# Activate it
pyenv activate $(head .python-virtualenv)

# Check enabled virtualenvs
pyenv virtualenvs
  3.7.4/envs/resif3 (created from /home/users/ULHPC/git/github.com/pyenv/pyenv/versions/3.7.4)
* resif3 (created from /home/users/ULHPC/git/github.com/pyenv/pyenv/versions/3.7.4)

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt
```

-------------------
## Repository setup

**`/!\ IMPORTANT`**: Once cloned and LMod installed, initiate your local copy of the repository by running:

    $> cd ~/git/github.com/ULHPC/sw
    $> make setup

This will initiate the Git submodules of this repository (see `.gitmodules`) and setup the [git flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) layout for this repository.
It will also install the latest version of [Easybuild](https://easybuild.readthedocs.io/)

Later on, you can upgrade the local repository by pulling the latests commits etc. by running

    $> make up

--------------------------------------------------------
## Setup your local fork of the Easyconfigs repository

ULHPC organization maintain a local fork of the official [easyconfigs](https://github.com/easybuilders/easybuild-easyconfigs) under [`ULHPC/easyconfigs`](https://github.com/ULHPC/easybuild-easyconfigs). This permits to contribute back to the EasyBuild community.
If you want to use the `scripts/PR-*` ones, you **SHOULD** have a local clone of that repository __in `~/git/github.com/ULHPC/easybuild-easyconfigs`__ (as this is set by `$EASYBUILD_GIT_WORKING_DIRS_PATH`) and configure your working copy with the appropriate `upstream` remote.
Adapt the Github user if needed -- a dedicated file under `settings/custom/github.sh` for instance can be used to hold your preferable settings at this level.

**Optionally**, you can set custom paths in the files `.Makefile.before` (variable `FORK_EASYCONFIGS_DIR`) and `settings/custom.sh` (variables `EASYBUILD_ROBOT_PATHS` and `EASYBUILD_GIT_WORKING_DIRS_PATH`)

Proceed as follows:

```bash
mkdir -p ~/git/github.com/ULHPC/
cd ~/git/github.com/ULHPC/
git clone git@github.com:ULHPC/easybuild-easyconfigs.git
cd easybuild-easyconfigs

# Add 'upstream' remote
git remote add upstream https://github.com/easybuilders/easybuild-easyconfigs.git
# check it
git remote -v
origin	git@github.com:ULHPC/easybuild-easyconfigs.git (fetch)
origin	git@github.com:ULHPC/easybuild-easyconfigs.git (push)
upstream	https://github.com/easybuilders/easybuild-easyconfigs.git (fetch)
upstream	https://github.com/easybuilders/easybuild-easyconfigs.git (push)

# checkout the branch master
git checkout -b main  --track origin/main
# ... and return to develop branch which should be your default
git checkout develop
```

At any moment of time, you can update this repository and synchronize with both the `origin` and `upstream` remotes by running __from this repository (i.e. `ULHPC/sw`)__:

```
make fork-easyconfigs-update
```

--------------------------------------------------------
## Install Easybuild

Now it's time to install [Easybuild](http://easybuild.readthedocs.io/en/latest/Introduction.html) -- see also [UL HPC Tutorial on Easybuild](https://ulhpc-tutorials.readthedocs.io/en/latest/tools/easybuild/#part-2-easybuild).
The script `scripts/setup.sh` will take care of that from the settings set in `settings/default.sh` (i.e. install under `apps/local`).

```bash
### On iris, you need to be on computing node to access the 'module' command
# ./script/get-interactive-job -c1
./scripts/setup.sh -n   # Dry-run
./scripts/setup.sh
```


---------------------------------------------------------------------
## Setup your Github tokens to allow for contributions to Easybuild

See [`contributing/setup-github-integration.md`](contributing/setup-github-integration.md)


----------------------------------
## Last and Misc. setup operations

### Installing the Git LFS extension

Custom sources are stored in this repository under `sources/` through the [Git LFS](https://git-lfs.github.com/) extension, a system for managing and versioning large files in association with a Git repository.
In particular, you need to install [git-lfs client](https://git-lfs.github.com/).

See [`layout.md`](layout.md)

### Preparing for RAM builds

* Under Linux, use `/dev/shm` for Easybuild build processes
* Under Mac OS, you need to [create and mount a ram based disk](https://stackoverflow.com/questions/2033362/does-os-x-have-an-equivalent-to-dev-shm).
   - Create a disk:  `hdiutil attach -nomount ram://$((2 * 1024 * SIZE_IN_MB))`
       * `hdiutil` will return the name of the ramdisk.
   - Format and mount the disk: `diskutil eraseVolume HFS+ shm /dev/<disk2>`
   - Access the disk under `/Volumes/shm`

Example:

```bash
# Creating a 500MB ramdisk:
$> hdiutil attach -nomount ram://$((2 * 1024 * 500))
/dev/disk2
$> diskutil eraseVolume HFS+ shm /dev/disk2
Started erase on disk2
Unmounting disk
Erasing
Initialized /dev/rdisk2 as a 500 MB case-insensitive HFS Plus volume
Mounting disk
Finished erase on disk2 shm
```

## Post Sanity checks

__On your laptop__

```bash
### On your laptop
source settings/default.sh
eb --version
eb --show-config
# check that you are able to interact/update the ULHPC fork copy
make fork-easyconfigs-update
# check that you can interact with github
eb --check-github   # All checks PASSed!
```


__On `iris/aion` cluster__

``` bash
### On iris, this will go on a broadwell node
./scripts/get-interactive-job
source settings/${ULHPC_CLUSTER}.sh
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
eval "$(ssh-agent -k)"
```


## That's all folks!!
