# Fastcatsearch-console [![Build Status](https://travis-ci.org/fastcat-co/fastcatsearch-console.png)](https://travis-ci.org/fastcat-co/fastcatsearch-console)

Fastcatsearch-console is a tool for managing fastcatsearch. You can make collections on fastcatsearch, edit configs, and index documents.

## Notice

This is a managment tool on embedded web server jetty. Fastcatsearch-console cannot privide search features by itself, and you must install [fastcatsearch](https://github.com/fastcat-co/fastcatsearch) too.

## License

The license is GNU LGPL v2.1

It's free and you can use it however you want it wharever way.

You don't need to open your closed source unless you distribute derived works to others.

For more information, see <http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html>



## Building

1. Download source from github repository

2. Maven it


    $ cd fastcatsearch-console-{version}   
    $ maven install

3. Done

    Copy built directory to some where you want to install.
    Now, it's ready to run.
    


## Settings

* Port Check
    
    Default port is `8080`. If this port is used, you can change it in config file.
    
    In `etc/jetty.xml` file,  find line `<Set name="port"><Property name="jetty.port" default="8080"/></Set>` and change port number you want.



## Running 

1. Run shell script

    Linux : run script `start-console.sh` 
    Windows : run script `start-console.cmd` 

    see log at `logs/server.log`

2. Access console using web browser

    Open url `http://localhost:8080/console`
    
    If success, you can see login page.
    
3. Trouble Shooting

    If you see 500 error, check you run fastcatsearch-console using java jdk. In start-console.sh(cmd), modify java path like below.
    
    Windows : `"C:\Program Files\Java\jdk1.6.0_29\bin\java.exe" -jar start.jar>>logs/server.log 2>&1`
    
    Linux : `/usr/bin/java/java -jar start.jar>>logs/server.log 2>&1`
   



## Need Help?

You can find manuals and tutorials on the <http://www.fastcat.co> site.
