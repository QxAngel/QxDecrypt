TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = QxDecrypt

ARCHS = arm64 arm64e

GO_EASY_ON_ME = 1
PACKAGE_FORMAT = ipa

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = QxDecrypt

QxDecrypt_FILES = $(wildcard SSZipArchive/minizip/*.c) $(wildcard SSZipArchive/minizip/aes/*.c) $(wildcard SSZipArchive/*.m)
QxDecrypt_FILES += $(wildcard *.m)
QxDecrypt_FRAMEWORKS = UIKit CoreGraphics MobileCoreServices
QxDecrypt_CFLAGS = -fobjc-arc 
QxDecrypt_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS_MAKE_PATH)/application.mk

after-stage::
	rm -rf Payload
	mkdir -p $(THEOS_STAGING_DIR)/Payload
	ldid -Sentitlements.plist $(THEOS_STAGING_DIR)/Applications/QxDecrypt.app/QxDecrypt
	cp -a $(THEOS_STAGING_DIR)/Applications/* $(THEOS_STAGING_DIR)/Payload
	mv $(THEOS_STAGING_DIR)/Payload .
	zip -q -r packages/QxDecrypt.tipa Payload
