# Submitting working Easyconfigs to easybuilders

* __Official documentation__:
    - [Submitting pull requests (`--new-pr`)](https://easybuild.readthedocs.io/en/latest/Integration_with_GitHub.html#submitting-pull-requests-new-pr)
    - [Uploading test reports (`--upload-test-report`)](https://easybuild.readthedocs.io/en/latest/Integration_with_GitHub.html#uploading-test-reports-upload-test-report)
    - [Updating existing pull requests (`--update-pr`)](https://easybuild.readthedocs.io/en/master/Integration_with_GitHub.html#updating-existing-pull-requests-update-pr)


## TL;DR

```bash
# Creating a new pull requests ON LAPTOP
./scripts/PR-create -n easyconfigs/<letter>/<software>/<filename>.eb    # Dry-run
./scripts/PR-create easyconfigs/<letter>/<software>/<filename>.eb

# Complete it with a successfull test report ON IRIS/AION
sbatch ./scripts/PR-rebuild-upload-test-report.sh <ID>
# OR manually (ex on iris):
(access)$> ./scripts/get-interactive-job
(node)$> source settings/iris.sh
(node)$> eb --from-pr <ID> --rebuild --upload-test-report


# Update/complete the pull-request with new version/additional EB files
eb --update-pr <ID> <file>.eb --pr-commit-msg "<message>"

# Repo cleanup upon merged pull-request
./scripts/close-merged-PR <ID>
```


## Creating a new pull-request

Once you have a new (tested) and working EB file eligible for a pull request, use the script [`scripts/PR-create`](https://gitlab.uni.lu/svarrette/sw/-/blob/devel/scripts/PR-create) to create a new pull-request  __from your laptop__

```
$> ./scripts/PR-create -h
$> ./scripts/PR-create -n  easyconfigs/<letter>/<software>/<filename>.eb
$> ./scripts/PR-create  easyconfigs/<letter>/<software>/<filename>.eb
```

This will perform the following operations:

1. [checking code style](https://easybuild.readthedocs.io/en/latest/Code_style.html#code-style) with `eb --check-contrib <ebfile>`
2. submitting a new pull requests  using `eb --new-pr <ebfile>`
3. store info on pending pull-request in a dedicated directory `easyconfigs/pull-requests/<ID>`
    - create the directory `easyconfigs/pull-requests/<ID>`
    - add symlink to the EB file
    - add and commit all files, including the EB file

Example to submit a [new pull request](https://github.com/easybuilders/easybuild-easyconfigs/pull/10294) for the file `easyconfigs/p/PGI/PGI-19.10-GCC-8.3.0-2.32.eb`:

```bash
# From your local laptop
$ ./scripts/PR-create -n easyconfigs/p/PGI/PGI-19.10-GCC-8.3.0-2.32.eb   # Dry-run
# /!\ WARNING About to open a pull-request for 'easyconfigs/p/PGI/PGI-19.10-GCC-8.3.0-2.32.eb'.
# Are you sure you want to continue? [Y|n]
# => checking code style for 'easyconfigs/p/PGI/PGI-19.10-GCC-8.3.0-2.32.eb'
# eb --check-contrib easyconfigs/p/PGI/PGI-19.10-GCC-8.3.0-2.32.eb
# => submitting a new pull requests for 'easyconfigs/p/PGI/PGI-19.10-GCC-8.3.0-2.32.eb'
# echo eb --new-pr easyconfigs/p/PGI/PGI-19.10-GCC-8.3.0-2.32.eb
# Enter created pull-request ID: (using fake PR: )
# => storing info on pending Pull-Request #1234
# mkdir -p /Users/svarrette/git/gitlab.uni.lu/svarrette/sw/easyconfigs/pull-requests/1234
# ln -s ../../easyconfigs/p/PGI/PGI-19.10-GCC-8.3.0-2.32.eb /Users/svarrette/git/gitlab.uni.lu/svarrette/sw/easyconfigs/pull-requests/1234/PGI-19.10-GCC-8.3.0-2.32.eb
# => committing changes
# git add easyconfigs/p/PGI/PGI-19.10-GCC-8.3.0-2.32.eb
# git add /Users/svarrette/git/gitlab.uni.lu/svarrette/sw/easyconfigs/pull-requests/1234
# git commit -s -m [PR #1234] easyconfigs/p/PGI/PGI 19.10

$ ./scripts/PR-create easyconfigs/p/PGI/PGI-19.10-GCC-8.3.0-2.32.eb
# [...]
# == pushing branch '20200331180505_new_pr_PGI1910' to remote 'github_ULHPC_slNhC' (git@github.com:ULHPC/easybuild-easyconfigs.git)
#
# Opening pull request
# * target: easybuilders/easybuild-easyconfigs:develop
# * from: ULHPC/easybuild-easyconfigs:20200331180505_new_pr_PGI1910
# * title: "{compiler}[system/system] PGI v19.10"
# * labels: update
# * description:
# """
# (created using `eb --new-pr`)
#
# """
# * overview of changes:
#  .../easyconfigs/p/PGI/PGI-19.10-GCC-8.3.0-2.32.eb  | 28 ++++++++++++++++++++++
#  1 file changed, 28 insertions(+)
#
# Opened pull request: https://github.com/easybuilders/easybuild-easyconfigs/pull/10294
# [...]
# Enter created pull-request ID: 10294     # <-- ENTER above pull-request ID
# => storing info on pending Pull-Request #10294
# => committing changes
```

Or manually:

```bash
### 1. check code style
eb --check-contrib easyconfigs/p/PGI/PGI-19.10-GCC-8.3.0-2.32.eb
### 2. submitting a new pull requests
eb --new-pr easyconfigs/p/PGI/PGI-19.10-GCC-8.3.0-2.32.eb
# == temporary log file in case of crash /var/folders/2t/d5gk7bt14fv14k6zt2mglg3c0000gn/T/eb-v93_tnbo/easybuild-iugpknt1.log
# == cloning git repo from /Users/svarrette/git/github.com/ULHPC/easybuild-easyconfigs...
# == fetching branch 'develop' from https://github.com/easybuilders/easybuild-easyconfigs.git...
# == copying easyconfigs to /var/folders/2t/d5gk7bt14fv14k6zt2mglg3c0000gn/T/eb-v93_tnbo/git-working-dir1wpamgcw/easybuild-easyconfigs...
# == pushing branch '20200331180505_new_pr_PGI1910' to remote 'github_ULHPC_BRZZM' (git@github.com:ULHPC/easybuild-easyconfigs.git)
#
# Opening pull request
# * target: easybuilders/easybuild-easyconfigs:develop
# * from: ULHPC/easybuild-easyconfigs:20200331180505_new_pr_PGI1910
# * title: "{compiler}[system/system] PGI v19.10"
# * labels: update
# * description:
# """
# (created using `eb --new-pr`)
#
# """
# * overview of changes:
#  .../easyconfigs/p/PGI/PGI-19.10-GCC-8.3.0-2.32.eb  | 28 ++++++++++++++++++++++
#  1 file changed, 28 insertions(+)
#
# Opened pull request: https://github.com/easybuilders/easybuild-easyconfigs/pull/10294
# == Temporary log file(s) /var/folders/2t/d5gk7bt14fv14k6zt2mglg3c0000gn/T/eb-v93_tnbo/easybuild-iugpknt1.log* have been removed.
# == Temporary directory /var/folders/2t/d5gk7bt14fv14k6zt2mglg3c0000gn/T/eb-v93_tnbo has been removed.
### 3. storing info on pending pull-request 10294
mkdir -p easyconfigs/pull-requests/10294
cd easyconfigs/pull-requests/10294
ln -s ../../p/PGI/PGI-19.10-GCC-8.3.0-2.32.eb  .     # Symlink here involved EB files
cdroot
git add easyconfigs/pull-requests/10294
git add easyconfigs/p/PGI/PGI-19.10-GCC-8.3.0-2.32.eb
git commit -s -m "[PR #10294] PGI 19.10"
```

In particular, at any moment of point, the pending pull requests are stored in `easyconfigs/pull-requests/`


## Complement the pull-request with a (successful) test report

Now you probably want to __upload also a test report__, __from `iris`__, using the script:

```
./scripts/PR-rebuild-upload-test-report.sh <ID>
```

Note that this asssumes that you correctly configured a token on iris (see [`contributing/README.md`](index.md)):

```bash
# On iris cluster, Example  with PR 10294
$> sbatch ./scripts/PR-rebuild-upload-test-report.sh 10294

## OR manually:
$> srun -p interactive -N 1 --ntasks-per-node 1 -c 28 --pty bash
$> source settings/iris.sh
# Example
# Setting EB_PYTHON from pyenv is no longer needed...
# $> EB_PYTHON=$(pyenv which python) eb --from-pr 10294 --rebuild --upload-test-report
$> eb --from-pr 10294 --rebuild --upload-test-report
# == temporary log file in case of crash /tmp/eb-gkxsg3xp/easybuild-i59anb9z.log
# == resolving dependencies ...
# == processing EasyBuild easyconfig /tmp/eb-gkxsg3xp/files_pr10294/p/PGI/PGI-19.10-GCC-8.3.0-2.32.eb
# == building and installing compiler/PGI/19.10-GCC-8.3.0-2.32...
# == fetching files...
# == creating build dir, resetting environment...
# == unpacking...
# == patching...
# == preparing...
# == configuring...
# == building...
# == testing...
# == installing...
# == taking care of extensions...
# == restore after iterating...
# == postprocessing...
# == sanity checking...
# == cleaning up...
# == creating module...
# == permissions...
# == packaging...
# == COMPLETED: Installation ended successfully (took 2 min 53 sec)
# == Results of the build can be found in the log file(s) /mnt/irisgpfs/users/svarrette/git/lab.uni.lu/svarrette/sw/apps/local/software/PGI/19.10-GCC-8.3.0-2.32/easybuild/easybuild-PGI-19.10-20200331.181312.log
# Adding comment to easybuild-easyconfigs issue #10294: 'Test report by @ULHPC
# **SUCCESS**
# Build succeeded for 1 out of 1 (1 easyconfigs in this PR)
# iris-021 - Linux centos linux 7.7.1908, Intel(R) Xeon(R) CPU E5-2680 v4 @ 2.40GHz, Python 3.7.4
# See https://gist.github.com/dbe8390f1290ce1c79905b5d3ce5cd7f for a full test report.'
# == Test report uploaded to https://gist.github.com/dbe8390f1290ce1c79905b5d3ce5cd7f and mentioned in a comment in easyconfigs PR#10294
# == Build succeeded for 1 out of 1
# == Temporary log file(s) /tmp/eb-gkxsg3xp/easybuild-i59anb9z.log* have been removed.
# == Temporary directory /tmp/eb-gkxsg3xp has been removed.
```

## (eventually) Correct and/or add other EB files to your pull request

If you need to __update/complete the pull-request__, use `eb --update-pr <PR> <file>.eb --pr-commit-msg "message"`.
Example:

```bash
# Adapt PR ID accordingdly
eb --update-pr 10306 easyconfigs/j/Java/Java-13.eb --pr-commit-msg "Provide Java 13 wrapper accordingdly (i.e. to use Java 13.0.2)"
```

Remember to update the symlinks in `easyconfigs/pull-requests/<ID>` when appropriate.

```bash
# Update PR 10306 from above
cd easyconfigs/pull-requests/10306
ln -s ../../j/Java/Java-13.eb .
git add .
git commit -s -m "[PR #10306] Complete with Java 13 wrapper accordingdly"
```

## Update your local easyconfigs from Pull Request comments

It might happen that further commits are proposed by easybuilders to correct your initial easyconfig.
In that case you should collect the latest version from the pull request branch using the [`scripts/PR-collect-remote-updates`](https://gitlab.uni.lu/svarrette/sw/-/blob/devel/scripts/PR-collect-remote-updates)

```bash
$> ./scripts/PR-collect-remote-updates -h
$> ./scripts/PR-collect-remote-updates -n <ID>   # Dry-run
$> ./scripts/PR-collect-remote-updates <ID>
```

This will:

1. Collect info on the Pull request using the [Github API](https://developer.github.com/v3/pulls/#get-a-single-pull-request)
    - using `curl https://api.github.com/repos/easybuilders/easybuild-easyconfigs/pulls/<ID>`
    - resulting JSON stored under `logs/$(date +%F)-pull-request-<ID>.json`
         * to limit the number of requests (limited to 60 per days by Github)
    - Extract from it meta-data information (author, title, branch)
2. synchronize your local copy of the (fork) easyconfigs repository
    - using `make fork-easyconfigs-update`
3. checkout the pull request branch and get the latest commits/updates in the (fork) easyconfigs repository
4. update the local easyconfigs files accordingly
5. checkout back to the 'develop' branch in the fork repository
6. delete the JSON file holding the REST API request

Example:

```bash
$> ./scripts/PR-collect-remote-updates -n 10294
# /!\ WARNING: update your local easyconfigs from pull-request '10294'.
# Are you sure you want to continue? [Y|n]
# ... using existing json '/Users/svarrette/git/gitlab.uni.lu/svarrette/sw/logs/2020-04-07-pull-request-10294.json'
# Updating (Fork) repository '/Users/svarrette/git/github.com/ULHPC/easybuild-easyconfigs'
# make fork-easyconfigs-update
# collecting last commits from [remote] branch '20200331180505_new_pr_PGI1910' from (Fork) repository '/Users/svarrette/git/github.com/ULHPC/easybuild-easyconfigs'
# git -C /Users/svarrette/git/github.com/ULHPC/easybuild-easyconfigs checkout 20200331180505_new_pr_PGI1910
# git commit -s -m [PR #10294] {compiler}[system/system] PGI v19.10 Update from Pull Request
# => restore state of (Fork) repository '/Users/svarrette/git/github.com/ULHPC/easybuild-easyconfigs'
#    checkout to branch 'develop'
# git -C /Users/svarrette/git/github.com/ULHPC/easybuild-easyconfigs checkout develop
#    delete local branch '20200331180505_new_pr_PGI1910'
# git -C /Users/svarrette/git/github.com/ULHPC/easybuild-easyconfigs branch -d 20200331180505_new_pr_PGI1910
# removing /Users/svarrette/git/gitlab.uni.lu/svarrette/sw/logs/2020-04-07-pull-request-10294.json
# rm -f /Users/svarrette/git/gitlab.uni.lu/svarrette/sw/logs/2020-04-07-pull-request-10294.json

$> ./scripts/PR-collect-remote-updates 10294
```


OR, proceed manually:

```bash
# Update Fork repository
make fork-easyconfigs-update
# Collect the name of the pull-request branch from PR <ID>
# /!\ ADAPT <ID> accordingly
curl --silent https://api.github.com/repos/easybuilders/easybuild-easyconfigs/pulls/<ID> | grep ULHPC: | cut -d '"' -f 4 | cut -d ':' -f 2

# checkout that branch from the fork repository
git -C ~/git/github.com/ULHPC/easybuild-easyconfigs checkout <YYYYMMDDHHMMSS>_new_pr_<software><version>
# Diff and copy -- Example with PR 10311
diff ~/git/github.com/ULHPC/easybuild-easyconfigs/easybuild/easyconfigs/l/LLVM/LLVM-9.0.1-GCCcore-8.3.0.eb  easyconfigs/l/LLVM/LLVM-9.0.1-GCCcore-8.3.0.eb
cp ~/git/github.com/ULHPC/easybuild-easyconfigs/easybuild/easyconfigs/l/LLVM/LLVM-9.0.1-GCCcore-8.3.0.eb    easyconfigs/l/LLVM/LLVM-9.0.1-GCCcore-8.3.0.eb
# checkout to the develop branch within the fork repository
git -C ~/git/github.com/ULHPC/easybuild-easyconfigs checkout develop
# Commit changes
git add easyconfigs/l/LLVM/LLVM-9.0.1-GCCcore-8.3.0.eb
git commit -s -m "[PR #<ID>] update LLVM 9.0.1 from Pull Request"
```


## Delete EB files upon pull-request merge

see [`closing-merged-pr.md`](closing-merged-pr.md)
