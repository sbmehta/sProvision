#!/usr/bin/env bash

# recursive_packages_size.sh package1 package2 ...
# recursive_packages_size.sh -n package1 package2 ...

# takes a list of packages & estimates the download & installed sizes
# -n flag tries to remove already-installed packages
# Note: imprecise b/c takes only first of multi-options

set -e

if [ $1 = '-n' ] ; then   # prepare the installed list & shift away the flag
    installedlist=$(dpkg-query -W | awk {'print $1'} | sed 's/\:.*$//' | sort -u)
    shift
fi

dependlist=$(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances -o APT::Cache::ShowOnlyFirstOr=true $@ | grep "^\w" | sort -u)

if [ -v installedlist ] ; then
    dependlist=$(comm -23 <(echo "$dependlist") <(echo "$installedlist") )
fi

download_sizes=$(apt-cache show --no-all-versions $(echo "$dependlist" | paste -sd' ') | grep "^Size")
installed_sizes=$(apt-cache show --no-all-versions $(echo "$dependlist" | paste -sd' ') | grep "^Installed-Size")

paste <(echo "$dependlist") <(echo "$download_sizes") <(echo "$installed_sizes") | column -s $'\t' -t
echo "$download_sizes" | sed -e 's/^Size: //' | paste -sd+ | bc -l | numfmt --to=si --format="Total download ${SIZETYPE}: %5.3f bytes"
echo "$installed_sizes" | sed -e 's/^Installed-Size: //' -e 's/$/*1000/' | paste -sd+ | bc -l | numfmt --to=si --format="Total installed ${SIZETYPE}: %5.3f bytes"

exit 0
