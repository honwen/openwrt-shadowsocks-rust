#
# Copyright (C) 2021 honwen <https://github.com/honwen>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shadowsocks-rust
PKG_VERSION:=1.10.9
PKG_RELEASE:=20210424

# refer: https://github.com/honwen/openwrt-shadowsocks-rust/commit/1c42f16ba56440bffd3560aa5d1c8305f5d9e1c5
PKG_LIBC:=musl
ifeq ($(ARCH),arm)
	PKG_LIBC:=musleabi
else ifneq ($(filter ($(ARCH),arm),vfp vfpv2),)
	PKG_LIBC:=musleabihf
endif

PKG_SOURCE:=shadowsocks-v$(PKG_VERSION).$(ARCH)-unknown-linux-$(PKG_LIBC).tar.xz
PKG_SOURCE_URL:=https://github.com/shadowsocks/shadowsocks-rust/releases/download/v$(PKG_VERSION)/
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)
PKG_HASH:=skip

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Lightweight Secured Socks5 Proxy - Rust.
	URL:=https://github.com/shadowsocks/shadowsocks-rust
endef

define Package/$(PKG_NAME)/config
	config SS_RUST_SERVER
		depends on PACKAGE_shadowsocks-rust
		bool "Build ssserver"
	config SS_RUST_TOOLS
		depends on PACKAGE_shadowsocks-rust
		bool "Build ssurl/ssmanager"
endef

define Package/$(PKG_NAME)/description
This is a port of shadowsocks.
endef

define Build/Prepare
	tar -C $(PKG_BUILD_DIR)/ -Jxf $(DL_DIR)/$(PKG_SOURCE)
endef

define Build/Compile
	echo "$(PKG_NAME) Compile Skiped!"
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sslocal $(1)/usr/bin/
ifeq ($(CONFIG_SS_RUST_SERVER),y)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ssserver $(1)/usr/bin/
endif
ifeq ($(CONFIG_SS_RUST_TOOLS),y)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ssurl $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ssmanager $(1)/usr/bin/
endif
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
