# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit bash-completion eutils

DESCRIPTION="Gentoo automatic kernel building scripts"
HOMEPAGE="http://www.gentoo.org"

if [[ ${PV} == 999999 ]]; then
	EGIT_REPO_URI="git://git.overlays.gentoo.org/proj/genkernel.git"
	EGIT_BRANCH="dracut"
	inherit git autotools
else
	SRC_URI="mirror://gentoo/${P}.tar.bz2"
fi

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="bash-completion ibm selinux"

RDEPEND="${DEPEND}
	>=sys-kernel/dracut-007
	selinux? ( sys-libs/libselinux )
	"
DEPEND="
	>=dev-libs/libxslt-1.1.26
	>=app-text/docbook-xsl-ns-stylesheets-1.75.2
	"

#
# ebuild functions
#

src_install() {
	local docs="AUTHORS BUGS ChangeLog HACKING README TODO"

	dodoc ${docs} || die "dodoc"
	doman genkernel.8 || die "doman"
	insinto /etc; doins genkernel.conf || die "doins etc"
	dobin genkernel || die "dobin"

	rm -f genkernel genkernel.conf genkernel.8 ${docs}

	insinto /usr/share/genkernel
	doins -r * || die "doins share"
	if use ibm; then
		insinto /usr/share/genkernel/arch/ppc64
		newins arch/ppc64/kernel-2.6-pSeries kernel-2.6 || \
				newins arch/ppc64/kernel-2.6.g5 kernel-2.6
	fi

	use bash-completion && dobashcompletion "${FILESDIR}"/genkernel.bash
}

pkg_preinst() {
	use selinux && dosed 's/###//' usr/share/genkernel/gen_compile.sh
}

pkg_postinst() {
	echo
	elog 'Documentation is available in the Genkernel manual page'
	elog 'as well as the following URL:'
	elog ''
	elog 'http://www.gentoo.org/doc/en/genkernel.xml'
	echo
	ewarn "Kernel command line arguments have changed. Genkernel uses Dracut"
	ewarn "to generate initramfs. See man 7 dracut.kernel for help on kernel"
	ewarn "cmdline arguments."
	echo
	ewarn "Don't use internal initramfs generation tool as it's beining removed"
	ewarn "at the moment."
	echo
	elog 'Do NOT report kernel bugs as Genkernel bugs unless your bug is about'
	elog 'the default Genkernel configuration...'
	elog 'Make sure you have the latest Genkernel before reporting bugs.'

	use bash-completion && echo && bash-completion_pkg_postinst
}
