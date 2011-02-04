# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit autotools-utils git

DESCRIPTION="Graphical boot animation (splash) and logger"
HOMEPAGE="http://cgit.freedesktop.org/plymouth/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

IUSE_VIDEO_CARDS="video_cards_intel video_cards_nouveau video_cards_radeon"
IUSE="${IUSE_VIDEO_CARDS} branding gdm +libkms +pango"

DEPEND=">=media-libs/libpng-1.2.16
	>=x11-libs/gtk+-2.12
	libkms? ( x11-libs/libdrm[libkms] )
	pango? ( >=x11-libs/pango-1.21 )
	video_cards_intel? ( x11-libs/libdrm[video_cards_intel] )
	video_cards_nouveau? ( x11-libs/libdrm[video_cards_nouveau] )
	video_cards_radeon? ( x11-libs/libdrm[video_cards_radeon] )
	"
RDEPEND="${DEPEND}
	>=sys-kernel/dracut-007
	"

EGIT_REPO_URI="git://anongit.freedesktop.org/plymouth"
EGIT_PATCHES=("${FILESDIR}"/${PV}-gentoo-fb-path.patch)

src_prepare() {
	git_src_prepare
	eautoreconf || die "eautoreconf failed"
}

src_configure() {
	econf \
		--enable-static=no \
		$(use_enable libkms) \
		$(use_enable pango) \
		$(use_enable gdm gdm-transition) \
		$(use_enable video_cards_intel libdrm_intel) \
		$(use_enable video_cards_nouveau libdrm_nouveau) \
		$(use_enable video_cards_radeon libdrm_radeon) \
		|| die "econf failed"
}

src_install() {
	autotools-utils_src_install

	mv "${D}/$(get_libdir)"/libply{,-splash-core}.la \
		"${D}/usr/${get_libdir}"/ || die 'mv *.la files failed'

	newinitd "${FILESDIR}"/plymouth.initd plymouth || die 'initd failed'

	if use branding ; then
		insinto /usr/share/plymouth
		newins "${FILESDIR}"/gentoo_ply.png bizcom.png || die 'branding failed'
	fi
}

pkg_postinst() {
	elog "Plymouth initramfs utilities scripts are located in"
	elog "/usr/libexec/plymouth"
	elog ""
	elog "Follow instructions on <http://en.gentoo-wiki.com/wiki/Plymouth> to"
	elog "setup Plymouth."
}
