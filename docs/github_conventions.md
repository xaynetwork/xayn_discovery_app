### Submit PRs always together with an increase of general coverage

That means newly introduced code needs to be covered by **at least 50%**!

_"Coverage is not a good measurement for code quality. But at least it is a measurement."_ 
Confucius 1037 BC

---------------

### Table of content:

1. [Creating PR](#creating-prs)
1. [Branch naming](#branch-naming)
1. [Commit messages](#commit-messages)
1. [Merging](#merging-in-github)
1. [Reviewing](#reviewing)
1. [Emoji for review](#emoji-for-review)

---------------

### Creating PRs

- Aim for a good commit history (use `git blame <file>` and `git log`).
- When you just start working on your PR - mark it with label `WIP ⏳`
- When your PR is ready for review - remove `WIP ⏳` and add `Ready for review ✅` label
- When you get a few comments and decide to improve your PR - please change the labels again. Keep
  them updated - it helps others better understand which PRs are more important to review.
- After merging your PR - rebase the next `Ready for review ✅` PR in line, so the next dev does not
  need to wait for its verification.

---------------

### Branch naming

Ideally every PR should refer to the JIRA task. It means there is a `task-id`, which should be
represented in the branch naming. Apart from the `task-id` branch name should be meaningful and
self-representative.

For example:

- we have task with id `TB-1234`
- task is about fixing jumping keyboard issue As result, branch should be named like
  next: ``TB-1234_jumping_keyboard_issue_fix``

---------------

### Commit messages

Ideally first commit in PR, should follow the next template:

```
TB-XXXX: _commit_title_here_
 
Commit message details here
```

Avoid submitting useless commit messages

```
// bad  
 XAYN-1767 clean up search result list (#617)
 * wip
 * wip
 * wip
 * wip
 * wip
 * wip
 * wip
 * wip
 * wip
 * wip  
 *

// better  

 XAYN-1234: Quickfix update provisioning profiles after the introduction of the AD capa.
// New Line
The Accociated Domains (AD)  Capability was introduced by e64a876900416098e375ca19bc483ececde27f84
to allow domains to be accociated with the app,
and thus marketing links to work.
This needed to be updated in the certificates/ capabilities / identifiers [1] and downloaded
to the build_scripts/profiles folder.  
[1] https://developer.apple.com/account/resources/identifiers/list  
```

During development process this is totally okay to create _wip_ commits, but when submitting this as
a PR, squash your commits into a single or multiple  
distinct and well documented commits.  
For this you can
use [rebase interactive](https://hackernoon.com/beginners-guide-to-interactive-rebasing-346a3f9c3a6d) `git rebase -i HEAD~#NO_OF_COMMITS`

Avoid merging develop into your current feature branch, instead use
rebase (`git fetch && git rebase origin/develop`).  
Then it is easier to share a branch between developers and to create clean commits that can be (
rebase+merge) into develop.

---------------

### Merging in Github

- **Rebase + Merge** - clean commits with nice messages
- **Squash + Merge** - dirty commit history - but then you need to provide a good non-trivial squash
  commit message (last step before merging the PR).

- try to avoid **Squash + Merge** cos then the history of individual commits are lost
- try to do **Rebase + Merge** as much as possible, cos it make life of other developers much
  easier :)

---------------

### Reviewing

- Make it nice ritual. **Do it at least twice per day**:
    - start your morning with :coffee: and PR review
    - finish your working day with cup of :tea: and PR review
- Review the oldest PR first
- Ask questions (and answer them, this helps to create a document of discussions for later)
- When writing a comment - use [emoji](#emoji-for-review)
- When reviewing - **do not hesitate to test it** (for example run the app). Some bugs are easier to
  find when you see them

---------------

### Emoji for review

There is nice practice to use emoji during PR review, specially when you are commenting something
for the first time.

Why it might be useful:

- from the first glance you can understand what about will be this comment
- easier visually to separate more and less important comments
- looks more fancy :tada:

| emoji | code | meaning | actions |
|-------|------|---------|---------|
| :heart: | `:heart:` | nice solution, awesome code, etc | do not require any action |
| :nail_care: | `:nail_care:` | some tiny improvements, polishing stuff, etc | not critical , but probably need to be updated |
| :bulb: | `:bulb:` | idea of how this piece of code might be improved | place for discussion, probably might be updated |
| :question: | `:question:` | unclear code/meaning/destinations, etc | place for discussion, might be needed some changes |
| :stop_sign: | `:stop_sign:` | smth wrong here | blocker to merge, update is required |

Here are some examples:

- :nail_care: this empty line can be removed
- :question: what is the benefit of putting this variable here?
- :stop_sign: we should not store secrets in code like this

-----------
