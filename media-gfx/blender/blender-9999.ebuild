# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_10 )
LLVM_MAX_SLOT="14"

inherit check-reqs cmake flag-o-matic pax-utils python-single-r1 toolchain-funcs xdg-utils

DESCRIPTION="Blender is a free and open-source 3D creation suite."
HOMEPAGE="https://www.blender.org"

inherit git-r3
if [[ ${PV} == 9999 ]]; then
	#inherit git-r3
	EGIT_REPO_URI="https://git.blender.org/blender"
	EGIT_SUBMODULES=( release/datafiles/locale )
	EGIT_BRANCH="master"
	#EGIT_COMMIT=""
    KEYWORDS=""
	MY_PV="3.3"
else
	#SRC_URI="https://download.blender.org/source/${P}.tar.xz"
	#TEST_TARBALL_VERSION=2.93.0
	#SRC_URI+=" test? ( https://dev.gentoo.org/~sam/distfiles/${CATEGORY}/${PN}/${PN}-${TEST_TARBALL_VERSION}-tests.tar.bz2 )"
	MY_PV="$(ver_cut 1-2)"
	EGIT_REPO_URI="https://git.blender.org/blender"
	EGIT_SUBMODULES=( release/datafiles/locale )
	EGIT_BRANCH="blender-v${MY_PV}-release"
    #EGIT_COMMIT="3e85bb34d0d792b49cf4923f781d98791c5a161c"
	KEYWORDS="~amd64 ~x86 ~arm64"
fi

SLOT="${MY_PV}"
LICENSE="|| ( GPL-3 BL )"
CUDA_ARCHS="sm_30 sm_35 sm_50 sm_52 sm_61 sm_70 sm_75 sm_86"
IUSE_DESKTOP="cg -portable +X headless wayland +addons +addons_contrib +nls +icu -ndof"
IUSE_GPU="+opengl -optix cuda ${CUDA_ARCHS}"
IUSE_LIBS="clang +cycles gmp sdl jack openal pulseaudio +freestyle -osl +openvdb nanovdb abi6-compat abi7-compat abi8-compat abi9-compat +opensubdiv +opencolorio +openimageio +pdf +pugixml +potrace +collada -alembic +gltf-draco +fftw +oidn +quadriflow -usd +bullet -valgrind +jemalloc libmv +llvm"
IUSE_CPU="+openmp embree +simd +tbb +lld gold"
IUSE_TEST="-debug -doc -man -gtests test"
IUSE_IMAGE="-dpx -dds +openexr jpeg2k tiff +hdr webp"
IUSE_CODEC="avi +ffmpeg -sndfile +quicktime"
IUSE_COMPRESSION="+lzma -lzo"
IUSE_MODIFIERS="+fluid +smoke +oceansim +remesh"
IUSE="${IUSE_DESKTOP} ${IUSE_GPU} ${IUSE_LIBS} ${IUSE_CPU} ${IUSE_TEST} ${IUSE_IMAGE} ${IUSE_CODEC} ${IUSE_COMPRESSION} ${IUSE_MODIFIERS}"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	|| ( gold lld )
	|| ( headless wayland X )
	alembic? ( openexr )
	embree? ( cycles tbb )
	smoke? ( fftw )
	cuda? ( cycles )
	cycles? ( openexr tiff openimageio )
	fluid?  ( fftw tbb )
	oceansim? ( fftw )
	oidn? ( cycles tbb )
	openexr? ( openimageio )
	optix? ( cycles cuda )
	openvdb? (
		^^ ( abi6-compat abi7-compat abi8-compat abi9-compat )
		cycles tbb
	)
	osl? ( cycles llvm )
	test? ( gtests opencolorio )
	tiff? ( openimageio )
"

LANGS="en ar bg ca cs de el es es_ES fa fi fr he hr hu id it ja ky ne nl pl pt pt_BR ru sr sr@latin sv tr uk zh_CN zh_TW"
for X in ${LANGS} ; do
	IUSE+=" linguas_${X}"
	REQUIRED_USE+=" linguas_${X}? ( nls )"
done

RDEPEND="${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/zstandard[${PYTHON_USEDEP}]
        dev-libs/boost[python,nls?,icu?,threads(+),${PYTHON_USEDEP}]
	')
	media-libs/freetype:=
	app-arch/brotli:=[static-libs]
	media-libs/libpng:=
	media-libs/libsamplerate
	sys-libs/zlib:=
	virtual/jpeg
	virtual/libintl
	addons? ( media-blender/addons:${SLOT} )
	addons_contrib? ( media-blender/addons_contrib:${SLOT} )
	alembic? ( media-gfx/alembic:=[boost(+),-hdf5] )
	collada? ( media-libs/opencollada )
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	embree? ( >=media-libs/embree-3.10.0[raymask,tbb?] )
	ffmpeg? ( media-video/ffmpeg:=[x264,mp3,encode,theora,jpeg2k?,vpx,vorbis,opus,xvid] )
	fftw? ( sci-libs/fftw:3.0=[openmp?] )
	gltf-draco? ( media-libs/draco[gltf] )
	gmp? ( dev-libs/gmp )
	gtests? (
		dev-cpp/gflags
		dev-cpp/glog[gflags]
	)
	X? (
		x11-libs/libX11
		x11-libs/libXi
		x11-libs/libXxf86vm
	)
	wayland? (
		dev-libs/wayland
		gui-libs/egl-wayland
		dev-util/wayland-scanner
		x11-libs/libxkbcommon
		sys-apps/dbus
	)
	jack? ( virtual/jack )
	jemalloc? ( dev-libs/jemalloc:= )
	jpeg2k? ( media-libs/openjpeg:2= )
	libmv? ( sci-libs/ceres-solver )
	lld? ( <sys-devel/lld-$((${LLVM_MAX_SLOT} + 1)):= )
	llvm? ( <sys-devel/llvm-$((${LLVM_MAX_SLOT} + 1)):= )
    clang? ( <sys-devel/clang-$((${LLVM_MAX_SLOT} + 1)):= )
	lzo? ( dev-libs/lzo:2= )
	ndof? (
		app-misc/spacenavd
		dev-libs/libspnav
	)
	nanovdb? ( media-gfx/openvdb[cuda?,nanovdb?] )
	nls? ( virtual/libiconv )
	openal? ( media-libs/openal )
	opengl? (
		virtual/opengl
		media-libs/glew:*
		virtual/glu
	)
	oidn? ( media-libs/oidn )
	openimageio? ( >=media-libs/openimageio-2.3.12.0-r3:= )
	opencolorio? ( >=media-libs/opencolorio-2.1.1-r7:= )
	openexr? ( media-libs/openexr:= )
	opensubdiv? ( media-libs/opensubdiv[cuda?,openmp?,tbb?] )
	openvdb? (
		>=media-gfx/openvdb-9.0.0[abi6-compat(-)?,abi7-compat(-)?,abi8-compat(-)?,abi9-compat(-)?]
		dev-libs/c-blosc:=
	)
	optix? ( =dev-libs/optix-7.4.0 )
	osl? ( >=media-libs/osl-1.11.10.0 )
	pdf? ( media-libs/libharu )
	potrace? ( media-gfx/potrace )
	pugixml? ( dev-libs/pugixml )
	pulseaudio? ( media-sound/pulseaudio )
	quicktime? ( media-libs/libquicktime )
	sdl? ( media-libs/libsdl2[sound,joystick] )
	sndfile? ( media-libs/libsndfile )
	tbb? ( dev-cpp/tbb:= )
	tiff? ( media-libs/tiff )
	usd? ( media-libs/openusd[monolithic,-python] )
	valgrind? ( dev-util/valgrind )
	webp? ( media-libs/libwebp )
"

DEPEND="${RDEPEND}
	dev-cpp/eigen:=
"

BDEPEND="
	virtual/pkgconfig
	nls? ( sys-devel/gettext )
	doc? (
		dev-python/sphinx
		app-doc/doxygen[-nodot(-),dot(+)]
	)
"

RESTRICT="
	mirror
	!test? ( test )
"

QA_WX_LOAD="usr/share/${PN}/${MY_PV}/scripts/addons/cycles/lib/kernel_sm_*.cubin"
QA_PREBUILT="${QA_WX_LOAD}"
QA_PRESTRIPPED="${QA_WX_LOAD}"
QA_FLAGS_IGNORED="${QA_WX_LOAD}"

blender_check_requirements() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp

	if use doc; then
		CHECKREQS_DISK_BUILD="4G" check-reqs_pkg_pretend
	fi
}

blender_get_version() {
	# Get blender version from blender itself.
	BV=$(grep "BLENDER_VERSION " source/blender/blenkernel/BKE_blender_version.h | cut -d " " -f 3; assert)
	if ((${BV:0:1} < 3)) ; then
		# Add period (290 -> 2.90).
		BV=${BV:0:1}.${BV:1}
	else
		# Add period and strip last number (300 -> 3.0)
		BV=${BV:0:1}.${BV:2}
	fi
}

pkg_pretend() {
	blender_check_requirements
}

pkg_setup() {
	blender_check_requirements
	python-single-r1_pkg_setup
}

src_unpack() {
	git-r3_src_unpack

	if use test; then
		default
		mkdir -p lib || die
		mv "${WORKDIR}"/blender-${TEST_TARBALL_VERSION}-tests/tests lib || die
	fi
}

src_prepare() {
	python_setup

	cmake_src_prepare

	blender_get_version

	eapply "${FILESDIR}/x112.patch"
	eapply "${FILESDIR}/${MY_PV}/blender-system-glog-gflags.patch"
	eapply "${FILESDIR}/Fix-build-with-system-glew.patch"
	if use cg; then
        eapply "${FILESDIR}"/cg-defaults.patch
    fi

	if use addons_contrib; then
        #set BLENDER_ADDONS_DIR to userpref
        if ! [ -d "${BLENDER_ADDONS_DIR}" ]; then
        	BLENDER_ADDONS_DIR="/usr/share/blender/${SLOT}/scripts/addons/"
        fi
        sed -i -e "s|.pythondir.*|.pythondir = \"${BLENDER_ADDONS_DIR}\",|" "${S}"/release/datafiles/userdef/userdef_default.c || die
    fi
	# remove some bundled deps
	rm -rf extern/{Eigen3,glew-es,lzo,gflags,glog,draco,glew} || die

	# we don't want static glew, but it's scattered across
	# multiple files that differ from version to version
	# !!!CHECK THIS SED ON EVERY VERSION BUMP!!!
	local file
	while IFS="" read -d $'\0' -r file ; do
		sed -i -e '/-DGLEW_STATIC/d' "${file}" || die
	done < <(find . -type f -name "CMakeLists.txt")

	# Disable MS Windows help generation. The variable doesn't do what it
	# it sounds like.
	sed -e "s|GENERATE_HTMLHELP      = YES|GENERATE_HTMLHELP      = NO|" \
		-i doc/doxygen/Doxyfile || die

	# Prepare icons and .desktop files for slotting.
	sed -e "s|blender.svg|blender-${MY_PV}.svg|" -i source/creator/CMakeLists.txt || die
	sed -e "s|blender-symbolic.svg|blender-${MY_PV}-symbolic.svg|" -i source/creator/CMakeLists.txt || die
	sed -e "s|blender.desktop|blender-${MY_PV}.desktop|" -i source/creator/CMakeLists.txt || die

	sed -e "s|Name=Blender|Name=Blender ${MY_PV}|" -i release/freedesktop/blender.desktop || die
	sed -e "s|Exec=blender|Exec=blender-${MY_PV}|" -i release/freedesktop/blender.desktop || die
	sed -e "s|Icon=blender|Icon=blender-${MY_PV}|" -i release/freedesktop/blender.desktop || die

	mv release/freedesktop/icons/scalable/apps/blender.svg release/freedesktop/icons/scalable/apps/blender-${MY_PV}.svg || die
	mv release/freedesktop/icons/symbolic/apps/blender-symbolic.svg release/freedesktop/icons/symbolic/apps/blender-${MY_PV}-symbolic.svg || die
	mv release/freedesktop/blender.desktop release/freedesktop/blender-${MY_PV}.desktop || die

	if use test; then
		# Without this the tests will try to use /usr/bin/blender and /usr/share/blender/ to run the tests.
		sed -e "s|string(REPLACE.*|set(TEST_INSTALL_DIR ${ED}/usr/)|g" -i tests/CMakeLists.txt || die
		sed -e "s|string(REPLACE.*|set(TEST_INSTALL_DIR ${ED}/usr/)|g" -i build_files/cmake/Modules/GTestTesting.cmake || die
	fi

	ewarn "$(echo "Remaining bundled dependencies:";
			( find extern -mindepth 1 -maxdepth 1 -type d; ) | sed 's|^|- |')"

	# linguas cleanup
	local i
	if ! use nls; then
		rm -r "${S}"/release/datafiles/locale || die
	else
		if [[ -n "${LINGUAS+x}" ]] ; then
			cd "${S}"/release/datafiles/locale/po
			for i in *.po ; do
				mylang=${i%.po}
				has ${mylang} ${LINGUAS} || { rm -r ${i} || die ; }
			done
		fi
	fi

}

src_configure() {
	use debug && CMAKE_BUILD_TYPE="Debug" || CMAKE_BUILD_TYPE="Release"
	for slot in $(seq 10 ${LLVM_MAX_SLOT}); do
		has_version "sys-devel/llvm:${slot}" && LLVM_SLOT="${slot}"
	done

	python_setup

	# FIX: forcing '-funsigned-char' fixes an anti-aliasing issue with menu
	# shadows, see bug #276338 for reference
	append-flags -funsigned-char -fno-strict-aliasing
	append-lfs-flags

	if use openvdb; then
		local version
		if use abi6-compat; then
			version=6;
		elif use abi7-compat; then
			version=7;
        elif use abi8-compat; then
			version=8;
		elif use abi9-compat; then
			version=9
		else
			die "Openvdb abi version not compatible"
		fi
		append-cppflags -DOPENVDB_ABI_VERSION_NUMBER=${version}
	fi

	local mycmakeargs=()
	#CUDA Kernel Selection
	local CUDA_ARCH=""
	if use cuda; then
		for CA in ${CUDA_ARCHS}; do
			use ${CA} && CUDA_ARCH+="${CA};"
		done

		#If a kernel isn't selected then all of them are built by default
		if [ -n "${CUDA_ARCH}" ] ; then
			mycmakeargs+=(
				-DCYCLES_CUDA_BINARIES_ARCH=${CUDA_ARCH::-1}
			)
		fi
		mycmakeargs+=(
			-DWITH_CYCLES_CUDA=ON
			-DWITH_CYCLES_CUDA_BINARIES=ON
			-DCUDA_INCLUDE_DIRS=/opt/cuda/include
			-DCUDA_CUDART_LIBRARY=/opt/cuda/lib64
			-DCUDA_NVCC_EXECUTABLE=/opt/cuda/bin/nvcc
			-DCUDA_NVCC_FLAGS=-std=c++11
		)
	fi

	if use optix; then
		mycmakeargs+=(
			-DOPTIX_ROOT_DIR=/opt/optix/SDK
			-DOPTIX_INCLUDE_DIR=/opt/optix/include
			-DWITH_CYCLES_DEVICE_OPTIX=ON
		)
	fi

	mycmakeargs+=(
		-DCMAKE_INSTALL_PREFIX=/usr
		-DPYTHON_VERSION="${EPYTHON/python/}"
		-DPYTHON_INCLUDE_DIR="$(python_get_includedir)"
		-DPYTHON_LIBRARY="$(python_get_library_path)"
		-DWITH_BOOST_ICU=$(usex icu)
		-DWITH_CPU_SIMD=$(usex simd)
		-DWITH_PYTHON_INSTALL=$(usex !portable OFF ON)			# Copy system python
		-DWITH_PYTHON_INSTALL_NUMPY=$(usex !portable OFF ON)
		-DWITH_PYTHON_MODULE=$(usex !X)							# runs without a user interface
		-DWITH_HEADLESS=$(usex headless)						# server mode only
		-DWITH_ALEMBIC=$(usex alembic)							# export format support
		-DWITH_ASSERT_ABORT=$(usex debug)
		-DWITH_BOOST=ON
		-DWITH_BULLET=$(usex bullet)							# Physics Engine
		-DWITH_SYSTEM_BULLET=OFF								# currently unsupported
		-DWITH_CODEC_AVI=$(usex avi)
		-DWITH_CODEC_FFMPEG=$(usex ffmpeg)
		-DWITH_CODEC_SNDFILE=$(usex sndfile)
		-DWITH_FFTW3=$(usex fftw)
		-DWITH_CYCLES=$(usex cycles)							# Enable Cycles Render Engine
		-DWITH_CYCLES_DEVICE_CUDA=$(usex cuda)
		-DWITH_CYCLES_CUDA_BUILD_SERIAL=$(usex cuda)			# Build cuda kernels in serial mode (if parallel build takes too much RAM or crash)
		-DWITH_CYCLES_EMBREE=$(usex embree)
		-DWITH_CYCLES_NATIVE_ONLY=$(usex cycles)				# for native kernel only
		-DWITH_CYCLES_OSL=$(usex osl)
		-DWITH_CYCLES_STANDALONE=OFF
		-DWITH_CYCLES_STANDALONE_GUI=OFF
		-DWITH_CYCLES_LOGGING=$(usex gtests)
		-DWITH_DOC_MANPAGE=$(usex man)
		-DWITH_FREESTYLE=$(usex freestyle)						# advanced edges rendering
		-WITH_GHOST_X11=$(usex X)
		-DWITH_GHOST_XDND=$(usex X)								# drag-n-drop support on X11
		-DWITH_GHOST_WAYLAND=$(usex wayland)
		-DWITH_IMAGE_CINEON=$(usex dpx)
		-DWITH_HARU=$(usex pdf)
		-DWITH_IMAGE_DDS=$(usex dds)
		-DWITH_IMAGE_HDR=$(usex hdr)
		-DWITH_IMAGE_WEBP=$(usex webp)
		-DWITH_IMAGE_OPENEXR=$(usex openexr)
		-DWITH_IMAGE_OPENJPEG=$(usex jpeg2k)
		-DWITH_IMAGE_TIFF=$(usex tiff)
		-DWITH_INPUT_NDOF=$(usex ndof)
		-DWITH_INSTALL_PORTABLE=$(usex portable)
		-DWITH_INTERNATIONAL=$(usex nls)						# I18N fonts and text
		-DWITH_JACK=$(usex jack)
		-DWITH_JACK_DYNLOAD=$(usex jack)
		-DWITH_PULSEAUDIO=$(usex pulseaudio)
		-DWITH_PULSEAUDIO_DYNLOAD=$(usex pulseaudio)
		-DWITH_LZMA=$(usex lzma)								# used for pointcache only
		-DWITH_LZO=$(usex lzo)									# used for pointcache only
		-DWITH_DRACO=$(usex gltf-draco)							# gltf mesh compression
		-DWITH_LLVM=$(usex llvm)
		-DWITH_LIBMV=$(usex libmv)                              # Enable libmv sfm camera tracking
		-DWITH_MEM_JEMALLOC=$(usex jemalloc)					# Enable malloc replacement
		-DWITH_MEM_VALGRIND=$(usex valgrind)
		-DWITH_MOD_FLUID=$(usex fluid)							# Mantaflow Fluid Simulation Framework
		-DWITH_MOD_REMESH=$(usex remesh)						# Remesh Modifier
		-DWITH_MOD_OCEANSIM=$(usex oceansim)					# Ocean Modifier
		-DWITH_OPENAL=$(usex openal)
		-DWITH_OPENCOLLADA=$(usex collada)						# export format support
		-DWITH_OPENCOLORIO=$(usex opencolorio)
		-DWITH_OPENGL=$(usex opengl)
		-DWITH_OPENIMAGEDENOISE=$(usex oidn)					# compositing node
		-DWITH_OPENIMAGEIO=$(usex openimageio)
		-DWITH_OPENMP=$(usex openmp)
		-DWITH_OPENSUBDIV=$(usex opensubdiv)					# for surface subdivision
		-DWITH_OPENVDB=$(usex openvdb)							# advanced remesh and smoke
		-DWITH_OPENVDB_BLOSC=$(usex openvdb)					# compression for OpenVDB
		-DWITH_NANOVDB=$(usex nanovdb)							# OpenVDB for rendering on the GPU
		-DWITH_QUADRIFLOW=$(usex quadriflow)					# remesher
		-DWITH_SDL=$(usex sdl)									# for sound and joystick support
		-DWITH_SDL_DYNLOAD=$(usex sdl)
		-DWITH_STATIC_LIBS=$(usex portable)
		-DWITH_SYSTEM_EIGEN3=$(usex !portable)
		-DWITH_SYSTEM_GLES=$(usex !portable)
		-DWITH_SYSTEM_GLEW=$(usex !portable)
		-DWITH_SYSTEM_LZO=$(usex !portable)
		#-DWITH_SYSTEM_LZMA=$(usex !portable)
		-DWITH_SYSTEM_GFLAGS=$(usex !portable)
		-DWITH_SYSTEM_GLOG=$(usex !portable)
		#-DWITH_SYSTEM_CERES=$(usex !portable)
		-DWITH_GTESTS=$(usex gtests)
		-DWITH_GHOST_DEBUG=$(usex debug)
		-DWITH_CXX_GUARDEDALLOC=$(usex debug)
		-DWITH_CXX11_ABI=ON
		-DWITH_TBB=$(usex tbb)
		-DWITH_USD=$(usex usd)									# export format support
		-DWITH_XR_OPENXR=OFF
		#-DUSD_ROOT_DIR=/opt/openusd
		#-DUSD_LIBRARY=/opt/openusd/lib/libusd_ms.so
		-DWITH_NINJA_POOL_JOBS=OFF								# for machines with 16GB of RAM or less
		-DBUILD_SHARED_LIBS=OFF
		-DWITH_CLANG=$(usex clang)
		#-DCLANG_ROOT_DIR="/usr/lib/llvm/${LLVM_SLOT}"
		-DCLANG_INCLUDE_DIR="/usr/lib/llvm/${LLVM_SLOT}/include/clang"
		#-Wno-dev
		#-DCMAKE_FIND_DEBUG_MODE=ON
	)

	append-flags $(usex debug '-DDEBUG' '-DNDEBUG')

	if tc-is-gcc ; then
		# These options only exist when GCC is detected.
		mycmakeargs+=(
			-DWITH_LINKER_LLD=$(usex lld)
			-DWITH_LINKER_GOLD=$(usex gold)
		)
	fi

	cmake_src_configure
}

src_test() {
	# A lot of tests needs to have access to the installed data files.
	# So install them into the image directory now.
	cmake_src_install

	blender_get_version
	# Define custom blender data/script file paths not be able to find them otherwise during testing.
	# (Because the data is in the image directory and it will default to look in /usr/share)
	export BLENDER_SYSTEM_SCRIPTS=${ED}/usr/share/blender/${BV}/scripts
	export BLENDER_SYSTEM_DATAFILES=${ED}/usr/share/blender/${BV}/datafiles

	cmake_src_test

	# Clean up the image directory for src_install
	rm -fr ${ED}/* || die
}

src_install() {
	python_setup

	blender_get_version

	# Pax mark blender for hardened support.
	pax-mark m "${BUILD_DIR}"/bin/blender

	cmake_src_install

	if use man; then
		# Slot the man page
		mv "${ED}/usr/share/man/man1/blender.1" "${ED}/usr/share/man/man1/blender-${BV}.1" || die
	fi

	if use doc; then
		# Define custom blender data/script file paths. Otherwise Blender will not be able to find them during doc building.
		# (Because the data is in the image directory and it will default to look in /usr/share)
		export BLENDER_SYSTEM_SCRIPTS=${ED}/usr/share/blender/${BV}/scripts
		export BLENDER_SYSTEM_DATAFILES=${ED}/usr/share/blender/${BV}/datafiles

		# Workaround for binary drivers.
		addpredict /dev/ati
		addpredict /dev/dri
		addpredict /dev/nvidiactl

		einfo "Generating Blender C/C++ API docs ..."
		cd "${CMAKE_USE_DIR}"/doc/doxygen || die
		doxygen -u Doxyfile || die
		doxygen || die "doxygen failed to build API docs."

		cd "${CMAKE_USE_DIR}" || die
		einfo "Generating (BPY) Blender Python API docs ..."
		"${BUILD_DIR}"/bin/blender --background --python doc/python_api/sphinx_doc_gen.py -noaudio || die "sphinx failed."

		cd "${CMAKE_USE_DIR}"/doc/python_api || die
		sphinx-build sphinx-in BPY_API || die "sphinx failed."

		docinto "html/API/python"
		dodoc -r "${CMAKE_USE_DIR}"/doc/python_api/BPY_API/.

		docinto "html/API/blender"
		dodoc -r "${CMAKE_USE_DIR}"/doc/doxygen/html/.
	fi

	# Fix doc installdir
	docinto html
	dodoc "${CMAKE_USE_DIR}"/release/text/readme.html
	rm -r "${ED%/}"/usr/share/doc/blender || die

	#python_fix_shebang "${ED%/}/usr/bin/blender-${MY_PV}-thumbnailer.py"
	python_optimize "${ED%/}/usr/share/blender/${MY_PV}/scripts"

	mv "${ED}/usr/bin/blender-thumbnailer" "${ED}/usr/bin/blender-${MY_PV}-thumbnailer" || die
	ln -s "${ED}/usr/bin/blender-${MY_PV}-thumbnailer" "${ED}/usr/bin/blender-thumbnailer"
	mv "${ED}/usr/bin/blender" "${ED}/usr/bin/blender-${MY_PV}" || die
	ln -s "${ED}/usr/bin/blender-${MY_PV}" "${ED}/usr/bin/blender"

	elog "${PN^}-$( grep -Po 'CPACK_PACKAGE_VERSION "\K[^"]..' ${BUILD_DIR}/CPackConfig.cmake ) has been installed."
}

pkg_postinst() {
	elog
	elog "Blender compiles from master thunk by default"
	elog
	elog "There is some my prefer blender settings as patches"
	elog "find them in cg/local-patches/blender/"
	elog "To apply someone copy them in "
	elog "/etc/portage/patches/media-gfx/blender/"
	elog "or create simlink"
	elog
	elog "It is recommended to change your blender temp directory"
	elog "from /tmp to /home/user/tmp or another tmp file under your"
	elog "home directory. This can be done by starting blender, then"
	elog "changing the 'Temporary Files' directory in Blender preferences."
	elog

	if ! use python_single_target_python3_10; then
		elog "You are building Blender with a newer python version than"
		elog "supported by this version upstream."
		elog "If you experience breakages with e.g. plugins, please switch to"
		elog "python_single_target_python3_10 instead."
		elog "Bug: https://bugs.gentoo.org/737388"
		elog
	fi

	xdg_icon_cache_update
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
	xdg_desktop_database_update

	ewarn ""
	ewarn "You may want to remove the following directory."
	ewarn "~/.config/${PN}/${SLOT}/cache/"
	ewarn "It may contain extra render kernels not tracked by portage"
	ewarn ""
}
