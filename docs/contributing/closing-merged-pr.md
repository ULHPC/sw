# Closing a merged Pull Request

You can see the status of the **closed** Pull-requests by ULHPC using the following URL:

->__[Closed Pull-Requests submitted from ULHPC Fork](https://github.com/easybuilders/easybuild-easyconfigs/pulls?q=is%3Apr+is%3Aclosed+ULHPC)__<-

In particular, the ones with a merge symbol are merged.

## Workflow overview

__If a pull request is accepted/merged__ _i.e.,_ that the contributed easyconfigs has been merged to the `develop` branch of the official [`easybuilders/easybuild-easyconfigs`](https://github.com/easybuilders/easybuild-easyconfigs), __it is useless to keep the eb file as part of this repository__ since upon build, this branch is also  searched as last resort (see `$EASYBUILD_ROBOT_PATHS` settings in [`settings/default.sh`](https://github.com/ULHPC/sw/-/blob/devel/settings/default.sh)).

_In short_, once a pull-request is accepted and merged, it is then time to make some cleanup of this repository from the easyconfigs that are now integrated.
This is facilitated by the script [`./scripts/PR-close`](https://github.com/ULHPC/sw/-/blob/devel/scripts/PR-close)

```bash
$> ./scripts/PR-close -h
$> ./scripts/PR-close -n <ID>   # Dry-run
$> ./scripts/PR-close <ID>
```

This will:

1. Collect info on the Pull request using the [Github API](https://developer.github.com/v3/pulls/#get-a-single-pull-request)
    - using `curl https://api.github.com/repos/easybuilders/easybuild-easyconfigs/pulls/<ID>`
    - resulting JSON stored under `logs/$(date +%F)-pull-request-<ID>.json`
         * to limit the number of requests (limited to 60 per days by Github)
    - Extract from it meta-data information (author, title, state)
2. delete from git the directory `easyconfigs/pull-requests/<ID>` and involved easyconfigs, i.e.
    - the symlinks under `easyconfigs/pull-requests/<ID>/*.eb`
    - the target real files `easyconfigs/<letter>/<software>/<filename>.eb`
3. synchronize your local copy of the (fork) easyconfigs repository
    - using `make fork-easyconfigs-update`
4. delete the git branch(es) (including remotes) used for the pull request
5. delete the JSON file holding the REST API request

## Example

To close the [merged pull request #10311](https://github.com/easybuilders/easybuild-easyconfigs/pull/10311):

```bash
$> ./scripts/PR-close -n 10311   # Dry-run
# /!\ WARNING: closing merged pull-request '10311'.
# Are you sure you want to continue? [Y|n]
# => collect pull-request status using Github API
#   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
#                                  Dload  Upload   Total   Spent    Left  Speed
# 100 22472    0 22472    0     0  48211      0 --:--:-- --:--:-- --:--:-- 48223
# => Repository [git] cleanup from 'easyconfigs/pull-requests/10311/' content
# deleting: symlink '/Users/svarrette/git/github.com/ULHPC/sw/easyconfigs/pull-requests/10311/LLVM-9.0.1-GCCcore-8.3.0.eb'
#    ...  and target eb file '/Users/svarrette/git/github.com/ULHPC/sw/easyconfigs/l/LLVM/LLVM-9.0.1-GCCcore-8.3.0.eb'
# git rm /Users/svarrette/git/github.com/ULHPC/sw/easyconfigs/pull-requests/10311/LLVM-9.0.1-GCCcore-8.3.0.eb
# git rm /Users/svarrette/git/github.com/ULHPC/sw/easyconfigs/l/LLVM/LLVM-9.0.1-GCCcore-8.3.0.eb
# git rm -rf /Users/svarrette/git/github.com/ULHPC/sw/easyconfigs/pull-requests/10311
# git commit -s -m [Merged PR #10311] closing '{compiler}[GCCcore/8.3.0] LLVM v9.0.1'; repo cleanup accordingly
# Updating (Fork) repository '/Users/svarrette/git/github.com/ULHPC/easybuild-easyconfigs'
# make fork-easyconfigs-update
# deleting [remote] branch '20200402130420_new_pr_LLVM901' from (Fork) repository '/Users/svarrette/git/github.com/ULHPC/easybuild-easyconfigs'
# git -C /Users/svarrette/git/github.com/ULHPC/easybuild-easyconfigs branch -d 20200402130420_new_pr_LLVM901
# git -C /Users/svarrette/git/github.com/ULHPC/easybuild-easyconfigs push origin --delete 20200402130420_new_pr_LLVM901
# removing /Users/svarrette/git/github.com/ULHPC/sw/logs/2020-04-06-pull-request-10311.json
# rm -f /Users/svarrette/git/github.com/ULHPC/sw/logs/2020-04-06-pull-request-10311.json
```

If all looks good, proceed:

```bash
$> ./scripts/PR-close 10311
# /!\ WARNING: closing merged pull-request '10313'.
# Are you sure you want to continue? [Y|n]
# ... using existing json '/Users/svarrette/git/github.com/ULHPC/sw/logs/2020-04-06-pull-request-10313.json'
# => Repository [git] cleanup from 'easyconfigs/pull-requests/10313/' content
# deleting: symlink '/Users/svarrette/git/github.com/ULHPC/sw/easyconfigs/pull-requests/10313/LLVM-10.0.0-GCCcore-8.3.0.eb'
#    ...  and target eb file '/Users/svarrette/git/github.com/ULHPC/sw/easyconfigs/l/LLVM/LLVM-10.0.0-GCCcore-8.3.0.eb'
# rm 'easyconfigs/pull-requests/10313/LLVM-10.0.0-GCCcore-8.3.0.eb'
# rm 'easyconfigs/l/LLVM/LLVM-10.0.0-GCCcore-8.3.0.eb'
# fatal: pathspec '/Users/svarrette/git/github.com/ULHPC/sw/easyconfigs/pull-requests/10313' did not match any files
# [devel c79e2aa] [Merged PR #10313] closing '{compiler}[GCCcore/8.3.0] LLVM v10.0.0'; repo cleanup accordingly
#  2 files changed, 46 deletions(-)
#  delete mode 100644 easyconfigs/l/LLVM/LLVM-10.0.0-GCCcore-8.3.0.eb
#  delete mode 120000 easyconfigs/pull-requests/10313/LLVM-10.0.0-GCCcore-8.3.0.eb
# Updating (Fork) repository '/Users/svarrette/git/github.com/ULHPC/easybuild-easyconfigs'
# => fetching latest remote commits (incl. from upstream) in '/Users/svarrette/git/github.com/ULHPC/easybuild-easyconfigs'
# From https://github.com/hpcugent/easybuild-easyconfigs
#  = [up to date]            2020a          -> upstream/2020a
#  = [up to date]            3.9.x          -> upstream/3.9.x
#  = [up to date]            4.0.x          -> upstream/4.0.x
#  = [up to date]            4.1.x          -> upstream/4.1.x
#  = [up to date]            auto_merge_prs -> upstream/auto_merge_prs
#  = [up to date]            develop        -> upstream/develop
#  = [up to date]            master         -> upstream/master
#
# => Pulling and updating the local branch 'develop' in 'easybuild-easyconfigs' repository
#
# Already on 'develop'
# Your branch is up to date with 'origin/develop'.
# From github.com:ULHPC/easybuild-easyconfigs
#  * branch                  develop    -> FETCH_HEAD
# Already up to date.
#
# => Pulling and updating from upstream the local branch 'develop'
#
# From https://github.com/hpcugent/easybuild-easyconfigs
#  * branch                  develop    -> FETCH_HEAD
# Already up to date.
#
# => Pushing local branch 'develop'
#
# Everything up-to-date
#
# => Pulling and updating the local branch 'master' in 'easybuild-easyconfigs' repository
#
# Switched to branch 'master'
# Your branch is up to date with 'origin/master'.
# From github.com:ULHPC/easybuild-easyconfigs
#  * branch                  master     -> FETCH_HEAD
# Already up to date.
#
# => Pulling and updating from upstream the local branch 'master'
#
# From https://github.com/hpcugent/easybuild-easyconfigs
#  * branch                  master     -> FETCH_HEAD
# Already up to date.
#
# => Pushing local branch 'master'
#
# Everything up-to-date
# => returning to default branch 'develop' in 'easybuild-easyconfigs' repository
# Switched to branch 'develop'
# Your branch is up to date with 'origin/develop'.
# deleting [remote] branch '20200402155358_new_pr_LLVM1000' from (Fork) repository '/Users/svarrette/git/github.com/ULHPC/easybuild-easyconfigs'
# error: branch '20200402155358_new_pr_LLVM1000' not found.
# To github.com:ULHPC/easybuild-easyconfigs.git
#  - [deleted]               20200402155358_new_pr_LLVM1000
# removing /Users/svarrette/git/github.com/ULHPC/sw/logs/2020-04-06-pull-request-10313.json
```
