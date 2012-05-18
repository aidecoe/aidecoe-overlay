# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

EAPI=4

PYTHON_DEPEND="2:2.7"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="2.[456] 3.*"

inherit distutils git-2

DESCRIPTION="Experimental terminal UI for net-mail/notmuch written in Python"
HOMEPAGE="https://github.com/pazz/alot"
EGIT_REPO_URI="git://github.com/pazz/alot.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="doc"

DEPEND=""
RDEPEND="
	>=dev-python/configobj-4.6.0
	>=dev-python/pyme-0.8.1
	>=dev-python/twisted-10.2.0
	>=dev-python/urwid-1.0.0
	net-mail/mailbase
	>=net-mail/notmuch-0.13[crypt,python]
	sys-apps/file[python]
	"

src_prepare() {
	distutils_src_prepare

	local md
	for md in *.md; do
		mv "${md}" "${md%.md}"
	done
}

src_compile() {
	distutils_src_compile

	if use doc; then
		pushd docs || die
		emake html
		popd || die
	fi
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r docs/build/html/*
	fi
}
