#!/bin/bash
APPDIR="../"
THUMBNAIL_FOLDER="${APPDIR}/Fotos/thumbnails"
SAVEFS=$IFS
IFS=$(echo -ne "\n\b")
for l in $(sqlite3 fotos.sqlite "SELECT md5,fullpath FROM files WHERE type in ('jpg','JPG','jpeg',JPEG','gif','GIF','png',PNG','tif','TIF','tiff','TIFF') GROUP BY md5;");
do
	fullpath="$(echo $l | cut -d'|' -f2)"
	filename=$(basename "$fullpath")
	filetype="${filename##*.}"

	fld="${THUMBNAIL_FOLDER}/$(echo $l | cut -c1-2)"
	fil="$(echo $l | cut -d'|' -f1).${filetype}"
	echo "$fld,$fil"
	if [ ! -d "${fld}" ]; then
		mkdir "${fld}"
	fi
	convert -define jpeg:size=500x500 ${fullpath} -auto-orient -thumbnail 100x100 -unsharp 0x.5 "${fld}/${fil}"
done
