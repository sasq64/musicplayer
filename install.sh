TARGET=/usr/local/bin/

[ -f $TARGET/msxp ] && mv $TARGET/msxp $TARGET/msxp.old
cp build/msxp $TARGET/
rm -rf /usr/local/share/musix
cp -a data /usr/local/share/musix

