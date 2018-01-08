#!/bin/bash

IFS="
"

# Install the Logitech software if absent.
profilerpid=$(ps auxwww|grep -i l[o]git.*Profiler|sed 's/^[^ ]*  *//;s/ .*//'|tail -1)
if [ "" == "$profilerpid" ]
then
	echo "Installing Profiler."
	dmgpath=$(for i in $(mdfind -name GamePanel3.06.128-Multi.dmg)
				do
					md5 "$i"
				done|grep " = 462ab8147dbbc7c5a84e34d9a516f0ff$"|head -1|sed 's/^MD5 (//;s/) = .*//')

	if [ -f "$dmgpath" ]
	then
		open "$dmgpath"
	fi

	echo -n "Waiting for Profiler to start."
	profilerpid=$(ps auxwww|grep -i l[o]git.*Profiler|sed 's/^[^ ]*  *//;s/ .*//'|tail -1)
	while [ "" == "$profilerpid" ]
	do
		echo -n .
		sleep 1
		profilerpid=$(ps auxwww|grep -i l[o]git.*Profiler|sed 's/^[^ ]*  *//;s/ .*//'|tail -1)
	done
fi

if [ -d "/Applications/Jump Desktop.app" ]
then
	./retarget.sh "Visual Studio.lgp" "/Applications/Jump Desktop.app" "Visual Studio JumpDesktop"
fi
if [ -d "/Applications/Jump Desktop Beta.app" ]
then
	./retarget.sh "Visual Studio.lgp" "/Applications/Jump Desktop Beta.app" "Visual Studio JumpDesktopBeta"
fi

mkdir -p ~/Library/Application\ Support/Logitech/G-series\ Software/Keyboard/Profiles
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

# Make sure the application won't show up in the Dock or switcher
infoPlist=/Applications/Logitech/GamePanel\ Software/G-series\ Software/G-series\ Key\ Profiler.app/Contents/Info.plist
content=$(cat "$infoPlist"|plutil -convert xml1 - -o -)
echo "$content"|grep -q LSUIElement
if [ 0 -ne $? ]
then
	content=$(echo "$content"|sed -n '1,/^	/ p;/^	/p'|uniq;echo "	<key>LSUIElement</key>";echo "	<string>1</string>";echo "$content"|sed '1,/^	/d;/^	/d')
	echo "$content" > "$infoPlist"
	defaults read "$infoPlist"
fi

# Set the backlight colors if not already set.
prefPlist=~/Library/Preferences/com.logitech.G-seriesKeyProfiler.plist
content=$(cat "$prefPlist"|plutil -convert xml1 - -o -)
echo "$content"|grep -q BacklightColorOnM1_LHC
if [ 0 -ne $? ]
then
	content=$(echo "$content"|sed -n '1,/^	/ p;/^	/p'|uniq
		echo "	<key>BacklightColorOnM1_LHC</key>
	<data>
	YnBsaXN0MDDUAQIDBAUIFxhUJHRvcFgkb2JqZWN0c1gkdmVyc2lvblkkYXJjaGl2ZXLR
	BgdUcm9vdIABowkKEVUkbnVsbNMLDA0ODxBcTlNDb2xvclNwYWNlVU5TUkdCViRjbGFz
	cxABRjEgMSAxAIAC0hITFBVYJGNsYXNzZXNaJGNsYXNzbmFtZaIVFldOU0NvbG9yWE5T
	T2JqZWN0EgABhqBfEA9OU0tleWVkQXJjaGl2ZXIIERYfKDI1OjxARk1aYGdpcHJ3gIuO
	lp+kAAAAAAAAAQEAAAAAAAAAGQAAAAAAAAAAAAAAAAAAALY=
	</data>
	<key>BacklightColorOnM2_LHC</key>
	<data>
	YnBsaXN0MDDUAQIDBAUIGBlUJHRvcFgkb2JqZWN0c1gkdmVyc2lvblkkYXJjaGl2ZXLR
	BgdUcm9vdIABowkKEVUkbnVsbNMLDA0ODxBcTlNDb2xvclNwYWNlVU5TUkdCViRjbGFz
	cxABTxASMSAwLjAzNTM1MTYzNDAzIDAAgALSEhMUF1gkY2xhc3Nlc1okY2xhc3NuYW1l
	ohUWV05TQ29sb3JYTlNPYmplY3RXTlNDb2xvchIAAYagXxAPTlNLZXllZEFyY2hpdmVy
	CBEWHygyNTo8QEZNWmBnaX6AhY6ZnKSttboAAAAAAAABAQAAAAAAAAAaAAAAAAAAAAAA
	AAAAAAAAzA==
	</data>
	<key>BacklightColorOnM3_LHC</key>
	<data>
	YnBsaXN0MDDUAQIDBAUIFxhUJHRvcFgkb2JqZWN0c1gkdmVyc2lvblkkYXJjaGl2ZXLR
	BgdUcm9vdIABowkKEVUkbnVsbNMLDA0ODxBcTlNDb2xvclNwYWNlVU5TUkdCViRjbGFz
	cxABTxAcMC43MTg1MjQzMzY4IDAgMC45MTUyNjQ0Mjc3AIAC0hITFBVYJGNsYXNzZXNa
	JGNsYXNzbmFtZaIVFldOU0NvbG9yWE5TT2JqZWN0EgABhqBfEA9OU0tleWVkQXJjaGl2
	ZXIIERYfKDI1OjxARk1aYGdpiIqPmKOmrre8AAAAAAAAAQEAAAAAAAAAGQAAAAAAAAAA
	AAAAAAAAAM4=
	</data>"
		echo "$content"|sed '1,/^	/d;/^	/d')
	echo "$content" > "$prefPlist"
	defaults read "$prefPlist"
fi

echo -n "Waiting for Profiler to restart."
count=0
profilerpid=$(ps auxwww|grep -i l[o]git.*Profiler|sed 's/^[^ ]*  *//;s/ .*//'|tail -1)
while [ "" == "$profilerpid" ]
do
	count=$((count+1))
	if [ $count -eq 75 ]
	then
		echo "Profiler has not restarted automatically within 75 seconds.  Suggest the user type cmd-space profiler enter to launch."
	fi
	echo -n .
	sleep 1
	profilerpid=$(ps auxwww|grep -i l[o]git.*Profiler|sed 's/^[^ ]*  *//;s/ .*//'|tail -1)
done

echo
echo "Done."
