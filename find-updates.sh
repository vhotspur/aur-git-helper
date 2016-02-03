#!/bin/sh

#
# Copyright (c) 2016, Vojtech Horky
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of aur-git-helper nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

expand_version() {
	echo "$1" | sed -e 's#.*#.&.#' -e 'y/-/./' -e ':a' -e 's#\.\([0-9]\{1,6\}\)\.#.0\1.#' -e 't a' -e 's#\.\(.*\)\.#\1#'
}

compare_version() {
    _ver1=`expand_version "$1"`
    _ver2=`expand_version "$2"`
    if [ "$_ver1" = "$_ver2" ]; then
        echo "eq"
    elif [ `expr "$_ver1" '<' "$_ver2"` = "1" ]; then
        echo "lt"
    else
        echo "gt"
    fi
}

COLOR_RESET='\e[0m'
COLOR_UPDATE='\e[1;32m'
COLOR_AHEAD='\e[1;36m'

cd packages;

for PACKAGE in *; do
	(
		cd $PACKAGE;
		git pull >/dev/null
	)
	CUR_VER=`pacman -Q $PACKAGE 2>/dev/null | cut '-d ' -f 2`
	if [ -z "$CUR_VER" ]; then
		echo "WARNING: $PACKAGE probably not installed, consider removing the repository." >&2
		continue
	fi
	REPO_VER=`grep -e pkgver -e pkgrel $PACKAGE/.SRCINFO  | cut -d= -f 2 | tr -d ' ' | paste -sd-`
	VER_CMP=`compare_version "$CUR_VER" "$REPO_VER"`
	if [ "$VER_CMP" = "eq" ]; then
		echo "$PACKAGE $CUR_VER (up-to-date)" >&2
	elif [ "$VER_CMP" = "lt" ]; then
		echo -e "$COLOR_UPDATE$PACKAGE$COLOR_RESET $CUR_VER ($REPO_VER available)" >&2
		echo "$PACKAGE $CUR_VER => $REPO_VER"
		cat $PACKAGE/PKGBUILD | sed 's:.*:## &:'
		if [ -n "`ls $PACKAGE/*.install 2>/dev/null`" ]; then
			cat $PACKAGE/*.install | sed 's:.*:## &:'
		fi
		echo
		echo
		echo
	else
		echo -e "$COLOR_AHEAD$PACKAGE$COLOR_RESET $CUR_VER (newer than $REPO_VER)" >&2
	fi
done

