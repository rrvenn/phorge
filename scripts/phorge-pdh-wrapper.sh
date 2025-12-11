#!/bin/sh
# Start phd
/var/www/phorge/phorge/bin/phd start

# Wait a moment for the daemon to start
sleep 2

# Get pid of the first phd-daemon
PID=$(/var/www/phorge/phorge/bin/phd status | awk 'NR==2 {print $1}')

# Create directory for pid file
mkdir /var/run/phd

# Write pid to a file supervisord can track
echo $PID > /var/run/phd/phd.pid

# Wait forever so supervisord can track it
tail -f /dev/null