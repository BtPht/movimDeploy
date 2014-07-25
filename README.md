movimDeploy
===========
author :  bertrand dot pechenot at gmail dot com

Script bash to automatically deploy a Movim node.

More information at :
https://movim.eu/
https://launchpad.net/movim
http://wiki.movim.eu/en:start


* General information and warnings

This installation is highly non standard and may fail under many cases.

The aim is to allow a complete beginner to deploy his own node with the very
basic configuration.

The password for the database is randomly generated and doesn't need to be changed

The password for the administration of the node is the default one and *MUST*
be changed as soon as the node is reachable from outside.

The webserver part of the script is not properly functional. I make the very
restrictive assumption that you use Apache2. If it's not the case you should
tune the script and set the variable $website_root to a correct value.

If you actually use Apache2 or don't have a webserver installed the script
will work fine as it.


* Description

The script will install all the dependencies Movim needs to run.

Some tools are required also. The one already installed will be used. And the
ones missing will be installed then removed to impact less the system.

The database is automatically configured.

Once the script successfully run, just go to http://localhost/movim?q=admin
to configure the last details.
Note that the default configuration for the first login is : admin/password

