# Git Workflow

* Documentation:
   - [Introduction to Git in IT/Dev(op)s Army Knives Tools for the Researcher](https://varrette.gforge.uni.lu/download/slides/2016-07-07-ITDevOps_Tools.pdf)
   - [git - the simple guide](https://rogerdudler.github.io/git-guide/index.html)
   - [Atlassian Git Workflow Tutorial](https://www.atlassian.com/git/tutorials/comparing-workflows)

A Git Workflow is a recipe or recommendation for how to use Git to accomplish work in a consistent and productive manner. Indeed, Git offers a lot of flexibility in how changes can be managed, yet there is no standardized process on how to interact with Git. The following questions are expected to be addressed by a successful workflow:

1. __Q1__: Does this workflow scale with team size?
2. __Q2__: Is it possible to prevent/limit mistakes and errors ?
3. __Q3__: Is it easy to undo mistakes and errors with this workflow?
4. __Q4__: Does this workflow permits to easily test new feature/functionnalities before production release ?
5. __Q5__: Does this workflow allow for Continuous Integration (even if not yet planned at the beginning)
6. __Q6__: Does this workflow permit to master the production release
7. __Q7__: Does this workflow impose any new unnecessary cognitive overhead to the team?

In particular, the default "_centralized_" workflow (where everybody just commit to the single `master` branch), while being the only one satisfying Q7, proved to be easily error-prone and can break production system relying on the underlying repository. For this reason, other more or less complex workflows have emerged -- all [feature-branch-based](https://www.atlassian.com/git/tutorials/comparing-workflows/feature-branch-workflow), that supports teams and projects where production deployments are made regularly:

* [Git-flow](http://nvie.com/posts/a-successful-git-branching-model/), the historical successful workflow featuring two main branches with an infinite lifetime (`production` and `{master | devel}`)
    - all operations are facilitated by the `git-flow` CLI extension
    - maintaining both branches can be bothersome - `make up`
    - the only one permitting to really control production release
* [Github Flow](https://guides.github.com/introduction/flow/), a lightweight version with a single branch (`master`)
    - pull-request based - requires interaction with Gitlab/Github web interface (`git request-pull` might help)

**All UL HPC repository are [still] configured to follow an hybrid [gitflow](http://nvie.com/posts/a-successful-git-branching-model/) branching model** (mainly because of Q5/Q6).

A comparison of the reference workflows is detailed below:

| Questions                       | centralized                      | git-flow                          | github flow                           |
|---------------------------------|----------------------------------|-----------------------------------|---------------------------------------|
| Q1 (scale)                      | `--`                             | `+++`                             | `+++`                                 |
| Q2 (limit errors )              | `--`                             | `++` (side branch)                | `+++` (pull-request)                  |
| Q3 (undo mistakes)              | `+` (`git revert`)               | `++`  (`git {revert/ branch -d}`) | `++`  (`git {revert/ branch -d}`)     |
| Q4 (isolate tests)              | `---`                            | `++` (feature branch)             | `++` (side branch)                    |
| Q5 (CI/CD)                      | `+`  (single branch)             | `+++` (prod vs. devel)            | `+` (single branch)                   |
| Q6 (control production release) | `---` (commit based)             | `+++` (`git-flow release`)        | `-` (`git tag` + deploy)              |
| Q7 (easy to understand)         | `+++` (no overhead)              | `---` (complex to understand)     | `+` (lightweight yet UI interactions) |
| Easy to use                     | `+++` (`git {pull/commit/push}`) | `++` (`git-flow [...]`)           | `++`                                  |
| Easy to setup                   | `+++` (`git clone`)              | `++` (`git clone` + `make setup`) | `+++` (`git clone`)                   |
| Easy to maintain                | `+++`  (`git pull`)              | `-` (`make up`)                   | `++`  (`git pull`)                    |


## UL HPC Git Workflow

The main concepts inherited from both advanced workflows are:

* The central repository holds **two main branches** with an infinite lifetime:
    - `production`: the *production-ready* branch
    - `devel | master`: the main (master) branch where the latest developments intervene (name depends on repository purpose). This is the *default* branch you get when you clone the repository.
* You should **always setup** your local copy of the repository with `make setup`
    - ensure also you have installed the `gitflow` extension
    - ensure you are properly made the initial configuration of git -- see also [sample `.gitconfig`](https://github.com/Falkor/dotfiles/blob/master/git/.gitconfig)

```bash
make setup
# Eventually
git config --global user.name "Firstname Lastname"
git config –-global user.email "firstname.lastname@uni.lu"
git config –-global color.ui true      # use colors
git config –-global core.editor vim    # your preferred editor
git config --global merge.tool kdiff3  # your preferred merge tool
```
* You may want to configure the following aliases (see also [those examples](https://github.com/Falkor/dotfiles/blob/master/oh-my-zsh/custom/plugins/falkor/falkor.plugin.zsh#L144)):
   ```bash
   alias gg="git log  --graph --pretty=format:'%C(auto)%h -%d %s %Cgreen(%cr)%Creset %C(bold blue)<%an>%Creset' --abbrev-commit --max-count=20"
   alias gd='git diff'
   alias u='git pull origin'
   alias s='git status'
   ```

* **Anything in the `devel | master` branch is stable/deployable** (ready for production release)

Then your daily workflow, illustrated in the figure, is as follows:

![](ULHPC-git-workflow.png)

1. To work on something new/WIP (Work In Progress), AFTER pulling, __create a descriptively named feature branch__ `feature/<name>` off the master/development branch holding the latest stable state of a project
   ```bash
   git status          # check unstaged/untracked files
   git checkout devel  # (eventually) /!\ ADAPT branch name to master if applicable
   git pull            # collect latests commits
   # OR
   make up             # collect latests commits from both development and production branches
   git-flow feature start <name>          # create and checkout to feature/<name>
   # OR: git checkout -b feature/<name>   # -b: create the branch if it doesn’t already exist.
   ```
2. __develop and commit to the `feature/<name>` branch locally__ and regularly push/__publish__ your work to the same named branch on the gitlab/github server
   - Commit early and often (commit logical chunks) with descriptive commit message
       * if appropriate: prefix commit message with `[<topic>]`
   - Test early and often
   - Publish your feature branch i.e. push your work the same named branch to make others aware of your current developments
       * this serves as a convenient _remote_ backup, and allow to get feedback or help from the other team members
   ```bash
   git checkout feature/<name>    # (eventually) come back to your feature branch
   git status    # check unstaged/untracked files
   [...]
   git add [...] # (eventually) stage/add not yet tracked file
   git commit -s -m "[<topic>] <msg>"   # -s: self signed
   git-flow feature publish <name>      #  Publish feature branch <name> on origin.
   ```
3. __Pull: get changes from the master/development branch__ holding the latest stable state of a project
   - Commit first!
   - Merge conflicts if necessary
   - **DO NOT REBASE** the master/development branch (as it is published thus public)
   - _As often a possible_
   ```bash
   git checkout feature/<name>    # (eventually) come back to your feature branch
   git fetch -va    # fetch and see latest available commits
   git status       # check unstaged/untracked files
   git commit -s -m "..."    # commit first
   git merge origin/devel    # /!\ ADAPT branch name to master if applicable
   #                         # OR: git pull origin devel
   # (eventually) solve conflicts, if any
   # git mergetool
   # git commit -s [...]
   # git push
   ```
4. __Push and [eventually] open a Pull request__ when you need feedback or help, or when you think the branch is ready for merging
   - Commit first!
   - Sync with the master/development branch
   - All tests/checks must pass
   - Open a pull/merge request by command line following [gitlab `push` options](https://docs.gitlab.com/ce/user/project/push_options.html#push-options-for-merge-requests) or [github `hub` utility](https://hub.github.com/)
   ```bash
   git commit -s -m "..."    # commit first
   git status    # everything should be clean, ideally without unstaged changes/untracked files
   git checkout devel # /!\ ADAPT branch name to master if applicable
   make up            # sync devel and production branches
   git checkout feature/<name>    # come back to your feature branch
   git request-pull devel ./     # check what would be put in the pull request
   ### Option 1: Open Pull/Merge Request from web interface
   # Gitlab: Open 'New merge request' from 'Merge Requests' menu on Gitlab/Github
   #      Source = feature/<name>, Target = devel   (or master if applicable)
   # Github: Open 'new pull request'
   #      Base = feature/<name>,   compare = devel
   ### Option 2: command line /!\ YOU NEED git >= 2.10
   # Gitlab:
   git push -o merge_request.create -o merge_request.target=$(git config --get gitflow.branch.develop)
   # If you get 'Everything up-to-date', you need to add an empty commit locally
   # Github:
   git push
   hub pull-request   # open a pull request for the branch you've just pushed
   ```
5. Pull request will be reviewed, eventually with comments/suggestion for modifications -- see [official doc](https://docs.gitlab.com/ee/user/project/merge_requests/)
   - In the merge request, in "Changes", select the line on which you want to add comments/suggest modifications
      * see [official doc](https://docs.gitlab.com/ee/user/project/merge_requests/reviewing_and_managing_merge_requests.html)
   - you may need to apply new commits to resolve the comments -- remember to mention the merge request in the commit message with the syntax '!<MRID>' (Ex: `!5`)
       * use simple quotes for inline `git commit -s -m '[<bundle name>] [...] resolve comment on !<N>'` (otherwise `!` will be interpreted by your shell)
   - once all changes looks OK, Approval can be granted from the "Overview" tab

6. Once the Pull/Merge requests received the expected number of [Approvals](https://docs.gitlab.com/ee/user/project/merge_requests/merge_request_approvals.html), it can be __merged__ it into the master/development branch and the __feature branch can be closed__
   - pull changes first (see step 3)
   - update the `devel` branch
   - finish the feature branch to merge it back to the master/development branch
   ```bash
   git checkout devel # /!\ ADAPT branch name to master if applicable
   make up            # sync devel and production branches
   git checkout feature/<name> # Eventually
   git pull origin    # collect eventual commits / changes suggested to the PR
   git pull origin devel       # /!\ ADAPT branch name to master if applicable
   git-flow feature finish <name> # feature branch 'feature/<name>' will be merged into 'devel'
   #                              # feature branch 'feature/<name>' will be locally deleted
   #                              # you will  checkout back to the 'devel' branch
   git push origin --delete feature/<name>   # /!\ WARNING: Ensure you delete the CORRECT remote branch
   git push  # sync devel|master branch
   ```
