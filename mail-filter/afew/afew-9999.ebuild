# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

PYTHON_DEPEND="2:2.7 3:3.2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="2.[456] 3.[01]"

inherit distutils git-2

DESCRIPTION="Initial tagging script for Notmuch"
HOMEPAGE="https://github.com/teythoon/afew"
EGIT_REPO_URI="git://github.com/teythoon/afew.git"

LICENSE="ISC"
SLOT="0"
KEYWORDS=""
IUSE="doc"

DEPEND="
	doc? ( dev-python/sphinx )
	"
RDEPEND="app-text/dbacl
	net-mail/notmuch[python]
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

	dodoc afew/defaults/afew.config

	if use doc; then
		dohtml -r docs/build/html/*
		dodoc docs/move_mode
	fi
}
