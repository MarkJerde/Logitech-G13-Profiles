#!/bin/bash

source="$1"
app="$2"
sigkey=$(dirname "$app")
sigval=$(basename "$app")
title="$3"

./reuuid.sh "$source"|sed 's|<signature key="[^"]*" subkey="" value="[^"]*" executable="[^"]*"|<signature key="'"$sigkey"'" subkey="" value="'"$sigval"'" executable="'"$sigval"'"|;s|<target>[^<]*<|<target>'"$app"'<|;s/\(<profile guid="[^"]*" name="\)[^"]*"/\1'"$title"'"/' > "$title.lgp"

