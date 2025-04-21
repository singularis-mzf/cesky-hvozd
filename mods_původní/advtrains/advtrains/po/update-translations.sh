#!/bin/sh
# NOTE: Please make sure you also have basic_trains installed, as it uses attrans for historical reasons

PODIR=`dirname "$0"`
ATDIR="$PODIR/../.."
BTDIR="$ATDIR/../basic_trains"
POTFILE="$PODIR/advtrains.pot"

xgettext \
	-D "$ATDIR" \
	-D "$BTDIR" \
	-d advtrains \
	-o "$POTFILE" \
	-p . \
	-L lua \
	--from-code=UTF-8 \
	--sort-by-file \
	--keyword='attrans' \
	--keyword='S' \
	--package-name='advtrains' \
	--msgid-bugs-address='advtrains-discuss@lists.sr.ht' \
	`find $ATDIR $BTDIR -name '*.lua' -printf '%P\n'` \
	&&
for i in "$PODIR"/*.po; do
	msgmerge -U \
		--sort-by-file \
		$i "$POTFILE"
done
