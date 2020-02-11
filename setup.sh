#!/usr/bin/env bash
set -eou pipefail

function clean() {
    echo "Cleaning existing files"
    rm -f /usr/lib/tmpfiles.d/airflow.conf
    for fn in $(ls systemd/*.service)
    do
        rm -f /etc/systemd/system/$(basename $fn)
    done

    systemctl stop airflow-webserver.service || /bin/true
    systemctl stop airflow-scheduler.service || /bin/true
    systemctl disable airflow-webserver.service || /bin/true
    systemctl disable airflow-scheduler.service || /bin/true
}

clean
ln -s $PWD/systemd/airflow.conf /usr/lib/tmpfiles.d/airflow.conf

# transfer systemd files over
for fn in $(ls systemd/*.service)
do
    target=/etc/systemd/system/$(basename $fn)
    echo ln -s $PWD/$fn $target
    ln -s $PWD/$fn $target
done

systemctl daemon-reload
systemctl start airflow-webserver.service
systemctl enable airflow-webserver.service

systemctl start airflow-scheduler.service
systemctl enable airflow-scheduler.service

systemctl status airflow-webserver.service
systemctl status airflow-scheduler.service
