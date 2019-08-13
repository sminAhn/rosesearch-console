@echo off
IF NOT EXIST temp mkdir temp

echo fastcatsearch-console start. see logs/server.log file.

REM SET JAVA_PATH=C:\Program Files\Java\jdk1.6.0_29\bin\

"%JAVA_PATH%java.exe" -Dorg.eclipse.jetty.server.Request.maxFormKeys=2000 -Dfile.encoding=UTF-8 -jar start.jar>>logs/server.log 2>&1
