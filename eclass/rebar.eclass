# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

#
# Original Author: Amadeusz Żołnowski <aidecoe@gentoo.org>
# Purpose:
#

inherit eutils

EXPORT_FUNCTIONS src_prepare src_compile src_install

get_erl_libs() {
	echo "/usr/$(get_libdir)/erlang/lib"
}

RDEPEND="dev-lang/erlang"
DEPEND="${RDEPEND}
	dev-util/rebar"

export ERL_LIBS="${EPREFIX}$(get_erl_libs)"

awk_i() {
	local f="$1"; shift

	[[ -e ${f}.new ]] && return 1
	awk "$@" "${f}" >"${f}.new" || return 1
	mv "${f}.new" "${f}" || return 1
}

find_dep_version() {
	local pn="$1"
	local p

	pushd "${EPREFIX}$(get_erl_libs)" >/dev/null
	for p in ${pn} ${pn}-*; do
		if [[ -d ${p} ]]; then
			echo "${p#${pn}-}"
			return 0
		fi
	done
	popd >/dev/null

	return 1
}

rebar_fix_include_path() {
	local pn="$1"
	local rebar_config="${2:-rebar.config}"
	local erl_libs="${EPREFIX}$(get_erl_libs)"
	local pv="$(find_dep_version "${pn}")"

	awk_i "${rebar_config}" \
		-v erl_libs="${erl_libs}" -v pn="${pn}" -v pv="${pv}" \
		'/^{[[:space:]]*erl_opts[[:space:]]*,/, /}[[:space:]]*\.$/ {
	pattern = "\"(./)?deps/" pn "/include\"";
	if (match($0, "{i,[[:space:]]*" pattern "[[:space:]]*}")) {
		sub(pattern, "\"" erl_libs "/" pn "-" pv "/include\"");
	}
	print $0;
	next;
}
1
' || die "failed to fix include paths in ${rebar_config}"
}

rebar_remove_deps() {
	local rebar_config="${1:-rebar.config}"

	mkdir -p "${S}/deps" && :>"${S}/deps/.got" && :>"${S}/deps/.built" || die
	awk_i "${rebar_config}" \
		'/^{[[:space:]]*deps[[:space:]]*,/, /}[[:space:]]*\.$/ {
	if ($0 ~ /}[[:space:]]*\.$/) {
		print "{deps, []}.";
	}
	next;
}
1
' || die "failed to remove deps from ${rebar_config}"
}

rebar_set_vsn() {
	local version="${1:-${PV%_*}}"

	sed -e "s/vsn, git/vsn, \"${version}\"/" \
		-i "${S}/src/${PN}.app.src" \
		|| die "failed to set version in src/${PN}.app.src"
}

rebar_src_prepare() {
	debug-print-function ${FUNCNAME} "${@}"

	rebar_set_vsn
	[[ -f rebar.config ]] && rebar_remove_deps
}

rebar_src_compile() {
	debug-print-function ${FUNCNAME} "${@}"

	rebar -v compile || die 'rebar compile failed'

	if use_if_iuse doc; then
		rebar -v skip_deps=true doc || die 'rebar doc failed'
	fi
}

rebar_src_install() {
	debug-print-function ${FUNCNAME} "${@}"

	local bin
	local dest="$(get_erl_libs)/${P}"

	insinto "${dest}"
	doins -r ebin
	[[ -d include ]] && doins -r include
	[[ -d bin ]] && for bin in bin/*; do dobin "$bin"; done
	[[ -d priv ]] && cp -pR priv "${ED}${dest}/"

	einstalldocs
	use_if_iuse doc && dohtml -r doc/*
}
