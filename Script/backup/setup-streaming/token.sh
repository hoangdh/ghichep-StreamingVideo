#!/bin/bash

timestamp=`date +%s`
expire=$(($timestamp+300)) # Exprire 5'
key=`echo -n "ByHoangDH/$1$expire" | openssl dgst -md5 -binary | openssl enc -base64 | tr '+/' '-_' | tr -d '='`
echo "$1?e=$expire&st=$key"