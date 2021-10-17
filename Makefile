#
# Copyright (C) 2021 honwen <https://github.com/honwen>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shadowsocks-rust
PKG_VERSION:=1.11.2
PKG_RELEASE:=20210724

# refer: https://github.com/honwen/openwrt-shadowsocks-rust/commit/1c42f16ba56440bffd3560aa5d1c8305f5d9e1c5
PKG_LIBC:=musl
ifeq ($(ARCH),arm)
  PKG_LIBC:=musleabi

  ARM_CPU_FEATURES:=$(word 2,$(subst +,$(space),$(call qstrip,$(CONFIG_CPU_TYPE))))
  ifneq ($(filter $(ARM_CPU_FEATURES),vfp vfpv2),)
    PKG_LIBC:=musleabihf
  endif
endif

PKG_ARCH=$(ARCH)
ifeq ($(ARCH),i386)
  PKG_ARCH:=i686
endif

PKG_SOURCE:=shadowsocks-v$(PKG_VERSION).$(ARCH)-unknown-linux-$(PKG_LIBC).tar.xz
PKG_SOURCE_URL:=https://github.com/shadowsocks/shadowsocks-rust/releases/download/v$(PKG_VERSION)/
PKG_HASH:=skip

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/shadowsocks-rust/Default
  PKG_CONFIG_DEPENDS+=CONFIG_SHADOWSOCKS_RUST_$(1)_COMPRESS_UPX
  
  define Package/shadowsocks-rust-$(1)
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    TITLE:=shadowsocks-rust $(1)
    URL:=https://github.com/shadowsocks/shadowsocks-rust
    DEPENDS:=@(aarch64||arm||i386||mips||mipsel||x86_64) @USE_MUSL
  endef

  define Package/$(PKG_NAME)/description
	This is a port of shadowsocks.
  endef

  define Download/sha256sum
	FILE:=$(PKG_SOURCE).sha256
	URL_FILE:=$(FILE)
	URL:=$(PKG_SOURCE_URL)
	HASH:=skip
  endef
  
  define Build/Prepare
	mv $(DL_DIR)/$(PKG_SOURCE).sha256 .
	cp $(DL_DIR)/$(PKG_SOURCE) .
	shasum -a 256 -c $(PKG_SOURCE).sha256
	rm $(PKG_SOURCE).sha256 $(PKG_SOURCE)

	tar -C $(PKG_BUILD_DIR)/ -Jxf $(DL_DIR)/$(PKG_SOURCE)
  endef

  define Package/shadowsocks-rust-$(1)/config
    config SHADOWSOCKS_RUST_$(1)_COMPRESS_UPX
      bool "Compress $(1) with UPX"
      default y
  endef

  define Package/shadowsocks-rust-$(1)/install
	$$(INSTALL_DIR) $$(1)/usr/bin
	$$(INSTALL_BIN) $$(PKG_BUILD_DIR)/$(1) $$(1)/usr/bin
  endef
endef

PKG_CONFIG_DEPENDS:=
SHADOWSOCKS_COMPONENTS:=sslocal ssmanager ssserver ssurl
define shadowsocks-rust/templates
  $(foreach component,$(SHADOWSOCKS_COMPONENTS),
    $(call Package/shadowsocks-rust/Default,$(component))
  )
endef
$(eval $(call shadowsocks-rust/templates))

define Build/Compile
$(foreach component,$(SHADOWSOCKS_COMPONENTS),
  ifneq ($(CONFIG_SHADOWSOCKS_RUST_$(component)_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_BUILD_DIR)/$(component)
  endif
)
endef

$(foreach component,$(SHADOWSOCKS_COMPONENTS), \
  $(eval $(call BuildPackage,shadowsocks-rust-$(component))) \
)

$(eval $(call Download,sha256sum))
