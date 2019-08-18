# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="qubes-core-agent-linux"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Qubes VM RPC"
HOMEPAGE="https://www.qubes-os.org/"
SRC_URI="https://github.com/QubesOS/${MY_PN}/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

S="${WORKDIR}/${MY_P}/qubes-rpc"

CDEPEND="qubes-vm/libqrexec"
DEPEND="${CDEPEND}"
RDEPEND="${CDEPEND}"

src_install() {
	dobin qvm-sync-clock
	dobin qvm-open-in-dvm
	dobin qvm-open-in-vm
	dobin qvm-copy-to-vm
	dobin qvm-run-vm
	dobin qvm-copy

	dosym qvm-copy-to-vm /usr/bin/qvm-move-to-vm
	dosym qvm-copy /usr/bin/qvm-move

	local qubeslibdir=/usr/lib/qubes

	insinto "${qubeslibdir}"
	doins qvm-copy-to-vm.gnome
	doins ../misc/uca_qubes.xml

	dosym qvm-copy-to-vm.gnome "${qubeslibdir}"/qvm-move-to-vm.gnome
	dosym qvm-copy-to-vm.gnome "${qubeslibdir}"/qvm-copy-to-vm.kde
	dosym qvm-copy-to-vm.gnome "${qubeslibdir}"/qvm-move-to-vm.kde

	exeinto "${qubeslibdir}"
	doexe qvm-actions.sh
	doexe xdg-icon
	doexe vm-file-editor
	doexe qfile-agent
	doexe qopen-in-vm
	doexe tar2qfile
	doexe qrun-in-vm
	doexe prepare-suspend
	doexe qubes-sync-clock

	doexe qfile-unpacker
	fperms 4755 "${qubeslibdir}"/qfile-unpacker

	dobin qubes-open

	#install -d $(DESTDIR)/$(KDESERVICEDIR)
	#install -m 0644 qubes-rpc/{qvm-copy.desktop,qvm-move.desktop,qvm-dvm.desktop} $(DESTDIR)/$(KDESERVICEDIR)
	#install -d $(DESTDIR)/$(KDE5SERVICEDIR)
	#install -m 0644 qubes-rpc/{qvm-copy.desktop,qvm-move.desktop,qvm-dvm.desktop} $(DESTDIR)/$(KDE5SERVICEDIR)

	exeinto /etc/qubes-rpc
	doexe qubes.Backup
	doexe qubes.DetachPciDevice
	doexe qubes.Filecopy
	doexe qubes.GetAppmenus
	doexe qubes.GetDate
	doexe qubes.GetImageRGBA
	doexe qubes.InstallUpdatesGUI
	doexe qubes.OpenInVM
	doexe qubes.OpenURL
	doexe qubes.PostInstall
	doexe qubes.ResizeDisk
	doexe qubes.Restore
	doexe qubes.SelectDirectory
	doexe qubes.SelectFile
	doexe qubes.SetDateTime
	doexe qubes.StartApp
	doexe qubes.SuspendPost
	doexe qubes.SuspendPostAll
	doexe qubes.SuspendPre
	doexe qubes.SuspendPreAll
	doexe qubes.VMRootShell
	doexe qubes.VMShell
	doexe qubes.WaitForSession

	insinto /etc/qubes/rpc-config
	newins rpc-config.README README
	local config
	for config in *.config; do
		newins "${config}" "${config#.config}"
	done

	insinto /etc
	doins ../misc/qubes-suspend-module-blacklist

	insinto /etc/qubes/suspend-pre.d
	newins suspend-pre.README README

	insinto /etc/qubes/suspend-post.d
	newins suspend-post.README README

	exeinto /etc/qubes/suspend-post.d
	newexe suspend-post-qvm-sync-clock.sh qvm-sync-clock.sh

	local postinstalldir=/etc/qubes/post-install.d

	insinto "${postinstalldir}"
	doins ../post-install.d/README
	exeinto "${postinstalldir}"
	doexe ../post-install.d/*.sh

	insinto /etc/xdg/xfce4/xfconf/xfce-perchannel-xml
	doins ../misc/thunar.xml

	insinto /usr/share/nautilus-python/extensions
	doins *_nautilus.py
}
