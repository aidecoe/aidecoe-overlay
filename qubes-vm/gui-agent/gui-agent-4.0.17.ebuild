# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit python-single-r1 systemd tmpfiles

MY_PN="qubes-gui-agent-linux"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Qubes GUI agent"
HOMEPAGE="https://www.qubes-os.org/"
SRC_URI="https://github.com/QubesOS/${MY_PN}/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

S="${WORKDIR}/${MY_P}/gui-agent"

CDEPEND="gnome-extra/zenity
	qubes-vm/db
	qubes-vm/libvchan-xen:=
	x11-base/xorg-server
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage"
DEPEND="${CDEPEND}
	virtual/pkgconfig"
RDEPEND="${CDEPEND}
	dev-python/xcffib[${PYTHON_USEDEP}]"

SYSTEMD_UNITS=(
	../appvm-scripts/qubes-gui-agent.service
)

install_systemd_units() {
	local unit
	for unit in "${@}"; do
		systemd_dounit "${unit}"
	done

}

make_session_wrapper() {
	local session_exec_path="${1}"
	local session_name="${2:-${PN}}"
	printf "#!${EPREFIX}/bin/sh\nexec '${EPREFIX}${session_exec_path}'\n" \
		>"${T}/${session_name}" || die
	exeinto /etc/X11/Sessions
	doexe "${T}/${session_name}"
}

src_compile() {
	BACKEND_VMM=xen default
}

src_install() {
	dobin qubes-gui
	dobin ../appvm-scripts/usrbin/qubes-change-keyboard-layout
	dobin ../appvm-scripts/usrbin/qubes-run-xorg
	dobin ../appvm-scripts/usrbin/qubes-session
	dobin ../appvm-scripts/usrbin/qubes-set-monitor-layout
	make_session_wrapper /usr/bin/qubes-session Qubes

	insinto /etc/X11
	doins ../appvm-scripts/etc/X11/Xwrapper.config  # rh
	doins ../appvm-scripts/etc/X11/xorg-qubes.conf.template

	# TODO: Install only to one of Xsession.d or xinitrc.d
	insinto /etc/X11/Xsession.d
	doins ../appvm-scripts/etc/X11/Xsession.d/20qt-gnome-desktop-session-id
	doins ../appvm-scripts/etc/X11/Xsession.d/20qt-x11-no-mitshm
	doins ../appvm-scripts/etc/X11/Xsession.d/25xdg-qubes-settings
	insinto /etc/X11/xinit/xinitrc.d
	doins ../appvm-scripts/etc/X11/xinit/xinitrc.d/qubes-keymap.sh  # rh
	doins ../appvm-scripts/etc/X11/xinit/xinitrc.d/20qt-gnome-desktop-session-id.sh  # rh
	doins ../appvm-scripts/etc/X11/xinit/xinitrc.d/20qt-x11-no-mitshm.sh  # rh
	doins ../appvm-scripts/etc/X11/xinit/xinitrc.d/50-xfce-desktop.sh  # xfce

	insinto /etc/profile.d
	doins ../appvm-scripts/etc/profile.d/qubes-gui.sh
	doins ../appvm-scripts/etc/profile.d/qubes-gui.csh
	doins ../appvm-scripts/etc/profile.d/qubes-session.sh

	insinto /etc/qubes-rpc
	doins ../appvm-scripts/etc/qubes-rpc/qubes.SetMonitorLayout

	insinto /etc/security/limits.d
	doins ../appvm-scripts/etc/securitylimits.d/90-qubes-gui.conf

	insinto /etc/xdg
	doins ../appvm-scripts/etc/xdg/Trolltech.conf

	insinto /etc/xdg/autostart
	doins ../window-icon-updater/qubes-icon-sender.desktop

	exeinto /usr/lib/qubes
	doexe ../window-icon-updater/icon-sender

	insinto /usr/lib/modules-load.d
	doins ../appvm-scripts/usr/lib/modules-load.d/qubes-gui.conf

	insinto /usr/lib/sysctl.d
	doins ../appvm-scripts/usr/lib/sysctl.d/30-qubes-gui-agent.conf

	insinto /usr/share/glib-2.0/schemas
	doins ../appvm-scripts/qubes-gui-vm.gschema.override

	dotmpfiles ../appvm-scripts/etc/tmpfiles.d/qubes-session.conf
	install_systemd_units "${SYSTEMD_UNITS[@]}"

	keepdir /var/log/qubes

	python_fix_shebang "${ED}"usr/bin
}

pkg_postinst() {
	tmpfiles_process /usr/lib/tmpfiles.d/qubes-session.conf
	/usr/bin/glib-compile-schemas /usr/share/glib-2.0/schemas
}
