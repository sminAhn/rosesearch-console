#!/bin/sh
kill `ps -ef|grep fastcatsearch-console|grep start.jar|awk '{print $2}'`