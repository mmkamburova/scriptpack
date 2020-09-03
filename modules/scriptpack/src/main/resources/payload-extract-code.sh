extractPayload()
{
    case "`uname`" in
        SunOS | AIX | HP-UX ) legacy=1 ;;
        *) legacy=0 ;;
    esac

    if [ "$legacy" -eq 1 ]
    then
        astext="" # does not support --text option, but works ok without it
    else
        astext="--text" # linux/osx requires this option to work properly
    fi 
    match=`head -n 1000 $0 | grep $astext -n '^PAYLOAD:$' | cut -d ':' -f 1`

    if [ ! -z "$match" ]
    then
        payload_start=`expr $match + 1`
        echo "Extracting binaries to ${APP_HOME}..."
        mkdir -p "$APP_HOME"
        if [ "$legacy" -eq 1 ]
        then
            tail +$payload_start $0 >"$APP_HOME/payload.pax"
            [ -z "$OLDPWD" ] && OLDPWD=`pwd`
            cd "$APP_HOME"
            pax -rvf payload.pax || {
                echo "The payload may be corrupted."
                exit 1
            }
            cd "$OLDPWD"
        else
            tail -n +$payload_start $0 | tar -xzf - -C "$APP_HOME" || {
                echo "The payload may be corrupted."
                exit 1
            }
        fi
        echo "Extracted."
    else
        echo "No payload found."
    fi
}