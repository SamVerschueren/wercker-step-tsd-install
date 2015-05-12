# Function to detect if the package is installed
function npm_package_is_installed {
    if [ $(npm list --depth 0 --parseable true "${2}" | grep "${1}$") ]; then
        return 1
    else
        return 0
    fi
}

# First make sure tsd is installed
if ! type tsd &> /dev/null ; then
    # Check if it is in repo
    if ! $(npm_package_is_installed tsd) ; then
        info "tsd not installed, trying to install it through npm"

        sudo npm install -g --silent tsd
        tsd_command="tsd"
    else
        info "tsd is available locally"
        debug "tsd version: $(node ./node_modules/.bin/tsd --version)"
        tsd_command="node ./node_modules/.bin/tsd"
    fi
else
    # tsd is available globally
    info "tsd is available"
    debug "tsd version: $(tsd --version)"
    tsd_command="tsd"
fi

# Reinstall the tsd files
set +e
$tsd_command reinstall
result="$?"
set -e

# Fail if it is not a success or warning
if [[ result -ne 0 && result -ne 6 ]]; then
    warn "$result"
    fail "tsd command failed"
else
    success "finished $tsd_command"
fi
