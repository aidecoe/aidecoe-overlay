# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit autotools-utils

DESCRIPTION="Graphical boot animation (splash) and logger"
HOMEPAGE="http://cgit.freedesktop.org/plymouth/"
SRC_URI="http://cgit.freedesktop.org/${PN}/snapshot/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror"

IUSE_VIDEO_CARDS="video_cards_intel video_cards_nouveau video_cards_radeon"
IUSE="${IUSE_VIDEO_CARDS} branding gdm +pango"

DEPEND=">=media-libs/libpng-1.2.16
	>=x11-libs/gtk+-2.12
	pango? ( >=x11-libs/pango-1.21 )
	video_cards_intel? ( x11-libs/libdrm[video_cards_intel] )
	video_cards_nouveau? ( x11-libs/libdrm[video_cards_nouveau] )
	video_cards_radeon? ( x11-libs/libdrm[video_cards_radeon] )
	"
RDEPEND="${DEPEND}
	>=sys-kernel/dracut-007"

PATCHES=(
	"${FILESDIR}"/${PV}-drm-reduce-minimum-build-requirements.patch
	"${FILESDIR}"/${PV}-image-replace-deprecated-libpng-function.patch
	"${FILESDIR}"/${PV}-gentoo-fb-path.patch
	)

src_prepare() {
	autotools-utils_src_prepare
	eautoreconf || die "eautoreconf failed"
}

src_configure() {
	econf \
		--enable-static=no \
		$(use_enable pango) \
		$(use_enable gdm gdm-transition) \
		$(use_enable video_cards_intel libdrm_intel) \
		$(use_enable video_cards_nouveau libdrm_nouveau) \
		$(use_enable video_cards_radeon libdrm_radeon) \
		|| die "econf failed"
}

src_install() {
	autotools-utils_src_install

	mv "${D}/$(get_libdir)"/libply{,-splash-core}.la "${D}/usr/${get_libdir}"/

	newinitd "${FILESDIR}"/plymouth.initd plymouth

	if use branding ; then
		insinto /usr/share/plymouth
		newins "${FILESDIR}"/gentoo_ply.png bizcom.png
	fi
}

pkg_postinst() {
	elog "Plymouth initramfs utilities scripts are located in"
	elog "/usr/libexec/plymouth"
	elog ""
	elog "Use /usr/libexec/plymouth/plymouth-generate-initrd to generate"
	elog "initramfs image required for starting plymouth at boot time."
	elog "Although it is recommended to use sys-kernel/dracut instead."
}
