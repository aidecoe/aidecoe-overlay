# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DISTUTILS_OPTIONAL=1
PYTHON_COMPAT=( python{2_6,2_7,3_2,3_3} )

inherit elisp-common pax-utils distutils-r1 git-2

DESCRIPTION="Thread-based e-mail indexer, supporting quick search and tagging"
HOMEPAGE="http://notmuchmail.org/"
EGIT_REPO_URI="git://git.notmuchmail.org/git/notmuch"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
REQUIRED_USE="
	pick? ( emacs )
	python? ( ${PYTHON_REQUIRED_USE} )
	test? ( crypt emacs python )
	"
IUSE="bash-completion crypt debug doc emacs mutt nmbug pick python test
	zsh-completion"

CDEPEND="
	>=dev-libs/glib-2.22
	>=dev-libs/gmime-2.6.7
	dev-libs/xapian
	sys-libs/talloc
	debug? ( dev-util/valgrind )
	emacs? ( >=virtual/emacs-23 )
	python? ( ${PYTHON_DEPS} )
	x86? ( >=dev-libs/xapian-1.2.7-r2 )
	"
DEPEND="${CDEPEND}
	virtual/pkgconfig
	doc? ( python? ( dev-python/sphinx[${PYTHON_USEDEP}] ) )
	test? ( app-misc/dtach || ( >=app-editors/emacs-23[libxml2]
		>=app-editors/emacs-vcs-23[libxml2] ) sys-devel/gdb )
	"
RDEPEND="${CDEPEND}
	crypt? ( app-crypt/gnupg )
	nmbug? ( dev-vcs/git virtual/perl-File-Temp virtual/perl-PodParser )
	mutt? ( dev-perl/File-Which dev-perl/Mail-Box dev-perl/MailTools
		dev-perl/String-ShellQuote dev-perl/Term-ReadLine-Gnu
		virtual/perl-Digest-SHA virtual/perl-File-Path virtual/perl-Getopt-Long
		virtual/perl-PodParser
		)
	zsh-completion? ( app-shells/zsh )
	"

DOCS=( AUTHORS NEWS README )
SITEFILE="50${PN}-gentoo.el"
SITEFILE_PICK="60${PN}-pick-gentoo.el"
MY_LD_LIBRARY_PATH="${WORKDIR}/${P}/lib"

bindings() {
	local ret=0

	if use $1; then
		pushd bindings/$1 || die
		shift
		"$@"
		ret=$?
		popd || die
	fi

	return $ret
}

pkg_setup() {
	if use emacs; then
		elisp-need-emacs 23 || die "Emacs version too low"
	fi
}

src_prepare() {
	default
	bindings python distutils-r1_src_prepare
	bindings python mv README README-python || die
	mv contrib/notmuch-mutt/README contrib/notmuch-mutt/README-mutt || die
	mv contrib/notmuch-pick/README contrib/notmuch-pick/README-pick || die
}

src_configure() {
	local myeconfargs=(
		--bashcompletiondir="${ROOT}/usr/share/bash-completion"
		--emacslispdir="${ROOT}/${SITELISP}/${PN}"
		--emacsetcdir="${ROOT}/${SITEETC}/${PN}"
		--with-gmime-version=2.6
		--zshcompletiondir="${ROOT}/usr/share/zsh/site-functions"
		$(use_with bash-completion)
		$(use_with emacs)
		$(use_with zsh-completion)
	)
	econf "${myeconfargs[@]}"
}

src_compile() {
	default
	bindings python distutils-r1_src_compile

	if use mutt; then
		pushd contrib/notmuch-mutt || die
		emake notmuch-mutt.1
		popd || die
	fi

	if use doc; then
		pydocs() {
			pushd docs || die
			emake html
			mv html ../python || die
			popd || die
		}
		LD_LIBRARY_PATH="${MY_LD_LIBRARY_PATH}" bindings python pydocs
	fi
}

src_test() {
	pax-mark -m notmuch
	LD_LIBRARY_PATH="${MY_LD_LIBRARY_PATH}" default
	pax-mark -ze notmuch
}

src_install() {
	default

	if use emacs; then
		elisp-site-file-install "${FILESDIR}/${SITEFILE}" || die

		if use pick; then
			pushd contrib/notmuch-pick || die
			elisp-install "${PN}" notmuch-pick.el || die
			dodoc README-pick
			popd || die
			elisp-site-file-install "${FILESDIR}/${SITEFILE_PICK}" || die
		fi
	fi

	if use nmbug; then
		dobin devel/nmbug/nmbug
	fi

	if use mutt; then
		[[ -e /etc/mutt/notmuch-mutt.rc ]] && NOTMUCH_MUTT_RC_EXISTS=1
		pushd contrib/notmuch-mutt || die
		dobin notmuch-mutt
		doman notmuch-mutt.1
		insinto /etc/mutt
		doins notmuch-mutt.rc
		dodoc README-mutt
		popd || die
	fi

	DOCS="" bindings python distutils-r1_src_install
	use doc && bindings python dohtml -r python
}

pkg_postinst() {
	use emacs && elisp-site-regen

	if use mutt && [[ ! ${NOTMUCH_MUTT_RC_EXISTS} ]]; then
		elog "To enable notmuch support in mutt, add the following line into"
		elog "your mutt config file, please:"
		elog ""
		elog "  source /etc/mutt/notmuch-mutt.rc"
	fi
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
