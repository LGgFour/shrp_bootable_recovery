LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_CFLAGS := -fno-strict-aliasing

LOCAL_SRC_FILES := \
    gui.cpp \
    resources.cpp \
    pages.cpp \
    text.cpp \
    image.cpp \
    action.cpp \
    console.cpp \
    fill.cpp \
    button.cpp \
    checkbox.cpp \
    fileselector.cpp \
    progressbar.cpp \
    object.cpp \
    slidervalue.cpp \
    listbox.cpp \
    keyboard.cpp \
    input.cpp \
    blanktimer.cpp \
    partitionlist.cpp \
    mousecursor.cpp \
    scrolllist.cpp \
    patternpassword.cpp \
    textbox.cpp \
    terminal.cpp \
    twmsg.cpp

ifneq ($(TWRP_CUSTOM_KEYBOARD),)
    LOCAL_SRC_FILES += $(TWRP_CUSTOM_KEYBOARD)
else
    LOCAL_SRC_FILES += hardwarekeyboard.cpp
endif

LOCAL_SHARED_LIBRARIES += libminuitwrp libc libstdc++ libaosprecovery libselinux
ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 26; echo $$?),0)
    LOCAL_SHARED_LIBRARIES += libziparchive
    LOCAL_C_INCLUDES += $(LOCAL_PATH)/../otautil/include
else
    LOCAL_SHARED_LIBRARIES += libminzip
    LOCAL_CFLAGS += -DUSE_MINZIP
endif
LOCAL_MODULE := libguitwrp

#TWRP_EVENT_LOGGING := true
ifeq ($(TWRP_EVENT_LOGGING), true)
    LOCAL_CFLAGS += -D_EVENT_LOGGING
endif
ifneq ($(TW_USE_KEY_CODE_TOUCH_SYNC),)
    LOCAL_CFLAGS += -DTW_USE_KEY_CODE_TOUCH_SYNC=$(TW_USE_KEY_CODE_TOUCH_SYNC)
endif
ifneq ($(TW_OZIP_DECRYPT_KEY),)
    LOCAL_CFLAGS += -DTW_OZIP_DECRYPT_KEY=\"$(TW_OZIP_DECRYPT_KEY)\"
else
    LOCAL_CFLAGS += -DTW_OZIP_DECRYPT_KEY=0
endif
ifneq ($(TW_OZIP_DECRYPT_KEY),)
    LOCAL_CFLAGS += -DSHRP_OZIP_DECRYPT
endif
ifneq ($(TW_NO_SCREEN_BLANK),)
    LOCAL_CFLAGS += -DTW_NO_SCREEN_BLANK
endif
ifneq ($(TW_NO_SCREEN_TIMEOUT),)
    LOCAL_CFLAGS += -DTW_NO_SCREEN_TIMEOUT
endif
ifeq ($(TW_OEM_BUILD), true)
    LOCAL_CFLAGS += -DTW_OEM_BUILD
endif
ifneq ($(TW_X_OFFSET),)
    LOCAL_CFLAGS += -DTW_X_OFFSET=$(TW_X_OFFSET)
endif
ifneq ($(TW_Y_OFFSET),)
    LOCAL_CFLAGS += -DTW_Y_OFFSET=$(TW_Y_OFFSET)
endif
ifneq ($(TW_W_OFFSET),)
    LOCAL_CFLAGS += -DTW_W_OFFSET=$(TW_W_OFFSET)
endif
ifneq ($(TW_H_OFFSET),)
    LOCAL_CFLAGS += -DTW_H_OFFSET=$(TW_H_OFFSET)
endif
ifeq ($(TW_ROUND_SCREEN), true)
    LOCAL_CFLAGS += -DTW_ROUND_SCREEN
endif
ifeq ($(BOARD_BUILD_SYSTEM_ROOT_IMAGE), true)
    LOCAL_CFLAGS += -DBOARD_BUILD_SYSTEM_ROOT_IMAGE
endif
#SHRP Build Flags
ifeq ($(SHRP_CUSTOM_FLASHLIGHT),true)
    LOCAL_CFLAGS += -DSHRP_CUSTOM_FLASHLIGHT
endif
ifeq ($(SHRP_LITE),true)
    LOCAL_CFLAGS += -DSHRP_LITE
endif
ifeq ($(SHRP_AB),true)
    LOCAL_CFLAGS += -DSHRP_AB
endif
ifeq ($(SHRP_EXPRESS),true)
	LOCAL_CFLAGS += -DSHRP_EXPRESS
endif
ifeq ($(TW_EXCLUDE_ENCRYPTED_BACKUPS), true)
    LOCAL_CFLAGS += -DTW_EXCLUDE_ENCRYPTED_BACKUPS
endif

LOCAL_C_INCLUDES += \
    bionic \
    system/core/include \
    system/core/libpixelflinger/include \
    external/boringssl/src/include

ifeq ($(shell test $(PLATFORM_SDK_VERSION) -lt 23; echo $$?),0)
    LOCAL_C_INCLUDES += external/stlport/stlport
    LOCAL_CFLAGS += -DUSE_FUSE_SIDELOAD22
endif

LOCAL_CFLAGS += -DTWRES=\"$(TWRES_PATH)\"

include $(BUILD_STATIC_LIBRARY)

# Transfer in the resources for the device
include $(CLEAR_VARS)
LOCAL_MODULE := twrp
LOCAL_MODULE_TAGS := eng
LOCAL_MODULE_CLASS := RECOVERY_EXECUTABLES
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)

# The extra blank line before *** is intentional to ensure it ends up on its own line
define TW_THEME_WARNING_MSG

****************************************************************************
  Could not find ui.xml for TW_THEME: $(TW_THEME)
  Set TARGET_SCREEN_WIDTH and TARGET_SCREEN_HEIGHT to automatically select
  an appropriate theme, or set TW_THEME to one of the following:
    $(notdir $(wildcard $(LOCAL_PATH)/theme/*_*))
****************************************************************************
endef
define TW_CUSTOM_THEME_WARNING_MSG

****************************************************************************
  Could not find ui.xml for TW_CUSTOM_THEME: $(TW_CUSTOM_THEME)
  Expected to find custom theme's ui.xml at:
    $(TWRP_THEME_LOC)/ui.xml
  Please fix this or set TW_THEME to one of the following:
    $(notdir $(wildcard $(LOCAL_PATH)/theme/*_*))
****************************************************************************
endef

TWRP_RES := $(LOCAL_PATH)/theme/shrp_portrait_hdpi/fonts
TWRP_RES += $(LOCAL_PATH)/theme/shrp_portrait_hdpi/languages
ifeq ($(TW_EXTRA_LANGUAGES),true)
    TWRP_RES += $(LOCAL_PATH)/theme/extra-languages/fonts
    TWRP_RES += $(LOCAL_PATH)/theme/extra-languages/languages
endif
TW_THEME := shrp_portrait_hdpi

TWRP_THEME_LOC := $(LOCAL_PATH)/theme/$(TW_THEME)

TWRP_RES += $(TW_ADDITIONAL_RES)

TWRP_RES_GEN := $(intermediates)/twrp
$(TWRP_RES_GEN):
	mkdir -p $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)
	cp -fr $(TWRP_RES) $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)
	cp -fr $(TWRP_THEME_LOC)/* $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)

LOCAL_GENERATED_SOURCES := $(TWRP_RES_GEN)
LOCAL_SRC_FILES := twrp $(TWRP_RES_GEN)
include $(BUILD_PREBUILT)
