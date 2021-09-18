# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
whoami-1.1
serde_derive-1.0
serde-1.0
serde_json-1.0
cfg-if-1.0
lazy_static-1.4
sha2-0.9
repng-0.2
libc-0.2
https://github.com/open-trade/parity-tokio-ipc
flexi-logger-0.17
runas-0.2
https://github.com/open-trade/magnum-opus
dasp-0.11
rubato-0.8
samplerate-0.2
async-trait-0.1
crc32-fast-1.2
uuid-0.8
clap-2.33
rpassword-5.0
"

inherit cargo
inherit git-r3

DESCRIPTION="Yet another remote access client."
HOMEPAGE="https://rustdesk.com"
SRC_URI="https://github.com/rustdesk/rustdesk/archive/refs/tags/${PV}.tar.gz"
EGIT_REPO_URI="https://github.com/microsoft/vcpkg.git"
PATCHES="scrap_build_rs.patch"

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
	git-r3_src_unpack "https://github.com/microsoft/vcpkg.git" ${WORKDIR}/vcpkg
	cd ${WORKDIR}/vcpkg
	git checkout 134505003bb46e20fbace51ccfb69243fbbc5f82
	cd ..
	${WORKDIR}/vcpkg/bootstrap-vcpkg.sh
	${WORKDIR}/vcpkg/vcpkg install libvpx libyuv opus
	cargo_src_unpack
	cd ${WORKDIR}/rustdesk-${PV} || die
	eapply "${FILESDIR}/${PATCHES}"
	eapply_user
	cd ..
}

src_configure()
{
	cargo_src_configure
}

src_compile()
{
	export GCC_INCLUDE=/usr/lib/gcc/x86_64-pc-linux-gnu/10.3.0/include
	export VCPKG_ROOT=${WORKDIR}/vcpkg
	export LIBCLANG_PATH=/usr/lib/llvm/12/lib64
	cd rustdesk-${PV} || die
	if use debug; then
		BIN="debug"
	else
		BIN="release"
	fi
	mkdir -p target/${BIN}
	wget https://raw.githubusercontent.com/c-smile/sciter-sdk/master/bin.lnx/x64/libsciter-gtk.so
	mv libsciter-gtk.so target/${BIN}
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
