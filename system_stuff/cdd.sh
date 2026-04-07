cdd() {
    local dir
    dir="$(
      find . \
        -type d \
        -not -path '*/.git*' \
        -not -path '*/node_modules*' \
        -not -path '*/dist*' \
        | sed 's#^\./##' \
        | fzf
    )" || return 1
    [ -n "$dir" ] && cd "$dir"
}
