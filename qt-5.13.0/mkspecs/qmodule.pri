QT_CPU_FEATURES.i386 = sse sse2
QT.global_private.enabled_features = sse2 alloca_malloc_h alloca avx2 dbus gui network release_tools sql testlib widgets xml
QT.global_private.disabled_features = alloca_h android-style-assets private_tests dbus-linked gc_binaries libudev posix_fallocate reduce_exports reduce_relocations stack-protector-strong system-zlib zstd
QT_COORD_TYPE = double
CONFIG += sse2 aesni sse3 ssse3 sse4_1 sse4_2 avx avx2 avx512f avx512bw avx512cd avx512dq avx512er avx512ifma avx512pf avx512vbmi avx512vl compile_examples f16c largefile msvc_mp precompile_header rdrnd shani x86SimdAlways
QT_BUILD_PARTS += libs tools
QT_HOST_CFLAGS_DBUS += 
