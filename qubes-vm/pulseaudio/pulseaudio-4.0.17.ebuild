# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd tmpfiles

MY_PN="qubes-gui-agent-linux"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Audio support for Qubes VM"
HOMEPAGE="https://www.qubes-os.org/"
SRC_URI="https://github.com/QubesOS/${MY_PN}/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

S="${WORKDIR}/${MY_P}/pulse"

CDEPEND="media-sound/pulseaudio:=
	dev-libs/dbus-glib:=
	qubes-vm/libvchan-xen:=
	"
DEPEND="${CDEPEND}
	virtual/pkgconfig"
RDEPEND="${CDEPEND}"

just_best_version() {
	local pkg=$1
	local ver=$(best_version "$pkg")
	echo "${ver#$pkg-}"
}

get_system_pulse_audio_vesion() {
	ver_cut 1-2 $(just_best_version media-sound/pulseaudio)
}

src_prepare() {
	default

	local pa_ver=$(get_system_pulse_audio_vesion)
	ln -sf "${S}/pulsecore-${pa_ver}" pulsecore
}

src_compile() {
	BACKEND_VMM=xen default
}

src_install() {
	local pa_ver=$(get_system_pulse_audio_vesion)

	dobin start-pulseaudio-with-vchan

	exeinto /usr/$(get_libdir)/pulse-${pa_ver}/modules
	doexe module-vchan-sink.so

	insinto /etc/pulse
	doins qubes-default.pa

	dotmpfiles ../appvm-scripts/etc/tmpfiles.d/qubes-pulseaudio.conf

	insinto /etc/xdg/autostart
	doins ../appvm-scripts/etc/xdgautostart/qubes-pulseaudio.desktop
}

pkg_postinst() {
	tmpfiles_process /usr/lib/tmpfiles.d/qubes-pulseaudio.conf

	if ! grep '^autospawn[[:space:]]*=[[:space:]]*no /etc/pulse/client.conf'
	then
		eerror "'autospawn' in /etc/pulse/client.conf must be set explicitly to 'no'"
	fi
}
