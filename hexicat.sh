#!/usr/bin/env bash

# SECURITY WARNING: Any user allowed to run 'sudo hexicat' can read any file root has access to (but not write or edit)

socat_prompt() {
    local host="$1"
    local port="$2"
    local message

    echo $host
    echo $port

    # Start one persistent SOCAT connection
    coproc SOCAT {
        socat - "TCP:${host}:${port}"
    }

    local socat_in=${SOCAT[0]}
    local socat_out=${SOCAT[1]}
    local socat_pid=$SOCAT_PID

    exec {reader_fd}<&"$socat_in"

    # Background reader
    {
        while IFS= read -r response; do
            printf '\n[REMOTE] %s\n' "$response"
        done <&"$reader_fd"

        echo "[!] Connection closed"
    } &

    local reader_pid=$!


    local ascii_mode=0

    echo "[+] Connected to ${host}:${port}"
    echo '[+] Enter hexbytes to transmit, or !help for command list'

    while true; do
	if [[ $ascii_mode -eq 0 ]]; then
        	read -r -p "Hexbytes> " message
	elif [[ $ascii_mode -eq 1 ]]; then
		read -r -p "ASCII Text> " message
	fi;

	if [ "$message" == "!help" ]; then
		echo '!ascii		- Stop converting bytes; send whatever I type as raw ASCII '
		echo '!hex		- Hex mode (default): convert my hex string into raw bytes before sending'
		echo '				Ex:  48656c6c6f21 -> Hello!'
		echo '!exit		- Terminate connection and close Hexicat'
		echo '!file [/file/path]- Send the contents of a file through the Hexicat terminal' 
	elif [ "$message" == "!ascii" ]; then
		ascii_mode=1
	elif [ "$message" == "!hex" ]; then
		ascii_mode=0
	elif [ "$message" == "!exit" ]; then
		break
	else
		if [ "$message" == "\\file "* ]; then
			message=$( echo "${str#\file }" | cat )
		fi;
		if [[ $ascii_mode -eq 0 ]]; then
			message=$( echo $message | xxd -r -p )
		fi;

       		# Send message through the existing connection
        	printf '%s\n' "$message" >&"$socat_out" || {
        		echo "[-] Connection lost"
        		break
        		}
	fi;
    done

    # Close connection
    exec {socat_out}>&-
    exec {socat_in}<&-

    wait "$socat_pid" 2>/dev/null
    echo "[+] Disconnected"
}

if [ $# -ne 2 ]; then
	echo "Usage: 'hexicat [IP] [PORT]'"
else
	socat_prompt $1 $2
fi

