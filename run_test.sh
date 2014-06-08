#!/bin/bash

cd test/app
mrt > /dev/null &
cd ../..
casperjs test test/test.coffee
kill -- -$(ps -o pgid= $! | grep -o [0-9]*) 2> /dev/null > /dev/null 3> /dev/null
