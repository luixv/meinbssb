
There are two files:
    - /volume1/scripts/monitor_zmi.sh
    - /volume1/web/zmi/history.html
    - /volume1/web/zmi/https_monitor.csv

 The first script should be started using the scheduler, for example, every 5 minutes.
 This will add a new line to the https_monitor.csv.

For the time being this is running under my private Synology @home :-)

ssh luixv@192.168.188.2 -p <port>
