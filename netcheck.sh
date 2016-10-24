#!/usr/bin/env bash
# Based on this post http://www.linuxquestions.org/questions/linux-networking-3/script-to-check-connection-and-restart-network-if-down-262281/

# Need to install host
# sudo apt-get update
# sudo apt-get install host

# Make this script executable chmod a+x netcheck.sh
# Add one of the following lines to /etc/crontab and replace INSTALLDIR
# */10 *   * * *   root    sudo INSTALLDIR/netcheck.sh >> INSTALLDIR/netchecklog.log
# */10 *   * * *   root    sudo INSTALLDIR/netcheck.sh >/dev/null 2>&1

# Script to monitor and restart wireless access point when needed
echo Checking network connection
maxPloss=50 #Maximum percent packet loss before a restart
installdir="/home/pi/git/rpiscripts"
testurl="www.google.com"
netiface="wlan0"

restart_networking() {
        # Add any commands need to get network back up and running
        date >> $installdir/netcheckout.txt
        #/etc/init.d/networking restart
        echo RESTART NETWORK
        #shutdown -r "now"
        ifdown --force $netiface
        ifup $netiface
        #only needed if your running a wireless ap
        #/etc/init.d/dhcp3-server restart
}

# First make sure we can resolve google, otherwise 'ping -w' would hang
if ! $(host -W5 $testurl > /dev/null 2>&1); then
        #Make a note in syslog
        logger "netcheck: Network connection is down, DNS lookup failed, restarting network ..."
        restart_networking
        echo DNS lookup FAILED
        exit
else
        echo DNS lookup OK
fi

# Initialize to a value that would force a restart
# (just in case ping gives an error and ploss doesn't get set)
ploss=101
# now ping google for 10 seconds and count packet loss
ploss=$(ping -q -w10 $testurl | grep -o "[0-9]*%" | tr -d %) > /dev/null 2>&1

if [ "$ploss" -gt "$maxPloss" ]; then
        logger "netcheck: Packet loss ($ploss%) exceeded $maxPloss, restarting network ..."
        restart_networking
        echo "Packet loss FAILED (loss:$ploss max:$maxPloss)"
else
        echo "Packet loss OK (loss:$ploss max:$maxPloss)"
fi

echo Network check DONE.
logger "netcheck: I ran"
