# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# genkernel-9999        -> latest Git branch "master"
# genkernel-VERSION     -> normal genkernel release

VERSION_BUSYBOX='1.18.1'
VERSION_DMAP='1.02.22'
VERSION_DMRAID='1.0.0.rc14'
VERSION_MDADM='3.1.4'
VERSION_E2FSPROGS='1.41.14'
VERSION_FUSE='2.7.4'
VERSION_ISCSI='2.0-872'
VERSION_LVM='2.02.74'
VERSION_UNIONFS_FUSE='0.22'
VERSION_GPG='1.4.11'

MY_HOME="http://wolf31o2.org"
RH_HOME="ftp://sources.redhat.com/pub"
DM_HOME="http://people.redhat.com/~heinzm/sw/dmraid/src"
BB_HOME="http://www.busybox.net/downloads"

COMMON_URI="${DM_HOME}/dmraid-${VERSION_DMRAID}.tar.bz2
		${DM_HOME}/old/dmraid-${VERSION_DMRAID}.tar.bz2
		mirror://kernel/linux/utils/raid/mdadm/mdadm-${VERSION_MDADM}.tar.bz2
		${RH_HOME}/lvm2/LVM2.${VERSION_LVM}.tgz
		${RH_HOME}/lvm2/old/LVM2.${VERSION_LVM}.tgz
		${RH_HOME}/dm/device-mapper.${VERSION_DMAP}.tgz
		${RH_HOME}/dm/old/device-mapper.${VERSION_DMAP}.tgz
		${BB_HOME}/busybox-${VERSION_BUSYBOX}.tar.bz2
		mirror://kernel/linux/kernel/people/mnc/open-iscsi/releases/open-iscsi-${VERSION_ISCSI}.tar.gz
		mirror://sourceforge/e2fsprogs/e2fsprogs-${VERSION_E2FSPROGS}.tar.gz
		mirror://sourceforge/fuse/fuse-${VERSION_FUSE}.tar.gz
		http://podgorny.cz/unionfs-fuse/releases/unionfs-fuse-${VERSION_UNIONFS_FUSE}.tar.bz2
		mirror://gnupg/gnupg/gnupg-${VERSION_GPG}.tar.bz2"

if [[ ${PV} == 9999* ]]
then
	EGIT_REPO_URI="git://git.overlays.gentoo.org/proj/genkernel.git"
	EGIT_BRANCH="dracut"
	inherit git bash-completion eutils
	KEYWORDS=""
else
	inherit bash-completion eutils
	SRC_URI="mirror://gentoo/${P}.tar.bz2
		${MY_HOME}/sources/genkernel/${P}.tar.bz2
		${COMMON_URI}"
	# Please don't touch individual KEYWORDS.  Since this is maintained/tested by
	# Release Engineering, it's easier for us to deal with all arches at once.
	KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86"
fi

DESCRIPTION="Gentoo automatic kernel building scripts"
HOMEPAGE="http://www.gentoo.org"

LICENSE="GPL-2"
SLOT="0"
RESTRICT=""
IUSE="ibm selinux"

DEPEND="
	selinux? ( sys-libs/libselinux )"
RDEPEND="${DEPEND}
	>=sys-kernel/dracut-010
	"

if [[ ${PV} == 9999* ]]; then
	DEPEND="${DEPEND}
		>=dev-libs/libxslt-1.1.26
		>=app-text/docbook-xsl-ns-stylesheets-1.75.2
		"
fi

src_unpack() {
	if [[ ${PV} == 9999* ]] ; then
		git_src_unpack
	else
		unpack ${P}.tar.bz2
	fi
	use selinux && sed -i 's/###//g' "${S}"/gen_compile.sh
}

src_compile() {
	if [[ ${PV} == 9999* ]]; then
		emake || die
	fi
}

src_install() {

	doman genkernel.8 || die "doman"
	dodoc AUTHORS ChangeLog README TODO || die "dodoc"

	dobin genkernel || die "dobin genkernel"
	insinto /etc
	doins genkernel.conf || die "doins genkernel.conf"

	rm -f genkernel genkernel.8 AUTHORS ChangeLog README TODO genkernel.conf

	insinto /usr/share/genkernel
	doins -r "${S}"/* || die "doins"
	use ibm && cp "${S}"/ppc64/kernel-2.6-pSeries "${S}"/ppc64/kernel-2.6 || \
		cp "${S}"/arch/ppc64/kernel-2.6.g5 "${S}"/arch/ppc64/kernel-2.6

	dobashcompletion "${FILESDIR}"/genkernel.bash
}

pkg_preinst() {
	use selinux && dosed 's/###//' usr/share/genkernel/gen_compile.sh
}

pkg_postinst() {
	echo
	elog 'Documentation is available in the genkernel manual page'
	elog 'as well as the following URL:'
	echo
	elog 'http://www.gentoo.org/doc/en/genkernel.xml'
	echo
	ewarn "Kernel command line arguments have changed. Genkernel uses Dracut"
	ewarn "to generate initramfs. See man 7 dracut.kernel for help on kernel"
	ewarn "cmdline arguments."
	echo
	ewarn "Don't use internal initramfs generation tool as it's beining removed"
	ewarn "at the moment."
	echo

	bash-completion_pkg_postinst
}
