#!/bin/sh
set -e

export RANCHER_IP=$(wget -qO- http://rancher-metadata.rancher.internal/latest/self/container/primary_ip)
export RANCHER_SERVICE_NAME=$(wget -qO- http://rancher-metadata.rancher.internal/latest/self/service/name)

/opt/app/bin/financial_system_api $@