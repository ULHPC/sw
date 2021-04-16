
This repository is organized as follows:

~~~bash
.
├── Makefile     # GNU Make configuration
├── README.md    # Project README
├── VERSION      # /!\ DO NOT EDIT. Current repository version
├── apps/        # Root directory for applications builds (past RESIF data dir)
│   └── local    # Easybuild prefix for 'local' environment (Local tests)
├── config/      # Easybuild configurations
├── docs/        # [MkDocs](mkdocs.org) main directory
├── easyconfigs/ # Custom Easyconfigs
│   ├── pull-requests/     # Pending pull-requests to official easybuild-easyconfigs repo
│   └── u
│       ├── ULHPC/         # Main ULHPC bundle
│       ├── ULHPC-toolchains/ # Main toolchains, compilers, debuggers, programming languages
│       ├── ULHPC-bio/      # bioinformatics, biology and biomedical bundle
│       ├── ULHPC-cs/       # computational science bundle
│       └── [...]
├── logs/          # Slurm logs, json temporary etc.
│   └── easybuild/ # Easybuild logs
├── mkdocs.yml   # [MkDocs](mkdocs.org) configuration
├── requirements.txt   # Python requirements for the 'resif3' virtual environment
├── scripts/     # Utility scripts
│   ├── {2019b, 2020a, 2021a,...}/
│   │   └── launcher-test-build-*    # Test builds (project sw) against <version> release
│   ├── PR-*                    # Pull-request management (create, update, close)
│   ├── get-interactive-job*    # wrappers for getting architecture-based interactive jobs
│   ├── include/
│   │   └── common.bash         # common functions for launchers
│   ├── launcher-test-build*    # Test builds (project sw)
│   ├── prod/
│   │   ├── launcher-resif-prod-build-*   # **Prod** builds (resif user)
│   ├── setup.sh                # Easybuild bootstrap
│   └── suggest-easyconfigs     # Helper guiding easyconfigs search
├── settings     # Settings to source
│   ├── {2019b, 2020a, 2021a,...}/           # Setting for <version> tests builds (project sw)
│   │   └── <cluster>[-gpu].sh
│   ├── archives/        # old settings (spartan etc.)
│   ├── custom/          # custom settings (ex: Gurobi licence etc.)
│   ├── default.sh       # Generic default settings
│   ├── <cluster>[-gpu].sh # Generic test settings for <cluster>, eventually for gpu arch
│   └── prod/            # **Prod** settings (resif user)
│       ├── {2019b, 2020a, 2021a,...}/ # Setting for <version> **prod** builds (resif user)
│       ├── default.sh          # Generic default settings for **prod** builds
│       └── <cluster>[-gpu].sh  # Cluster settings for production builds
├── slides/      # Slides
└── sources/     # Special/Commercial software sources
~~~

--------------------
## Software sources

By default, easybuild relies on its [source path](https://easybuild.readthedocs.io/en/latest/Configuration.html#sourcepath) to specify  the  directory in which EasyBuild looks for software source and install files.
Outside the defaults ones, you should configure the `sources/` directory of this repository as the __second__ location to search for sources, as done in `settings/default.sh`.

```bash
export EASYBUILD_SOURCEPATH=${EASYBUILD_PREFIX}/sources:${TOP_DIR}/sources:/opt/apps/sources
```

As the archives in this folder are quite heavy, they should be managed by the [Git LFS](https://git-lfs.github.com/) extension, a system for managing and versioning large files in association with a Git repository.
Instead of storing the large files within the Git repository as blobs, Git LFS stores special "pointer files" in the repository, while storing the actual file contents on a Git LFS server. The contents of the  large  file  are  downloaded  automatically  when needed, for example when a Git branch containing the large file is checked out.

Git LFS is supported on our internal [Gitlab](https://docs.gitlab.com/ee/administration/lfs/manage_large_binaries_with_git_lfs.html) instance as well as on the public [Github](https://docs.github.com/en/github/managing-large-files/configuring-git-large-file-storage) export.

* You need to install [git-lfs client](https://git-lfs.github.com/)
* See `.gitattributes` and [path specs](https://css-tricks.com/git-pathspecs-and-how-to-use-them/)
   - Tracked files are added using ` git lfs track <pattern>`:
* Simply run `make setup-git-lfs` to run `git-lfs pull` and fetch the real files tracked using LFS
   - this will have to be done only once (or never if you cloned the repo with git-lfs installed)

If you want to add/track a new pattern, proceed as follows:

```bash
$> git lfs track 'sources/**/*.tar.gz'
[...]
$> git lfs track
Listing tracked patterns
    sources/**/*.tar.gz (.gitattributes)
    sources/**/*.tar.bz2 (.gitattributes)
    sources/**/*.tgz (.gitattributes)
Listing excluded patterns
```

Then nothing special is necessary when adding source files:

```bash
$> git add sources/PGI/pgilinux-2019-1910-x86-64.tar.gz
$> git status
On branch devel
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   sources/PGI/pgilinux-2019-1910-x86-64.tar.gz

$> git commit -s -m '[sources] PGI 19.10'
[devel 4113b2b] [sources] PGI 19.10
 1 file changed, 3 insertions(+)
 create mode 100644 sources/PGI/pgilinux-2019-1910-x86-64.tar.gz

# Difference intervene here:
$> git lfs ls-files
ac9db73ba8 * sources/PGI/pgilinux-2019-1910-x86-64.tar.gz
```
