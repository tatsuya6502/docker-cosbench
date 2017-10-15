#!/bin/sh

echo "conf/driver.conf =============================="
cat conf/driver.conf

echo "conf/controller.conf =========================="
cat conf/controller.conf

echo "Starting both driver and controller."

./start-all.sh


echo "log/system.log ================================"

while [ ! -f log/system.log ]; do
    sleep 10
done

tail -f log/system.log
