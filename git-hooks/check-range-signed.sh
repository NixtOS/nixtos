# Checks whether a range of commits is signed according to the requirements set
# forth in `keys`.
# Takes two arguments, checks range $1..$2. Both must be valid revisions
function check_range_signed() {
    from="$1"
    to="$2"

    if [ "$from" = "$to" ]; then
        return 0
    fi

    export GNUPGHOME="$(mktemp -d /tmp/check-range-signed.XXXXXXXX)"

    rebuild_gpg_keyring_at "$GNUPGHOME" "$from"

    git rev-list --first-parent "$from..$to" -- keys/keys | \
            tac | \
            while read commit; do
        echo "  Commit '$commit' changed the keys directory, checking it..."
        if git verify-commit "$commit" > /dev/null 2>&1; then
            echo "    OK"
        else
            echo "    Unable to verify commit '$commit' which changed the keys directory!" >&2
            rm -Rf "$GNUPGHOME"
            return 1
        fi

        rebuild_gpg_keyring_at "$GNUPGHOME" "$commit"
    done || return 1

    if ! git verify-commit "$to" > /dev/null 2>&1; then
        echo "  Unable to verify tip commit '$commit'!" >&2
        rm -Rf "$GNUPGHOME"
        return 1
    fi

    rm -Rf "$GNUPGHOME"
    return 0
}

function rebuild_gpg_keyring_at() {
    keyring="$1"
    commit="$2"

    rm -rf "$keyring/*"

    git show "$commit:keys/keys" | tail -n +3 | \
        xargs -I '{}' git show "$commit:keys/keys/{}" | \
        gpg2 --homedir "$keyring" --import --quiet
}
