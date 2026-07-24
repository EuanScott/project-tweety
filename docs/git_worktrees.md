# Integrating parallel Git worktrees

Worktrees do not need to be merged. A worktree is only another directory
attached to the same repository; the **branches and commits** made in those
directories are what you integrate. Linked worktrees share the repository's
object database and normal refs, but each has its own `HEAD` and index.

## A safe workflow

Start each piece of work on its own branch from the same known base:

```sh
git switch main
git pull --ff-only
git worktree add -b feature/profile-copy ../project-profile-copy main
git worktree add -b feature/profile-validation ../project-profile-validation main
```

In each worktree, edit, test, and commit normally. Do not leave the work only
as uncommitted files: another worktree cannot merge those changes.

Then integrate one branch at a time in the worktree that owns `main` (or in a
separate integration worktree on an integration branch):

```sh
git switch main
git merge --no-ff feature/profile-copy
# run the relevant tests
git merge --no-ff feature/profile-validation
# run the relevant tests again
```

The first merge establishes the new base. When the two branches touched the
same lines, update the second branch against that base *before* merging it:

```sh
cd ../project-profile-validation
git rebase main
# resolve any conflicts, then: git add <resolved-files> && git rebase --continue
# run the relevant tests

cd /path/to/main-worktree
git merge --no-ff feature/profile-validation
```

If `feature/profile-validation` is already shared with other people, prefer
`git merge main` in that branch instead of rebasing it: that avoids rewriting
its published commit history. The final merge to `main` is the same.

## Resolving a merge conflict

Git stops a merge when it cannot combine overlapping changes. In the target
worktree:

```sh
git status
# edit each conflicted file; keep the intended combined behaviour
git add <resolved-files>
git merge --continue
```

Run focused tests after resolving the conflict, because a textual resolution
can still be behaviourally wrong. To abandon that integration attempt and
return the target branch to its pre-merge state, use `git merge --abort`.
During a rebase, use `git rebase --continue` after staging the resolution, or
`git rebase --abort` to return the feature branch to its pre-rebase state.

## Worktree-specific constraints

- A branch is normally checked out by at most one worktree. Create a distinct
  branch for each parallel change; do not force the same branch into two
  worktrees.
- Check `git worktree list` before cleanup. Remove a finished, clean linked
  worktree with `git worktree remove <path>`; then delete its merged branch if
  it is no longer useful.
- Do not manually delete or move worktree directories. Use `git worktree
  remove` or `git worktree move`; `git worktree repair` can recover metadata
  when a directory has already moved.

## References

- [git-worktree(1)](https://git-scm.com/docs/git-worktree): linked-worktree
  model, branch-checkout safety, lifecycle, and shared versus per-worktree
  state.
- [git-merge(1)](https://git-scm.com/docs/git-merge): merge execution,
  conflict resolution, and `--abort`.
- [git-rebase(1)](https://git-scm.com/docs/git-rebase): rebase continuation,
  abort, and the warning about rewriting published history.
