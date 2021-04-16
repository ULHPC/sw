![By ULHPC](https://img.shields.io/badge/by-ULHPC-blue.svg) [![Licence](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](http://www.gnu.org/licenses/gpl-3.0.html) [![GitHub issues](https://img.shields.io/github/issues/ULHPC/sw.svg)](https://github.com/ULHPC/sw/issues/) [![Github](https://img.shields.io/badge/sources-github-green.svg)](https://github.com/ULHPC/sw/) [![GitHub forks](https://img.shields.io/github/forks/ULHPC/sw?style=flat-square)](https://github.com/ULHPC/sw)

      _   _ _       _   _ ____   ____   ____  _____ ____ ___ _____   _____  ___
     | | | | |     | | | |  _ \ / ___| |  _ \| ____/ ___|_ _|  ___| |___ / / _ \
     | | | | |     | |_| | |_) | |     | |_) |  _| \___ \| || |_      |_ \| | | |
     | |_| | |___  |  _  |  __/| |___  |  _ <| |___ ___) | ||  _|    ___) | |_| |
      \___/|_____| |_| |_|_|    \____| |_| \_\_____|____/___|_|     |____(_)___/

       Copyright (c) 2020-2021 UL HPC Team <hpc-team@uni.lu>

__User Software Management for Uni.lu HPC Facility 3.0__

This is the main page of the documentation for this repository, which relies on [MkDocs](http://www.mkdocs.org/) and the [Read the Docs](http://readthedocs.io) theme. It proposes to detail the following elements:

* The [organization and directory layout](layout.md)
* Complete [Installation and Setup notes](setup.md) notes
* Overview of the proposed [Easybuild Framework @ ULHPC](environment.md)
* Overview and Hierarchy of the proposed [UL HPC Modules Bundles](swsets/index.md)
* [Contributing notes](contributing/index.md) (including a summary of the [(ULHPC) Git workflow](contributing/git-workflow.md)) and [semantic versioning](contributing/versioning.md) information of this project

To limit the explosion of custom easyconfigs as was done in the past, the key objective of this project is to **minimize** the number of custom easyconfigs to the _strict_ minimum and thus to submit a maximum of easyconfigs to the community for integration in the official [`easybuilders/easybuild-easyconfigs`](https://github.com/easybuilders/easybuild-easyconfigs) repository.

* The proposed workflow is detailed in the [Contributing notes](contributing/index.md), including:
    - [Setup instructions for Integration with Github](contributing/setup-github-integration.md) to allow for Easyconfigs contributions
    - guildelines to [submit working Easyconfigs to easybuilders as Pull-Requests](contributing/pull-requests.md)
    - Instructions to perform [upon merged Pull Request for repository cleanup](contributing/closing-merged-pr.md)
