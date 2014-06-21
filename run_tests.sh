#!/bin/bash

cd test/app
mrt > /dev/null &
cd ../..
casperjs test test/test.coffee

# Kills mrt and all the child processes
# From http://stackoverflow.com/a/15139734/2624068
kill -- -$(ps -o pgid= $! | grep -o [0-9]*) 2> /dev/null > /dev/null 3> /dev/null
