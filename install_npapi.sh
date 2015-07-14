#!/bin/sh
#For those who are lazy to update flash in usual way :p
#acknowledgement: https://gist.github.com/stefanschmidt/9510292

if [ `whoami` == "root" ];then
	export HOME=""
fi

FLASH_URL="http://fpdownload.macromedia.com/pub/flashplayer/latest/help/install_flash_player_osx.dmg"
FLASH_DMG=$(mktemp -d -t flash_dmg)/flash.dmg
FLASH_MOUNTPOINT=$(mktemp -d -t flash_mountpoint)
FLASH_PKG="$FLASH_MOUNTPOINT/Install Adobe Flash Player.app/Contents/Resources/Adobe Flash Player.pkg"
 
curl -o $FLASH_DMG $FLASH_URL
hdiutil attach -mountpoint $FLASH_MOUNTPOINT -nobrowse $FLASH_DMG
 
FLASH_PKG_ARCHIVE="$FLASH_MOUNTPOINT/Install Adobe Flash Player.app/Contents/Resources/Adobe Flash Player.pkg"
FLASH_PKG_EXTRACT_DIR=$(mktemp -d -t flash_pkg_extract_dir)
FLASH_INSTALL_SRC="$FLASH_PKG_EXTRACT_DIR/AdobeFlashPlayerComponent.pkg"
 
cd "$FLASH_PKG_EXTRACT_DIR"
xar -xf "$FLASH_PKG_ARCHIVE"
 
cd "$FLASH_INSTALL_SRC"
cat Payload | gunzip -dc | cpio -i
cat Scripts | gunzip -dc | cpio -i
 
mkdir -p "$HOME/Library/Internet Plug-Ins"
mkdir -p "$HOME/Library/PreferencePanes"
 
cp -f "$FLASH_INSTALL_SRC/Library/Internet Plug-Ins/Flash Player.plugin.lzma" "$HOME/Library/Internet Plug-Ins"
cp -f "$FLASH_INSTALL_SRC/Library/Internet Plug-Ins/flashplayer.xpt" "$HOME/Library/Internet Plug-Ins"
cp -fr "$FLASH_INSTALL_SRC/Library/PreferencePanes/Flash Player.prefPane" "$HOME/Library/PreferencePanes"
 
# extracts the lzma archive in ~/Library/Internet Plug-Ins
"$FLASH_INSTALL_SRC/finalize" "/$HOME"
 
hdiutil detach $FLASH_MOUNTPOINT -force
