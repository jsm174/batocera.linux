################################################################################
#
# xenia-canary
#
################################################################################
# Version: Commits on June 10, 2025
XENIA_CANARY_SOURCE = xenia_canary_windows.zip
XENIA_CANARY_VERSION = 1d7973a
XENIA_CANARY_SITE = \
    https://github.com/xenia-canary/xenia-canary-releases/releases/download/$(XENIA_CANARY_VERSION)
XENIA_CANARY_LICENSE = BSD
XENIA_CANARY_LICENSE_FILE = LICENSE

XENIA_CANARY_DEPENDENCIES = python-toml

# ugly hack becuase the is no version in the source file
define XENIA_CANARY_CLEAR_DL
    if [ -f "$(DL_DIR)/$(XENIA_CANARY_DL_SUBDIR)/$(XENIA_CANARY_SOURCE)" ]; then \
        rm $(DL_DIR)/$(XENIA_CANARY_DL_SUBDIR)/$(XENIA_CANARY_SOURCE); \
    fi
endef

define XENIA_CANARY_EXTRACT_CMDS
	mkdir -p $(@D) && cd $(@D) && $(UNZIP) -d $(@D) $(DL_DIR)/$(XENIA_CANARY_DL_SUBDIR)/$(XENIA_CANARY_SOURCE)
endef

define XENIA_CANARY_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr
	rsync -av --exclude=".*" $(@D)/ $(TARGET_DIR)/usr/xenia-canary/
endef

define XENIA_CANARY_POST_PROCESS
	# get the latest patches
	mkdir -p $(TARGET_DIR)/usr/xenia-canary/patches
	mkdir -p $(@D)/temp
	( cd $(@D)/temp && $(GIT) init && \
	  $(GIT) remote add origin https://github.com/xenia-canary/game-patches.git && \
	  $(GIT) config core.sparsecheckout true && \
	  echo "patches/*.toml" >> .git/info/sparse-checkout && \
	  $(GIT) pull --depth=1 origin main && \
	  mv -f patches/*.toml $(TARGET_DIR)/usr/xenia-canary/patches \
	)
	
	# Clean up the temporary directory
	rm -rf $(@D)/temp
endef

XENIA_CANARY_PRE_DOWNLOAD_HOOKS = XENIA_CANARY_CLEAR_DL
XENIA_CANARY_POST_INSTALL_TARGET_HOOKS = XENIA_CANARY_POST_PROCESS

$(eval $(generic-package))
