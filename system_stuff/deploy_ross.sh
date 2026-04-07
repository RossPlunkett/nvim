build_snakesteroids() {
    (cd /home/felix/Desktop/temp/csoundfreak/src/games/snakesteroids && npm run build)
}

deploy_ross() {
    local project_dir="/home/felix/Desktop/temp/csoundfreak"

    if [ "$1" = "--snakesteroids" ]; then
        build_snakesteroids || return 1
    fi

    (
        cd "$project_dir" || return 1
        npm run build || return 1
        rsync -av --delete \
          --include='/assets/***' \
          --include='/index.html' \
          --include='/vite.svg' \
          --include='/lib/***' \
          --include='/games/***' \
          --exclude='*' \
          dist/ ross:~/ross-o-fone.io/
    )
}
