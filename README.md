# NoSSL

This repository is for a project I created a long ago as an easy way to setup SSLstrip and SSLsplit so here it is.


```
usage: [ba[sh]] ./OpenBot[debug].sh [--strip]  [--split]
DO NOT use --strip and --split at the same time
```

**Requirements**
* Have python installed with: scapy, dnspython and twisted
on debian:
`
sudo apt-get install python-scapy python-dnspython python-twisted 
`
* Have dsniff installed (for arpspoof) on debian:
`sudo apt-get install dsniff`

Full Install(debian):
 `sudo apt-get install python-scapy python-dnspython python-twisted dsniff sslsplit`
 
**WARNINGS**  
* ONLY use an networks where you are allowed to test it on(e.g. pen-tester)
* to use the SSLsplit requires to have it installed, Kali 2016.2 recommended


Disclaimer

Note: NoSSL is intended to be used for legal security purposes only, and you should only use it to protect networks/hosts you own or have permission to test. Any other use is not the responsibility of the developer(s). Be sure that you understand and are complying with the NoSSL licenses and laws in your area. In other words, i copied this from cSploit (https://github.com/cSploit/android) 
