#!/usr/bin/env bash
set -e

## Author: Tommy Miland (@tmiland) - Copyright (c) 2019


######################################################################
####                    Invidious Ban Check                       ####
####            Check if server IP is banned on Google            ####
####                   Maintained by @tmiland                     ####
######################################################################


version='1.0.1'
#------------------------------------------------------------------------------#
#
# MIT License
#
# Copyright (c) 2019 Tommy Miland
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#------------------------------------------------------------------------------#
# Detect absolute and full path as well as filename of this script
cd "$(dirname $0)"
CURRDIR=$(pwd)
SCRIPT_FILENAME=$(basename $0)
cd - > /dev/null
sfp=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || greadlink -f "${BASH_SOURCE[0]}" 2>/dev/null)
if [ -z "$sfp" ]; then sfp=${BASH_SOURCE[0]}; fi
SCRIPT_DIR=$(dirname "${sfp}")
# Command arguments
check=$(echo "$1")
force=$(echo "$2")
# Set random video ID's
array[0]="Z5H8xL-eMmU"
array[1]="C-n3AMxdgsY"
array[2]="ocHpxhgm92k"
array[3]="CyOUa2lmyPM"
array[4]="6CdfsCz1oKo"
array[5]="mz7OHTFAPM4"

vid=${#array[@]}
index=$(($RANDOM % $vid))

# URL to use
# url="https://www.youtube.com/watch?v=${array[$index]}"
url="https://www.youtube.com/watch?v=${array[$index]}&gl=US&hl=en&disable_polymer=1&has_verified=1&bpctr=9999999999"
# Keyword to check for
keyword="captcha"
#keyword="g-recaptcha"
# Path to Invidious config
config_path="/home/invidious/invidious/config"

email=root

# Make sure that the script runs with root permissions
chk_permissions () {
  if [[ "$EUID" != 0 ]]; then
    echo -e " This action needs root permissions. Please enter your root password...";
    cd "$CURRDIR"
    su -s "$(which bash)" -c "./$SCRIPT_FILENAME"
    cd - > /dev/null

    exit 0;
  fi
}

get_force_resolve_IPv4() {
  echo $(grep -Fxq "force_resolve: ipv4" "$1" && echo $?)
}

# Get force_resolve IPv4
force_resolve_IPv4=$(get_force_resolve_IPv4 "${config_path}/config.yml")

get_force_resolve_IPv6() {
  echo $(grep -Fxq "force_resolve: ipv6" "$1" && echo $?)
}

# Get force_resolve IPv6
force_resolve_IPv6=$(get_force_resolve_IPv6 "${config_path}/config.yml")

# Check input
check_input() {
  echo ""
  echo -e " Invidious Ban Check"
  echo ""
  echo -e " Usage: ./invidious_ban_check.sh [check] [force]"
  echo ""
  echo -e " Info: [ check: Just check if the IP is banned ]"
  echo -e " Info: [ force: Change force_resolve in config.yml ]"
  echo -e " E.G: If Google ban on IPv4, change to force_resolve: IPv6"
  echo ""
}

input_check=$(check_input)

#check command input
if [[ -z "$1" ]];
then
  echo -e "${input_check}"
  exit 0
fi

main() {

  if [ "$1" == "check" ]; then
    if curl -s -4 "$url" | grep "$keyword" && curl -s -6 "$url" | grep "$keyword"; then
      echo "Both IPv4 and IPv6 is banned on Google... Skipping" | mail -s "Both IPv4 and IPv6 is banned on Google... On $(hostname)" $email
      exit
    elif curl -Ls -4 "$url" | grep "$keyword" > /dev/null 2>&1; then
      # if the keyword is in the content
      echo " Google ban on IPv4"
      if [ "$2" == "force" ]; then
        # Skip if already set to IPv6
        if [[ $force_resolve_IPv6 != 0 ]]; then
          echo " Changing force_resolve: to IPv6"
          cd ${config_path} || exit 1
          sudo -i -u invidious \
            sed -i "s/force_resolve: ipv4/force_resolve: ipv6/g" ${config_path}/config.yml
          systemctl restart invidious
          echo " Done"
          # Send email notification
          echo "Google ban on IPv4. force_resolve was set to IPv6 on $(hostname)" | mail -s "Google ban on $(hostname)" $email
        else
          echo " Force resolve is already set to IPv6... Skipping"
        fi
      fi
    elif curl -Ls -6 "$url" | grep "$keyword" > /dev/null 2>&1; then
      # if the keyword is in the content
      echo " Google ban on IPv6"
      if [ "$2" == "force" ]; then
        # Skip if already set to IPv4
        if [[ $force_resolve_IPv4 != 0 ]]; then
          echo " Changing force_resolve: to IPv4"
          cd ${config_path} || exit 1
          sudo -i -u invidious \
            sed -i "s/force_resolve: ipv6/force_resolve: ipv4/g" ${config_path}/config.yml
          systemctl restart invidious
          echo " Done"
          # Send email notification
          echo "Google ban on IPv6.\n force_resolve was set to IPv4 on $(hostname)" | mail -s "Google ban on $(hostname)" $email
        else
          echo " Force resolve is already set to IPv4... Skipping"
        fi
      fi
    else
      echo "IP not banned on Google"
    fi
  else
    echo -e "${input_check}"
  fi
}
chk_permissions
main $@
exit
