# Integration with Github -- contribution to Easybuild

* __Official documentation__:
    - [Integration with Github](https://easybuild.readthedocs.io/en/latest/Integration_with_GitHub.html)

To limit the explosion of custom easyconfigs as was done in the past, the key objective of RESIF 3 is to **minimize** the number of custom easyconfigs to the _strict_ minimum.

For that reason, outside the custom ULHPC module bundles and a few other software tweaked for the ULHPC platform (Ex: `easyconfigs/o/OpenMPI/OpenMPI-3.1.4-GCC-8.3.0.eb`), every easyconfigs developed in this repository should be submitted as pull request to the official [easyconfigs](https://github.com/easybuilders/easybuild-easyconfigs) repository (see [`pull-requests.md`](pull-requests.md)).

The workflow is largely facilitated by the native [integration with Github](https://easybuild.readthedocs.io/en/latest/Integration_with_GitHub.html) within Easybuild, which assumes the following setup.


#### Integration Setup

See [Requirements](https://easybuild.readthedocs.io/en/latest/Integration_with_GitHub.html#requirements)

* Configure your personnal github username in `$XDG_CONFIG_HOME/easybuild/config.cfg`
    - alternatively, add a custom setting (not versioned) under `settings/custom/`

```bash
# Bootstrap a default configuration file
eb --confighelp > $XDG_CONFIG_HOME/easybuild/config.cfg
```

* ensure you have setup your Python environment in this repository -- see also [`setup.md`](../setup.md)

```bash
# Example if using pyenv -- alternatively just activate your virtualenv
$>  pyenv version
resif3 (set by PYENV_VERSION environment variable)

$> make setup-python     # OR: pip install -r requirements.txt
=> running 'pip install -r requirements.txt' within resif3 (set by PYENV_VERSION environment variable)
[...]

# Should now include keyring package
$> pip list|grep keyring
keyring               21.2.0
```

* On `iris` or `aion` (**only**), you will need to install in addition the possibly-insecure, alternate keyrings -- see https://pypi.org/project/keyring/
   `pip install keyrings.alt`

* Load easybuild

```
source settings/default.sh
eb --version
```

* Obtain a Personal GitHub token:
   - visit https://github.com/settings/tokens/new and log in with your GitHub account
   - Token description: "EasyBuild"
   - make sure (only) the gist and repo scopes are fully enabled
   - click Generate token
   - copy-paste the generated token and enter the following

```
$>  eb --github-user ULHPC --install-github-token
== temporary log file in case of crash /var/folders/2t/d5gk7bt14fv14k6zt2mglg3c0000gn/T/eb-72rj35vd/easybuild-ymrkbskt.log
Token:
Validating token...
Token seems to be valid, installing it.
Token '953....' installed!
```

You will need to repeat the process on Iris or Aion  (assuming you have also installed `keyring` etc.) in your local virtualenv/pyenv.
To [use the python 3 in `eb`](https://easybuild.readthedocs.io/en/latest/Python-2-3-compatibility.html), proceed as follows:

```
# you will need alternate, possibly-insecure, keyrings -- see https://pypi.org/project/keyring/
$ pip install keyrings.alt

$ eb --install-github-token --force
== temporary log file in case of crash /tmp/eb-6i8v5l09/easybuild-fwwf024d.log
WARNING: overwriting installed token '616..f49' for user 'ULHPC'...
Token:
Validating token...
Token seems to be valid, installing it.
Token '936..9d9' installed!
```


### Updating the forked Easyconfigs repo

ULHPC organization maintain a local fork of the official [easyconfigs](https://github.com/easybuilders/easybuild-easyconfigs) under [`ULHPC/easyconfigs`](https://github.com/ULHPC/easybuild-easyconfigs).
If you want to contribute back, you also need a local clone of this forked repository, or your own to contribute on your side.

In all cases, you **should** have a local clone of that repository (for us in `~/git/github.com/ULHPC/easyconfigs` as this is set by `$EASYBUILD_GIT_WORKING_DIRS_PATH`) configured with the appropriate `upstream` remote -- see [`../setup.md`](../setup.md).

Then to update the repo:

```
### Only on ULHPC facility
eval "$(ssh-agent)"
ssh-add ~/.ssh/id_rsa

# synchronize the local copy of the fork with upstream
make fork-easyconfigs-update
```

Which run the equivalent of the following commands:

```bash
cd ~/git/github.com/ULHPC/easybuild-easyconfigs
# OR use 'git -C ~/git/github.com/ULHPC/easybuild-easyconfigs [...]
git fetch -va origin
git fetch -va upstream
for br in develop main; do
   git checkout $br
   git merge origin/$br      # OR git pull origin   $br
   git merge upstream/$br    # OR git pull upstream $br
   git push origin $br
done
```

When you source the default settings, you should set the path to the **parent** directory of the location of the working directories (i.e., clones) of the EasyBuild repositories:

```
export EASYBUILD_GIT_WORKING_DIRS_PATH=$HOME/git/github.com/ULHPC/
```

### Check Github configuration:

```bash
# Normally, --github-user option is not required as set by
#     export EASYBUILD_GITHUB_USER=ULHPC
#
# On iris/aion:

$> eb --github-user ULHPC --check-github
eb --check-github
== temporary log file in case of crash /var/folders/2t/d5gk7bt14fv14k6zt2mglg3c0000gn/T/eb-164m_wbh/easybuild-8xdoxq73.log

Checking status of GitHub integration...

Making sure we're online...OK

* GitHub user...ULHPC => OK
* GitHub token...953..323 (len: 40) => OK (validated)
* git command...OK ("git version 2.25.0; ")
* GitPython module...OK (GitPython version 3.1.0)
* push access to ULHPC/easybuild-easyconfigs repo @ GitHub...OK
* creating gists...OK
* location to Git working dirs... OK (/Users/svarrette/git/github.com/ULHPC/)

All checks PASSed!

Status of GitHub integration:
* --from-pr: OK
* --new-pr: OK
* --review-pr: OK
* --update-pr: OK
* --upload-test-report: OK
```

Kill the ssh-agent if needed: `eval $(ssh-agent -k)`
