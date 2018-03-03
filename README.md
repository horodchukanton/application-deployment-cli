**App::Deployment**

Simple perl module for managing application state on application server.
Includes command line utility.

At this point supports only Apache Tomcat server

Usage:

    ./deploytool.pl - script for managing deployed application.

    Arguments:
    --config,     path to a config file in .bashrc style (key=value\n)
    --action      string, deploy|check|undeploy|start
    --application string, hello-world.war

    --server      string, name of server plugin to use
    --plugin=s    string, allow to pass custom args to plugin (--plugin upload=~/app.war --plugin ssl=1)

    --hostname    server IP or FQDN
    --port        server port

    --user
    --password

    --debug=i