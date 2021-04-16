## Local contribution

You are more than welcome to contribute to the development of RESIF 3 as follows (assuming you belong to the project on Gitlab).
See [`git-workflow.md`](git-workflow.md) for more details on the expected git workflow followed by the ULHPC Team -- it is "summarized" in the below figure:

![](ULHPC-git-workflow.png)

This assumes that you have understood the [directory tree structure](../layout.md) of this repository.

Finally, you shall be aware of the way the [semantic versioning](versioning.md) procedure of this project is handled.

---------------------------------------------------------
## Integration with Github -- contribution to Easybuild

To limit the explosion of custom easyconfigs as was done in the past, one of the key objective of RESIF 3  is to **minimize** the number of custom easyconfigs to the _strict_ minimum and thus to submit a maximum of easyconfigs to the community for integration in the official [`easybuilders/easybuild-easyconfigs`](https://github.com/easybuilders/easybuild-easyconfigs) repository.
This assumes that you setup a private Github token for both your laptop and on the ULHPC facility.

See [`setup-github-integration.md`](setup-github-integration.md) for detailed instructions.

Then a set of helper scripts are provided to facilitate the contribution process, which follows the following workflow:

```bash
### TL;DR Contribution to Easybuild ###
# Creating a new pull requests ON LAPTOP
./scripts/PR-create [-n] easyconfigs/<letter>/<software>/<filename>.eb

# Complete it with a successfull test report ON IRIS
sbatch ./scripts/PR-rebuild-upload-test-report.sh <ID>
# (eventually) Update/complete the pull-request with new version/additional EB files
eb --update-pr <ID> <file>.eb --pr-commit-msg "<message>"
#  Update your local easyconfigs from PR commits
./scripts/update-from-PR [-n] <ID>

# Repo cleanup upon merged pull-request
./scripts/PR-close [-n] <ID>
```

-------------------------------
## Creating new Pull-Requests

... aka submitting working Easyconfigs to the official [`easybuilders/easybuild-easyconfigs`](https://github.com/easybuilders/easybuild-easyconfigs) repository for integration.

See [`pull-requests.md`](pull-requests.md)

------------------------------------------------
## Repository cleanup upon merged Pull-Requests

... aka delete useless EB files to restrict to the minimum the number of "_custom_" easyconfigs.

See [`closing-merged-pr.md`](closing-merged-pr.md)
