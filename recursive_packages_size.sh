#!/usr/bin/env bash

# recursive_packages_size.sh package1 package2 ...

# takes a list of packages & estimates the download & installed sizes to install
# all (recursive) dependencies not currently installed 

apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances $@ | grep "^\w" | sort -u > dependlist_raw

dpkg-query -W | awk {'print $1'} | sed 's/\:.*$//' > installedlist

comm -23 dependlist_raw installedlist > dependlist

apt-cache show --no-all-versions $(cat dependlist | paste -sd' ') | grep "^Size" > dependlist_download_sizes

apt-cache show --no-all-versions $(cat dependlist | paste -sd' ') | grep "^Installed-Size" > dependlist_installed_sizes

paste dependlist dependlist_download_sizes dependlist_installed_sizes | column -s $'\t' -t

cat dependlist_download_sizes | sed -e 's/^Size: //' | paste -sd+ | bc -l | numfmt --to=si --format="Total download ${SIZETYPE}: %5.3f bytes"

cat dependlist_installed_sizes | sed -e 's/^Installed-Size: //' -e 's/$/*1000/' | paste -sd+ | bc -l | numfmt --to=si --format="Total installed ${SIZETYPE}: %5.3f bytes"

rm dependlist_raw installedlist dependlist dependlist_download_sizes dependlist_installed_sizes

exit 0
