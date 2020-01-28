run_mysql_server_docker.sh mysql_db_rnaseq
screen -RD caper_server
caper server 2>caper.err 1>caper.out
# ctrl A + D to detach - can we do this automatically?