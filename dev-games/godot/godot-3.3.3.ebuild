# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python2_7 python3_{6..10} )

inherit eutils python-any-r1 scons-utils flag-o-matic llvm desktop

DESCRIPTION="Multi-platform 2D and 3D game engine"
HOMEPAGE="http://godotengine.org"
LICENSE="MIT"
SLOT="0"

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/godotengine/${PN}"
	EGIT_BRANCH="master"
else
	SRC_URI="https://github.com/godotengine/${PN}/archive/${PV}-stable.zip -> ${P}.zip"
	S="${WORKDIR}/${P}-stable"
	KEYWORDS="~amd64 ~x86"
fi

MONO_VERSION="6.12.0.122"

IUSE="
	bullet
	debug
	+enet
	+freetype
	llvm
	lto
	+mbedtls
	+upnp
	mono
	+ogg
	+opus
	+pcre2
	+png
	pulseaudio
	static-libs
	templates
	+theora
	+udev
	+vorbis
	+vpx
	+webp
	+yasm
	+X
	+zlib
	+zstd"

DEPEND="
	app-arch/lz4
	app-arch/zstd
	dev-libs/libpcre2[pcre32]
	media-libs/alsa-lib
	media-libs/libpng:0=
	media-libs/libvpx
	media-libs/mesa[gles2]
	sys-libs/zlib
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXinerama
	virtual/glu
	virtual/opengl
	!static-libs? (
		media-libs/embree:3
		bullet? ( >=sci-physics/bullet-2.89 )
		enet? ( net-libs/enet:= )
		freetype? ( media-libs/freetype:2 )
		mbedtls? ( net-libs/mbedtls )
		ogg? ( media-libs/libogg )
		opus? (
			media-libs/opus
			media-libs/opusfile
		)
		pulseaudio? ( media-sound/pulseaudio )
		theora? ( media-libs/libtheora )
		udev? ( virtual/udev )
		upnp? ( net-libs/miniupnpc )
		vorbis? ( media-libs/libvorbis )
		webp? ( media-libs/libwebp )
	)
	mono? (
		>=dev-lang/mono-${MONO_VERSION}
		dev-dotnet/dotnet-sdk-bin
	)
	"


RDEPEND="${DEPEND}"

BDEPEND="
	>=dev-util/scons-0.98.1
	yasm? ( >=dev-lang/yasm-1.3.0-r1 )
	virtual/pkgconfig
	"

pkg_setup() {
	python-any-r1_pkg_setup
	llvm_pkg_setup
}

src_prepare() {
	default
	rm -r thirdparty/{$(usex bullet bullet ),$(usex embree embree ),$(usex enet enet ),$(usex freetype freetype ),$(usex libogg libogg ),$(usex libpng libpng ),$(usex libtheora libtheora ),$(usex libvorbis libvorbis ),$(usex libvpx libvpx ),$(usex libwebp libwebp),$(usex mbedtls mbedtls ),$(usex miniupnpc miniupnpc),$(usex opus opus ),$(usex pcre2 pcre2 ),$(usex zstd zstd )} || die
}

src_configure() {
	if use llvm && ! tc-is-clang; then
		einfo "Enforcing the use of clang due to USE=llvm ..."
		CC=${CHOST}-clang
		CXX=${CHOST}-clang++
	fi

	strip-unsupported-flags

	MYSCONS=(
		CC="$(tc-getCC)"
		CXX="$(tc-getCXX)"
		builtin_bullet=$(usex static-libs $(usex bullet) no)
		builtin_enet=$(usex static-libs $(usex enet) no)
		builtin_libogg=$(usex static-libs $(usex ogg) no)
		builtin_libpng=$(usex static-libs $(usex png) no)
		builtin_libtheora=$(usex static-libs $(usex theora) no)
		builtin_libvorbis=$(usex static-libs $(usex vorbis) no)
		builtin_libvpx=$(usex static-libs $(usex vpx) no)
		builtin_libwebp=$(usex static-libs $(usex webp) no)
		builtin_mbedtls=$(usex static-libs $(usex mbedtls) no)
		builtin_miniupnpc=$(usex static-libs $(usex miniupnpc) no)
		builtin_opus=$(usex static-libs $(usex opus) no)
		builtin_pcre2=$(usex static-libs $(usex pcre2) no)
		builtin_zlib=$(usex static-libs $(usex zlib) no)
		builtin_zstd=$(usex static-libs $(usex zstd) no)
		module_bullet_enabled=$(usex static-libs no $(usex bullet))
		module_enet_enabled=$(usex static-libs no $(usex enet))
		module_ogg_enabled=$(usex static-libs no $(usex ogg))
		module_png_enabled=$(usex static-libs no $(usex png))
		module_vpx_enabled=$(usex static-libs no $(usex vpx))
		module_mbedtls_enabled=$(usex static-libs no $(usex mbedtls))
		module_miniupnpc=$(usex static-libs no $(usex miniupnpc))
		module_pcre2_enabled=$(usex static-libs no $(usex pcre2))
		module_zlib_enabled=$(usex static-libs no $(usex zlib))
		module_zstd_enabled=$(usex static-libs no $(usex zstd))
		module_freetype_enabled=$(usex static-libs no $(usex freetype))
		module_mbedtls_enabled=$(usex static-libs no $(usex mbedtls))
		module_mono_enabled=$(usex static-libs no $(usex mono))
		mono_glue=no
		module_opus_enabled=$(usex static-libs no $(usex opus))
		module_theora_enabled=$(usex static-libs no $(usex theora))
		module_vorbis_enabled=$(usex static-libs no $(usex vorbis))
		module_webp_enabled=$(usex static-libs no $(usex webp))
		platform=$(usex X x11 server)
		pulseaudio=$(usex pulseaudio)
		tools=yes
		verbose=false
		udev=$(usex udev)
		use_llvm=$(usex llvm)
		use_lld=$(usex llvm)
		use_lto=$(usex lto)
		target=$(usex debug debug release_debug)
	)

	MONOSCONS=(
		CC="$(tc-getCC)"
		CXX="$(tc-getCXX)"
		builtin_bullet=$(usex static-libs $(usex bullet) no)
		builtin_enet=$(usex static-libs $(usex enet) no)
		builtin_libogg=$(usex static-libs $(usex ogg) no)
		builtin_libpng=$(usex static-libs $(usex png) no)
		builtin_libtheora=$(usex static-libs $(usex theora) no)
		builtin_libogg=$(usex static-libs $(usex ogg) no)
		builtin_libpng=$(usex static-libs $(usex png) no)
		builtin_libtheora=$(usex static-libs $(usex theora) no)
		builtin_libvorbis=$(usex static-libs $(usex vorbis) no)
		builtin_libvpx=$(usex static-libs $(usex vpx) no)
		builtin_libwebp=$(usex static-libs $(usex webp) no)
		builtin_mbedtls=$(usex static-libs $(usex mbedtls) no)
		builtin_miniupnpc=$(usex static-libs $(usex miniupnpc) no)
		builtin_opus=$(usex static-libs $(usex opus) no)
		builtin_pcre2=$(usex static-libs $(usex pcre2) no)
		builtin_zlib=$(usex static-libs $(usex zlib) no)
		builtin_zstd=$(usex static-libs $(usex zstd) no)
		module_bullet_enabled=$(usex static-libs no $(usex bullet))
		module_enet_enabled=$(usex static-libs no $(usex enet))
		module_ogg_enabled=$(usex static-libs no $(usex ogg))
		module_png_enabled=$(usex static-libs no $(usex png))
		module_vpx_enabled=$(usex static-libs no $(usex vpx))
		module_mbedtls_enabled=$(usex static-libs no $(usex mbedtls))
		module_miniupnpc=$(usex static-libs no $(usex miniupnpc))
		module_pcre2_enabled=$(usex static-libs no $(usex pcre2))
		module_zlib_enabled=$(usex static-libs no $(usex zlib))
		module_zstd_enabled=$(usex static-libs no $(usex zstd))
		module_freetype_enabled=$(usex static-libs no $(usex freetype))
		module_mbedtls_enabled=$(usex static-libs no $(usex mbedtls))
		module_mono_enabled=$(usex static-libs no $(usex mono))
		mono_glue=yes
		module_opus_enabled=$(usex static-libs no $(usex opus))
		module_theora_enabled=$(usex static-libs no $(usex theora))
		module_vorbis_enabled=$(usex static-libs no $(usex vorbis))
		module_webp_enabled=$(usex static-libs no $(usex webp))
		platform=$(usex X x11 server)
		pulseaudio=$(usex pulseaudio)
		tools=yes
		verbose=false
		udev=$(usex udev)
		use_llvm=$(usex llvm)
		use_lld=$(usex llvm)
		use_lto=$(usex lto)
		target=$(usex debug debug release_debug)
	)
}

src_compile() {
	escons "${MYSCONS[@]}"
	if use mono; then
		if [[ "${ARCH}" == "amd64" ]]; then
			BITS=64
		fi
		if [[ "${ARCH}" == "x86" ]]; then
			BITS=32
		fi
		if use llvm; then
			LLVMBOOL=".llvm"
		else
			LLVMBOOL=""
		fi
		bin/godot.x11.opt.tools.${BITS}${LLVMBOOL} --generate-mono-glue modules/mono/glue
		rm -rvf bin/* || die
		escons "${MONOSCONS[@]}"
	fi
}

src_install() {
	newicon icon.svg ${PN}.svg
	dobin bin/godot.*
	if [[ "${ARCH}" == "amd64" ]]; then
		if use llvm; then
			make_desktop_entry godot.x11.opt.tools.64.llvm Godot
			with_desktop_entry=1
		else
			make_desktop_entry godot.x11.opt.tools.64 Godot
			with_desktop_entry=1
		fi
	fi

	if [[ "${ARCH}" == "x86" ]]; then
		if use llvm; then
			make_desktop_entry godot.x11.opt.tools.32.llvm Godot
			with_desktop_entry=1
		else
			make_desktop_entry godot.x11.opt.tools.32 Godot
			with_desktop_entry=1
		fi
	fi

	if ! [[ "${with_desktop_entry}" == "1" ]]; then
		elog "Couldn't detect running architecture to create a desktop file."
	fi
}
