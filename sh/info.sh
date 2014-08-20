#!/bin/bash

SRCROOT="/Users/lifeng/Documents/192.168.1.113/code/实创/SCAnalysis"

displayName="SC_Analysis"
name="SC_Analysis"

#项目目录的名称
appdirname="Designer"




build="$SRCROOT/build"
production="$SRCROOT/production"





app_infoplist_path=${SRCROOT}/${appdirname}/${name}-Info.plist
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" ${app_infoplist_path})



local_ipa_path="$production/$name.ipa"
server_path="root@223.4.147.79:/data/tomcat/webapps/ipa/sc/analysis/$name.ipa"










