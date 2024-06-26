#!/bin/bash
 
# server connection information
URL="https://talkingmoose.jamfcloud.com"
userName="api-editor"
password="P@55w0rd"
command="EnableRemoteDesktop" # or "DisableRemoteDesktop"
 
# XML data to upload
THExml="<computer_command>
    <general>
        <command>$command</command>
    </general>
    <computers>
        <computer>
            <id>4</id>
        </computer>
        <computer>
            <id>7</id>
        </computer>
    </computers>
</computer_command>"
 
# flattened XML
flatXML=$( /usr/bin/xmllint --noblanks - <<< "$THExml" )
 
# API submission command
/usr/bin/curl "$URL/JSSResource/computercommands/command/$command" \
--user "$userName:$password" \
--header "Content-Type: text/xml" \
--request POST \
--data "$flatXML"
 
exit 0