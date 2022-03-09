#!/usr/bin/env bash
set -euxo pipefail

function error() {
    echo "$@" >&2
    exit 1
}

DRY_RUN=true

case "$1" in
    --dry-run)
        ;;
    --do-push)
        DRY_RUN=false
        ;;
    --help)
        set +x
        echo "release.sh (--dry-run|--do-push)"
        echo "  NOTE: use 'just dry-run-release' to dry-run it locally"
        exit 0
        ;;
    *)
        error "First argument must either be --dry-run or --do-push"
        ;;
esac

EMAIL="$(git config user.email)"
if [ -z "$EMAIL" ]; then
    error "git user.email must be set"
fi
USERNAME="$(git config user.name)"
if [ -z "$USERNAME" ]; then
    error "git user.name must be set"
fi

BRANCH="$(git branch --show-current)"

echo "Targeting branch: $BRANCH"

# Create a temporary folder to clone the other repo
DST_DIR=$(mktemp -d)
DST_REPO='git@github.com:xaynetwork/xayn_discovery_app_public.git'

SRC_COMMIT=$(git rev-parse HEAD)
SRC_COMMIT_MSG=$(git log --format=%B -n1)

# Check if the branch exists, if so, clone using the existing branch,
# if not, clone using the default branch and let git push to send to the right branch
BRANCH_EXISTS=$(git ls-remote --heads "$DST_REPO" "$BRANCH" | wc -l);
if [ $BRANCH_EXISTS -eq 0 ]; then
    # We do not need to create a branch as we use `git push -u origin HEAD:$BRANCH`
    git clone --depth 1 "$DST_REPO" "$DST_DIR"
else
    git clone -b "$BRANCH" --depth 1 "$DST_REPO" "$DST_DIR";
fi

WS_ROOT="$(pwd)"
cd "$DST_DIR"

# Cleaning all files on the destination repository
# --ignore-unmatch avoid to fail if the repository is empty
git rm --ignore-unmatch -r .

rsync --exclude .git -a "$WS_ROOT/" "$DST_DIR/"

cat <<EOT >> .gitignore

.github/
application/ios/profiles/
application/android/*.jks

EOT

git add -A
git clean -f -d -x

git commit -a --message "$SRC_COMMIT_MSG
https://github.com/xaynetwork/xayn_discovery_app/commit/$SRC_COMMIT
https://github.com/xaynetwork/xayn_discovery_app/tree/$BRANCH"

if [ "$DRY_RUN" = "false" ]; then
    git push -u origin HEAD:$BRANCH
    git push -u origin HEAD:$BRANCH --tags
else
    echo "Prepared release at: $DST_DIR"
fi
