#!/bin/bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# SPDX-License-Identifier: GPL-2.0-or-later


IP_WAN="8.8.8.8"

PING_WAN=$(ping -4 -c 1 -W 5 ${IP_WAN}|head -n 2|tail -n 1|rev|cut -f 2 -d " " |rev|cut -f 2 -d "=")

if [ "${PING_WAN}" = "" ]; then
    RESULT="[ No internet connection ]"
else
    # Check DNS
    if [ "$(host -R3 -4 -t A google.com |grep address)" = "" ];then
        RESULT="[ DNS Problem ]"
    else
  	    RESULT="Latency: ${PING_WAN}ms"
    fi
fi

echo -n "${RESULT}"