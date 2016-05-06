# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit multilib

MY_PN="epam"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="epam for ejabberd to help with PAM authentication support"
HOMEPAGE="https://github.com/processone/epam"
SRC_URI="https://github.com/processone/${MY_PN}/archive/${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND=">=dev-lang/erlang-17.1"
DEPEND="${CDEPEND}
	dev-util/rebar"
RDEPEND="${CDEPEND}"

RESTRICT=strip

S="${WORKDIR}/${MY_P}"

get_erl_libs() {
	echo "/usr/$(get_libdir)/erlang/lib"
}

src_compile() {
	export ERL_LIBS="${EPREFIX}$(get_erl_libs)"
	rebar -v compile || die 'rebar compile failed'
}

src_install() {
	insinto "$(get_erl_libs)/${P}"
	doins -r ebin priv src
}
