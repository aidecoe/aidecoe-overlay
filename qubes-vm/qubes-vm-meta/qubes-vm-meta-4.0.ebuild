# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Qubes VM interaction with dom0 (meta package)"
HOMEPAGE="http://qubes-os.org/"
SRC_URI=""

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="x11-drivers/xf86-input-mfndev
	x11-drivers/xf86-video-dummy-qubes
	qubes-vm/qmemman
	qubes-vm/core-agent
	qubes-vm/udev-files
	qubes-vm/gui-agent"
