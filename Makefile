DEBUG = 1
GO_EASY_ON_ME := 1

ARCHS = arm64 arm64e
TARGET := iphone:clang:14.4:13.0
THEOS_DEVICE_IP = 192.168.0.15 -p 22

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ForceUITableViewStyle

$(TWEAK_NAME)_FILES = $(shell find Sources/ForceUITableViewStyle -name '*.swift') $(shell find Sources/ForceUITableViewStyleC -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
$(TWEAK_NAME)_SWIFTFLAGS = -ISources/ForceUITableViewStyleC/include
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -ISources/ForceUITableViewStyleC/include

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += forceuitableviewstylepref
include $(THEOS_MAKE_PATH)/aggregate.mk
