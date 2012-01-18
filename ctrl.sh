#!/bin/bash
## --------------------------------------------------------------------------------------------------------------------

# environment
set -e
. $HOME/.nvm/nvm.sh || true
nvm use v0.6.7 > /dev/null

## --------------------------------------------------------------------------------------------------------------------
# functions

function usage() {
    echo "Usage: $0 [action]"
    echo
    echo "actions:"
    echo "    initialise   - initialise this instance"
    echo "    start        - start the server"
    echo "    list         - lists all servers"
    echo "    restart      - restarts all servers"
    echo "    stop         - stops all servers"
    echo "    tail         - tails all the logs"
}

## --------------------------------------------------------------------------------------------------------------------

# firstly, check there is a command
if [ $# -lt 1 ]; then
    usage
    exit
fi

## --------------------------------------------------------------------------------------------------------------------
# environment variables

NODE_ENV=production
ACTION="$1";
PWD=`pwd`

## --------------------------------------------------------------------------------------------------------------------

# do whichever command we have chosen
case "$ACTION" in
    initialise)
        # install all the npm stuff we need
        npm -d install

        # Nginx
        sudo cp sys/etc/nginx/sites-available/site-cssminifier /etc/nginx/sites-available/
        if [ ! -e /etc/nginx/sites-enabled/site-cssminifier ]; then
            sudo ln -s /etc/nginx/sites-available/site-cssminifier /etc/nginx/sites-enabled/site-cssminifier
        fi
        sudo /etc/init.d/nginx restart
        ;;

    list)
        ./node_modules/.bin/forever list
        ;;

    start)
        # check to see if this port is already in use
        if ! lsof -i :3001 > /dev/null; then
            ./node_modules/.bin/forever \
                -a \
                -l $PWD/logs/forever-3001.log \
                -o logs/access-3001.log \
                -e logs/error-3001.log \
                start app.js 3001
        fi 

        if ! lsof -i :3002 > /dev/null; then
            ./node_modules/.bin/forever \
                -a \
                -l $PWD/logs/forever-3002.log \
                -o logs/access-3002.log \
                -e logs/error-3002.log \
                start app.js 3002
        fi
        ;;

    restart)
        ./node_modules/.bin/forever restart app.js
        ;;

    stop)
        ./node_modules/.bin/forever stop app.js
        ;;

    tail)
        tail -f logs/*.log
        ;;

    *)
        echo "Unknown action: $ACTION"
        echo
        usage
        ;;
esac

## --------------------------------------------------------------------------------------------------------------------
