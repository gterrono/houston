#!/bin/bash

function kill_mrt {
  # Kills mrt and all the child processes
  MRT_ID=$1
  # print all process id/group ids for current user
  # | only find ones with our meteor id in them (as pid or pgid)
  # | fix formatting so we get all pids we'll need to 'kill'
  # | kill each one
  # > don't show normal output to user
  ps -o pid,pgid | grep $MRT_ID | cut -f 1 -d " " | xargs kill > /dev/null
}

function run_test {
  TEST_FILE=$1
  CUSTOM_TEST_ARGS="$2"
  cd test/app
  # clear any past DB state
  rm -r .meteor/local > /dev/null
  # meteor, not mrt, so there are fewer child processes to chase down
  meteor --port=3500 $CUSTOM_TEST_ARGS > /dev/null &
  MRT_ID=$!
  cd ../..
  casperjs test test/$TEST_FILE
  echo "casper tests done running"
  kill_mrt $MRT_ID
}

if [! hash python >/dev/null 2>&1 ]
then
  echo "Tests require casper.js to run. Install casper.js with either"
  echo "'brew update && brew install casperjs'       (homebrew)"
  echo "or '[sudo] npm install -g casperjs'          (npm)"
fi

run_test test_base.coffee ""
run_test test_custom_root_route.coffee "--settings settings.json"
