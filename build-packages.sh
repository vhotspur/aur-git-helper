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

TO_BE_INSTALLED=""

while read PACKAGE IGNORE_REST_OF_LINE; do
	if [ -z "$PACKAGE" ]; then
		continue
	fi
	if echo "$PACKAGE" | grep -q '^#'; then
		continue
	fi
	echo -n "Building $PACKAGE ";
	(
		set -o errexit
		cd packages/$PACKAGE

		git clean -f >/dev/null
		echo -n "."

		makepkg -o >LAST_BUILD.log 2>&1
		echo -n "."

		makepkg >>LAST_BUILD.log 2>&1
		echo -n "."
	)
	if [ $? -eq 0 ]; then
		echo " done."
		PACKAGE_FILE=`ls "$PWD/packages/$PACKAGE/"$PACKAGE-*.pkg.tar.xz | tail -n 1`
		TO_BE_INSTALLED="$TO_BE_INSTALLED $PACKAGE_FILE"
	else
		echo " failed."
	fi
done

if [ -n "$TO_BE_INSTALLED" ]; then
	echo
	echo "pacman -U $TO_BE_INSTALLED"
	echo
fi

