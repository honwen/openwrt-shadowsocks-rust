#
# Copyright (C) 2021-2026 honwen <https://github.com/honwen>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shadowsocks-rust
PKG_VERSION:=1.25.0
PKG_RELEASE:=20260827

# refer: https://github.com/honwen/openwrt-shadowsocks-rust/commit/1c42f16ba56440bffd3560aa5d1c8305f5d9e1c5
PKG_LIBC:=musl
ifeq ($(ARCH),arm)
  PKG_LIBC:=musleabi

  ARM_CPU_FEATURES:=$(word 2,$(subst +,$(space),$(call qstrip,$(CONFIG_CPU_TYPE))))
  ifneq ($(filter $(ARM_CPU_FEATURES),vfp vfpv2),)
    PKG_LIBC:=musleabihf
  endif
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
	config SS_RUST_TOOLS
		depends on PACKAGE_shadowsocks-rust
		bool "Build ssurl"
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

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	if [ -f /etc/uci-defaults/$(PKG_NAME) ]; then
		( . /etc/uci-defaults/$(PKG_NAME) ) && \
		rm -f /etc/uci-defaults/$(PKG_NAME)
	fi
fi
exit 0
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ssservice $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/uci-defaults $(1)/etc/uci-defaults/$(PKG_NAME)
ifeq ($(CONFIG_SS_RUST_TOOLS),y)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ssurl $(1)/usr/bin/
endif
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
