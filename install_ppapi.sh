#!/bin/sh
#For those who are lazy to update flash in usual way :p
#acknowledgement: https://gist.github.com/stefanschmidt/9510292

#Note: use for installing to ~/Library or updating globally.
#New global installation should use normal installer.

if [ `whoami` == "root" ];then
	export HOME=""
fi

FLASH_URL="http://fpdownload.macromedia.com/pub/flashplayer/latest/help/install_flash_player_osx_ppapi.dmg"
FLASH_DMG=$(mktemp -d -t flash_dmg)/flash.dmg
FLASH_MOUNTPOINT=$(mktemp -d -t flash_mountpoint)
 
curl -o $FLASH_DMG $FLASH_URL
hdiutil attach -mountpoint $FLASH_MOUNTPOINT -nobrowse $FLASH_DMG
 
FLASH_PKG_ARCHIVE="$FLASH_MOUNTPOINT/Install Adobe Pepper Flash Player.app/Contents/Resources/Adobe Flash Player.pkg"
FLASH_PKG_EXTRACT_DIR=$(mktemp -d -t flash_pkg_extract_dir)
FLASH_INSTALL_SRC="$FLASH_PKG_EXTRACT_DIR/AdobeFlashPlayerComponent.pkg"
 
cd "$FLASH_PKG_EXTRACT_DIR"
xar -xf "$FLASH_PKG_ARCHIVE"
 
cd "$FLASH_INSTALL_SRC"
cat Payload | gunzip -dc | cpio -i
cat Scripts | gunzip -dc | cpio -i
 
mkdir -p "$HOME/Library/Internet Plug-Ins/PepperFlashPlayer"
mkdir -p "$HOME/Library/PreferencePanes"
 
cp -f "$FLASH_INSTALL_SRC/Library/Internet Plug-Ins/PepperFlashPlayer/PepperFlashPlayer.plugin.lzma" "$HOME/Library/Internet Plug-Ins/PepperFlashPlayer"
cp -f "$FLASH_INSTALL_SRC/Library/Internet Plug-Ins/PepperFlashPlayer/manifest.json" "$HOME/Library/Internet Plug-Ins/PepperFlashPlayer"
cp -fr "$FLASH_INSTALL_SRC/Library/PreferencePanes/Flash Player.prefPane" "$HOME/Library/PreferencePanes"
 
# extracts the lzma archive in ~/Library/Internet Plug-Ins
"$FLASH_INSTALL_SRC/finalize" "/$HOME"
 
hdiutil detach $FLASH_MOUNTPOINT -force
