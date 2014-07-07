#!/bin/bash

if [! hash python >/dev/null 2>&1 ]
then
  echo "Tests require casper.js to run. Install casper.js with either"
  echo "'brew update && brew install casperjs'       (homebrew)"
  echo "or '[sudo] npm install -j casperjs'          (npm)"
fi

cd test/app
mrt --port=3500 > /dev/null &
cd ../..
casperjs test test/test.coffee

# Kills mrt and all the child processes
# From http://stackoverflow.com/a/15139734/2624068
kill -- -$(ps -o pgid= $! | grep -o [0-9]*) 2> /dev/null > /dev/null 3> /dev/null
