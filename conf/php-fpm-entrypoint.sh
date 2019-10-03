#!/bin/sh

set -e

# ### RUN STACK CONFIG ###
if [ -f "/startup.sh" ]
then
	/startup.sh
fi

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
# "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
    local var="$1"
    local fileVar="${var}_FILE"
    eval local varValue="\$${var}"
    eval local fileVarValue="\$${var}_FILE"
    local def="${2:-}"
    if [ "${varValue:-}" ] && [ "${fileVarValue:-}" ]; then
        echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
        exit 1
    fi
    local val="$def"
    if [ "${varValue:-}" ]; then
        val="${varValue}"
    elif [ "${fileVarValue:-}" ]; then
        val="$(cat "${fileVarValue}")"
    fi
    echo "$var"
    echo "$val"
    export "$var"="$val"
    if [ "${fileVar:-}" ]; then
        unset "$fileVar"
    fi
}

file_env "MOODLE_DB_PASSWORD"



exec "$@"
