#!/bin/sh

# Initialization.
APP_HOME=`pwd`
SHOW_HELP=0
ORIG_ARGS="$@"

# Handling command line arguments.
processOptions()
{
    if [ $# -eq 0 ]
    then
        SHOW_HELP=1
    fi
    while :
    do
        if [ "$1" = "-d" ]
        then
            APP_HOME="$2"
        elif [ "$1" = "-h" ] || [ "$1" = "--h" ] || [ "$1" = "--help" ]
        then
            SHOW_HELP=1
        elif [ -z "$1" ]
        then
            break
        fi
        shift
    done
}

# At this point a variable with name APP_HOME must be defined with value pointing to the location where to extract the payload, for example /home/joe/myapp
# IMPORTANT: The following line is a placeholder and will be replaced with the actual code for extracting the payload.
# PAYLOAD-EXTRACT-CODE

# All code that runs the application goes here. The following code is an example for running a generic Java application.
runApp()
{
    JAVA="${APP_HOME}/jvm/bin/java"
    unset CLASSPATH
    for jar_file in `ls ${APP_HOME}/libs/*.jar 2> /dev/null`
    do
        if [ -z "$CLASSPATH" ]
        then
            CLASSPATH=$jar_file
        else
            CLASSPATH="${CLASSPATH}:${jar_file}"
        fi
    done
    $JAVA -cp $CLASSPATH fqn.of.main.Class $ORIG_ARGS
    exit $?
}

showHelp()
{
    if [ $SHOW_HELP -eq 1 ]
    then
        echo "Usage: $0 [Options...]"
        echo ""
        echo "Options:"
        echo "       -h,--help                 This usage help."
        echo "       -d ~/myapp                Target installation directory."
        echo ""
        exit 0
    fi
}

main()
{
    processOptions "$@"
    showHelp
    extractPayload
    runApp
}

main "$@"

# The file must end with "PAYLOAD:" followed by a single new line.
PAYLOAD:
