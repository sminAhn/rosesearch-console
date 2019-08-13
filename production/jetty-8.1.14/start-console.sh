#!/bin/sh
cd `dirname $0`
SERVER_HOME=`pwd`

if [ ! -d "temp" ]; then
	mkdir temp
fi

# 스키마에 필드가 많아서 저장시 too many keys 에러가 발생한다면 org.eclipse.jetty.server.Request.maxFormKeys 수치를 올려준다.
java -Dorg.eclipse.jetty.server.Request.maxFormKeys=2000 -Dfile.encoding=UTF-8 -jar $SERVER_HOME/start.jar > $SERVER_HOME/logs/server.log 2>&1 &

echo fastcatsearch-console start. see logs/server.log file.
