#!/bin/sh

ssh -f -NCT -ng -D 0.0.0.0:30001 root@127.0.0.1 -p27825 -o ServerAliveInterval=60
