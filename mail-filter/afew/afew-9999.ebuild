# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{3_2,3_3} )

inherit distutils-r1 git-2

DESCRIPTION="Initial tagging script for Notmuch"
HOMEPAGE="https://github.com/teythoon/afew"
EGIT_REPO_URI="git://github.com/teythoon/afew.git"

LICENSE="ISC"
SLOT="0"
KEYWORDS=""
IUSE="doc"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )
	"
RDEPEND="app-text/dbacl
	dev-python/chardet[${PYTHON_USEDEP}]
	net-mail/notmuch[python]
	"

src_prepare() {
	sed -e "/'subprocess32',/d" -i setup.py

	distutils-r1_src_prepare

	local md
	for md in *.md; do
		mv "${md}" "${md%.md}"
	done
}

src_compile() {
	distutils-r1_src_compile

	if use doc; then
		pushd docs || die
		emake html
		popd || die
	fi
}

src_install() {
	distutils-r1_src_install

	dodoc afew/defaults/afew.config

	if use doc; then
		dohtml -r docs/build/html/*
	fi
}
