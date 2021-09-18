# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cargo

DESCRIPTION="Yet another remote access client."
HOMEPAGE="https://rustdesk.com"
SRC_URI="https://github.com/rustdesk/rustdesk/archive/refs/tags/${PV}.tar.gz"
PATCHES=["scrap_build_rs.patch"]

LICENSE="GPLv3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	media-libs/alsa-lib
	media-sound/pulseaudio[X,alsa,alsa-plugin]
	media-plugins/alsa-plugins[pulseaudio]
	sys-libs/glibc
	gui-libs/gtk[X]
	x11-misc/xdotool
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-lang/rust
	dev-lang/nasm
	dev-lang/yasm
	dev-vcs/git
	sys-devel/clang
"

src_unpack()
{
	cargo_src_unpack
}

src_prepare()
{
	eapply "$PATCHES[@]"
	eapply_user
}

src_configure()
{
	cargo_src_configure
}

src_compile()
{
	cd rustdesk || die
	cargo_src_compile
}

src_install()
{
	cargo_src_install --path rustdesk
}

src_test()
{
	cd rustdesk || die
	cargo_src_test
}
