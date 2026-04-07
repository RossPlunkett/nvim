repos_with_changes() {
    find . -type d -name .git -prune | while read -r gitdir; do
        repo="${gitdir%/.git}"
        if [ -n "$(git -C "$repo" status --porcelain)" ]; then
            echo "Uncommitted changes in: $repo"
            git -C "$repo" diff --stat
            echo
        fi
    done
}

repos_with_changes_paths() {
    find . -type d -name .git -prune | while read -r gitdir; do
        repo="${gitdir%/.git}"
        [ -n "$(git -C "$repo" status --porcelain)" ] && echo "$repo"
    done
}
