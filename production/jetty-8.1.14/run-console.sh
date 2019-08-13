#!/bin/sh
cd `dirname $0`
SERVER_HOME=`pwd`

if [ ! -d "temp" ]; then
	mkdir temp
fi

if [ -z "$heap_memory_size" ]; then
    heap_memory_size=256m
fi

JVM_OPTS="-Xms$heap_memory_size -Xmx$heap_memory_size -XX:+HeapDumpOnOutOfMemoryError"

# 스키마에 필드가 많아서 저장시 too many keys 에러가 발생한다면 org.eclipse.jetty.server.Request.maxFormKeys 수치를 올려준다.
java $JVM_OPTS -Dorg.eclipse.jetty.server.Request.maxFormKeys=2000 -Dfile.encoding=UTF-8 -jar $SERVER_HOME/start.jar 2>&1
