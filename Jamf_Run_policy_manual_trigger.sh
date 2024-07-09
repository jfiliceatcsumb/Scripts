﻿#!/bin/bash

# This script runs a manual policy trigger to
# allow the policy or policies associated with that
# trigger to be executed.

trigger_name="$4"


/usr/local/bin/jamf policy -verbose -event "$trigger_name"
