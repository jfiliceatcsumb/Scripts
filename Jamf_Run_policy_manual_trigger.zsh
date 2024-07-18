#!/bin/zsh
# shellcheck shell=bash
# shellcheck disable=SC2034,SC2296
# these are due to the dynamic variable assignments used in the localization strings

# This script runs a manual policy trigger to
# allow the policy or policies associated with that
# trigger to be executed.

SCRIPTNAME=`/usr/bin/basename "$0"`
SCRIPTDIR=`/usr/bin/dirname "$0"`

# Jamf JSS Parameters 1 through 3 are predefined as mount point, computer name, and username

pathToScript=$0
mountPoint=$1
computerName=$2
userName=$3

echo "pathToScript=$pathToScript"
echo "mountPoint=$mountPoint"
echo "computerName=$computerName"
echo "userName=$userName"

set -x 

trigger_name="$4"

escape_args() {
    temp_string=$(awk 'BEGIN{FS=OFS="\""} {for (i=1;i<=NF;i+=2) gsub(/ /,"§",$i)}1' <<< "$1")
    # temp_string=$(awk -F\" '{OFS="\""; for(i=2;i<NF;i+=2)gsub(/ /,"++",$i);print}' <<< "$1")
    temp_string="${temp_string//\\ /++}"
    echo "$temp_string"
}

arguments=()
count=1
for i in {5..10}; do
    # first of all we replace all spaces with a § symbol
    eval_string="${(P)i}"
    parsed_parameter="$(escape_args "$eval_string")"

    # now we have split up the parameter we can put the spaces back
    for p in $parsed_parameter; do
        arguments+=("${p//§/ }")
    done
done

echo

# "${eraseinstall_path}" "${eraseinstall_args[@]}"

rc=$?

echo
echo "[$0] Exit ($rc)"
exit $rc

echo /usr/local/bin/jamf policy -verbose -event "$trigger_name" "${arguments[@]}"

