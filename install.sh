#!/bin/bash

IFS="
"

if [ -d "/Applications/Jump Desktop.app" ]
then
	./retarget.sh "Visual Studio.lgp" "/Applications/Jump Desktop.app" "Visual Studio JumpDesktop"
fi
if [ -d "/Applications/Jump Desktop Beta.app" ]
then
	./retarget.sh "Visual Studio.lgp" "/Applications/Jump Desktop Beta.app" "Visual Studio JumpDesktopBeta"
fi

for profile in *.lgp
do
	guid=$(grep -F "<profile guid=\"" $profile|sed 's/.*<profile guid="//;s/".*//')
	echo "Installing $profile."
	cp "$profile" ~/Library/Application\ Support/Logitech/G-series\ Software/Keyboard/Profiles/$guid.lgp
done

profilerpid=$(ps auxwww|grep -i l[o]git.*Profiler|sed 's/^[^ ]*  *//;s/ .*//'|tail -1)
if [ "" != "$profilerpid" ]
then
	echo "Restarting Profiler."
	kill "$profilerpid"
	profilerpid=$(ps auxwww|grep -i l[o]git.*Profiler|sed 's/^[^ ]*  *//;s/ .*//'|tail -1)
	while [ "" != "$profilerpid" ]
	do
		kill "$profilerpid"
		sleep 1
		profilerpid=$(ps auxwww|grep -i l[o]git.*Profiler|sed 's/^[^ ]*  *//;s/ .*//'|tail -1)
		if [ "" != "$profilerpid" ]
		then
			echo "Not dead yet."
			kill -9 "$profilerpid"
			profilerpid=$(ps auxwww|grep -i l[o]git.*Profiler|sed 's/^[^ ]*  *//;s/ .*//'|tail -1)
		fi
	done
else
	echo "No Profiler running."
fi

echo -n "Waiting for Profiler to restart."
profilerpid=$(ps auxwww|grep -i l[o]git.*Profiler|sed 's/^[^ ]*  *//;s/ .*//'|tail -1)
while [ "" == "$profilerpid" ]
do
	echo -n .
	sleep 1
	profilerpid=$(ps auxwww|grep -i l[o]git.*Profiler|sed 's/^[^ ]*  *//;s/ .*//'|tail -1)
done

echo
echo "Done."
