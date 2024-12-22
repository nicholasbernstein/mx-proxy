#!/bin/bash

PROJECT="perfect-lantern-344315"
ZONE="northamerica-south1-c" # mexico
SIZE="e2-small"
BROWSERCMD="chromium --proxy-server=localhost:3128"
QRCMD="qrencode https://github.com/nicholasbernstein/mx-proxy -t UTF8 2>*1"

start() {
gcloud compute instances create mx-vm1 \
--project="$PROJECT" \
--zone="$ZONE" \
--machine-type="$SIZE" \
--network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
--metadata=startup-script=apt-get\ update\ -yq\ \;\ apt-get\ install\ -yq\ squid \
--can-ip-forward \
--no-restart-on-failure \
--maintenance-policy=TERMINATE \
--provisioning-model=SPOT \
--instance-termination-action=STOP \
--max-run-duration=172800s \
--service-account=176241982757-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
--create-disk=auto-delete=yes,boot=yes,device-name=instance-20241221-225552,image=projects/debian-cloud/global/images/debian-12-bookworm-v20241210,mode=rw,size=10,type=pd-balanced \
--no-shielded-secure-boot \
--shielded-vtpm \
--shielded-integrity-monitoring \
--labels=goog-ec-src=vm_add-gcloud \
--reservation-affinity=any

cat <<EOT
Run "$0 browse" or manually:

  gcloud compute ssh --zone $ZONE mx-vm1 -- -f -N -L 3128:localhost:3128

Proxy:
  Configure browser to use http/https proxy: localhost:3128

EOT
}

stop() {
  gcloud compute instances stop --zone $ZONE mx-vm1
  gcloud compute instances delete --delete-disks=all --quiet --zone $ZONE mx-vm1
}

browse() {
  gcloud compute ssh --zone $ZONE mx-vm1 -- -f -N -L 3128:localhost:3128
  $BROWSERCMD

}

usage() {

        echo "$0 (start|stop|browse)"
        echo -e "documentation: https://github.com/nicholasbernstein/mx-proxy \n\n"
        $QRCMD
}
if (! $(which gcloud 1>/dev/null) ) ; then
  echo -e "Google Cloud SDK must be installed and you need a working google cloud account\n https://cloud.google.com/sdk/docs/install"
  exit 1
fi

if [ ! -e $1 ] ; then
  usage
fi

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    browse)
        browse
        ;;
    *)
        usage
        ;;
esac

