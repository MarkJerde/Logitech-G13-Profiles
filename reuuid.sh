#!/bin/bash

sedex=$(cat "$1"|grep " guid="|sed 's/.* guid="//;s/".*//'|perl -pe '$uuid=`uuidgen`;chomp($uuid);$_="$uuid $_";'|sed 's/^\([0-9A-F][0-9A-F\-]*\) \(.*\)/s|\2|\1|/'|tr '\n' ';');cat "$1"|sed $sedex

