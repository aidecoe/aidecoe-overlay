# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: rebar.eclass
# @MAINTAINER:
# Amadeusz Żołnowski <aidecoe@gentoo.org>
# @AUTHOR:
# Amadeusz Żołnowski <aidecoe@gentoo.org>
# @BLURB: Build Erlang/OTP projects using dev-util/rebar.
# @DESCRIPTION:
# An eclass providing functions to build Erlang/OTP projects using
# dev-util/rebar.
#
# rebar is a tool which tries to resolve dependencies itself which is by
# cloning remote git repositories. Dependant projects are usually expected to
# be in sub-directory 'deps' rather than looking at system Erlang lib
# directory. Projects relying on rebar usually don't have 'install' make
# targets. The eclass workarounds some of these problems. It handles
# installation in a generic way for Erlang/OTP structured projects.

case "${EAPI:-0}" in
	0|1|2|3|4|5)
		die "Unsupported EAPI=${EAPI:-0} (too old) for ${ECLASS}"
		;;
	6)
		;;
	*)
		die "Unsupported EAPI=${EAPI} (unknown) for ${ECLASS}"
		;;
esac

inherit eutils

EXPORT_FUNCTIONS src_prepare src_compile src_install

RDEPEND="dev-lang/erlang"
DEPEND="${RDEPEND}
	dev-util/rebar"

# @ECLASS-VARIABLE: REBAR_APP_SRC
# @DESCRIPTION:
# Relative path to .app.src description file.
REBAR_APP_SRC="${REBAR_APP_SRC-src/${PN}.app.src}"

# @FUNCTION: get_erl_libs
# @RETURN: the path to Erlang lib directory
# @DESCRIPTION:
# Get the full path without EPREFIX to Erlang lib directory.
get_erl_libs() {
	echo "/usr/$(get_libdir)/erlang/lib"
}

# @FUNCTION: _rebar_find_dep_version
# @INTERNAL
# @USAGE: <project_name>
# @RETURN: full path with EPREFIX to a Erlang package/project
# @DESCRIPTION:
# Find a Erlang package/project by name in Erlang lib directory. Project
# directory is usually suffixed with version. First match to <project_name> or
# <project_name>-* is returned.
_rebar_find_dep_version() {
	local pn="$1"
	local p

	pushd "${EPREFIX}$(get_erl_libs)" >/dev/null || die
	for p in ${pn} ${pn}-*; do
		if [[ -d ${p} ]]; then
			echo "${p#${pn}-}"
			break
		fi
	done
	popd >/dev/null || die

	[[ -d ${p} ]]
}

# @FUNCTION: eawk
# @USAGE: <file> <args>
# @DESCRIPTION:
# Edit file <file> in place with awk. Pass all arguments following <file> to
# awk.
eawk() {
	local f="$1"; shift
	local tmpf="$(emktemp)"

	cat "${f}" >"${tmpf}" || return 1
	awk "$@" "${tmpf}" >"${f}"
}

# @FUNCTION: erebar
# @USAGE: <targets>
# @DESCRIPTION:
# Run rebar with verbose flag. Die on failure.
erebar() {
	debug-print-function ${FUNCNAME} "${@}"

	(( $# > 0 )) || die 'erebar: at least one target is required'

	evar_push ERL_LIBS
	export ERL_LIBS="${EPREFIX}$(get_erl_libs)"
	rebar -v skip_deps=true "$@" || die "rebar $@ failed"
	evar_pop
}

# @FUNCTION: rebar_fix_include_path
# @USAGE: <project_name>
# @DESCRIPTION:
# Fix path in rebar.config to 'include' directory of dependant project/package,
# so it points to installation in system Erlang lib rather than relative 'deps'
# directory.
#
# The function dies on failure.
rebar_fix_include_path() {
	debug-print-function ${FUNCNAME} "${@}"

	local pn="$1"
	local erl_libs="${EPREFIX}$(get_erl_libs)"
	local pv="$(_rebar_find_dep_version "${pn}")"

	eawk rebar.config \
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
' || die "failed to fix include paths in rebar.config"
}

# @FUNCTION: rebar_remove_deps
# @DESCRIPTION:
# Remove dependencies list from rebar.config and deceive build rules that any
# dependencies are already fetched and built. Otherwise rebar tries to fetch
# dependencies and compile them.
#
# The function dies on failure.
rebar_remove_deps() {
	debug-print-function ${FUNCNAME} "${@}"

	mkdir -p "${S}/deps" && :>"${S}/deps/.got" && :>"${S}/deps/.built" || die
	eawk rebar.config \
		'/^{[[:space:]]*deps[[:space:]]*,/, /}[[:space:]]*\.$/ {
	if ($0 ~ /}[[:space:]]*\.$/) {
		print "{deps, []}.";
	}
	next;
}
1
' || die "failed to remove deps from rebar.config"
}

# @FUNCTION: rebar_set_vsn
# @USAGE: [<version>]
# @DESCRIPTION:
# Set version in project description file if it's not set.
#
# <version> is optional. Default is PV stripped from version suffix.
#
# The function dies on failure.
rebar_set_vsn() {
	debug-print-function ${FUNCNAME} "${@}"

	local version="${1:-${PV%_*}}"

	sed -e "s/vsn, git/vsn, \"${version}\"/" \
		-i "${S}/${REBAR_APP_SRC}" \
		|| die "failed to set version in src/${PN}.app.src"
}

# @FUNCTION: rebar_src_prepare
# @DESCRIPTION:
# Prevent rebar from fetching in compiling dependencies. Set version in project
# description file if it's not set.
#
# Existence of rebar.config is optional, but file description file must exist
# at 'src/${PN}.app.src'.
rebar_src_prepare() {
	debug-print-function ${FUNCNAME} "${@}"

	default
	rebar_set_vsn
	[[ -f rebar.config ]] && rebar_remove_deps
}

# @FUNCTION: rebar_src_configure
# @DESCRIPTION:
# Configure with ERL_LIBS set.
rebar_src_configure() {
	debug-print-function ${FUNCNAME} "${@}"

	evar_push ERL_LIBS
	export ERL_LIBS="${EPREFIX}$(get_erl_libs)"
	default
	evar_pop
}

# @FUNCTION: rebar_src_compile
# @DESCRIPTION:
# Compile project with rebar.
rebar_src_compile() {
	debug-print-function ${FUNCNAME} "${@}"

	erebar compile
}

# @FUNCTION: rebar_src_install
# @DESCRIPTION:
# Install BEAM files, include headers, executables and native libraries.
# Install standard docs like README or defined in DOCS variable.
#
# Function expects that project conforms to Erlang/OTP structure.
rebar_src_install() {
	debug-print-function ${FUNCNAME} "${@}"

	local dest="$(get_erl_libs)/${P}"

	insinto "${dest}"
	doins -r ebin
	[[ -d include ]] && doins -r include
	[[ -d priv ]] && cp -pR priv "${ED}${dest}/"

	if [[ -d bin ]]; then
		local bin
		for bin in bin/*; do
			dobin "$bin"
		done
	fi

	einstalldocs
}
