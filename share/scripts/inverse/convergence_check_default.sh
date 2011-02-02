#! /bin/bash
#
# Copyright 2009 The VOTCA Development Team (http://www.votca.org)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if [ "$1" = "--help" ]; then
cat <<EOF
${0##*/}, version %version%
dummy script (does nothing), useful to overwrite default by nothing

Usage: ${0##*/}

USES: check_deps 


EOF
   exit 0
fi

check_deps "$0"

limit="$(csg_get_property cg.inverse.convergence_check_options.limit)"
glob="$(csg_get_property cg.inverse.convergence_check_options.name_glob "*.conv")"

#we don't have glob pattern or no file matching found
[ "$glob" = "$(echo $glob)" ] && [ ! -f "$glob" ] && die "${0##*/}: No file matching '$glob' found!\nHave you added convergence to the postadd list of at least one interaction?"
sum="$(for i in $glob; do
    cat $i 
done | awk 'BEGIN{sum=0}{sum+=$1}END{print sum}')"
echo "Convergence sum was $sum, limit is $limit"
result="$(awk -v sum="$sum" -v limit="$limit" 'BEGIN{print (sum<limit)?"stop":"go-on"}')"
[ "$result" = "stop" ] && touch "stop"
