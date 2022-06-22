DEBUG = 1
GO_EASY_ON_ME := 1

ARCHS = arm64 arm64e
TARGET := iphone:clang:14.4:13.0
THEOS_DEVICE_IP = 192.168.0.15 -p 22

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ForceInsetGrouped

ForceInsetGrouped_FILES = $(shell find Sources/ForceInsetGrouped -name '*.swift') $(shell find Sources/ForceInsetGroupedC -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
ForceInsetGrouped_SWIFTFLAGS = -ISources/ForceInsetGroupedC/include
ForceInsetGrouped_CFLAGS = -fobjc-arc -ISources/ForceInsetGroupedC/include

include $(THEOS_MAKE_PATH)/tweak.mk
