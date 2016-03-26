cmake_minimum_required(VERSION 2.7.4 FATAL_ERROR)

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/third_party/vic_cmake")

# 设置作者信息
set(AUTHOR_NAME "Vic")
set(AUTHOR_CONTACT "Vic <vic@libgod.com>")
set(AUTHOR_HOMEPAGE "http://blog.libgod.com")

# 默认编译DEBUG版本
if(NOT CMAKE_BUILD_TYPE)
    message(STATUS "default CMAKE_BUILD_TYPE=Debug")
    set(CMAKE_BUILD_TYPE Debug) #Debug, Release, RelWithDebInfo, MinSizeRel.
endif()

# 默认编译静态库
if((NOT BUILD_SHARED_LIBRARY) AND (NOT BUILD_STATIC_LIBRARY))
    message(STATUS "default BUILD_STATIC_LIBRARY=TRUE")
    set(BUILD_STATIC_LIBRARY TRUE)
endif()

# 自增全局版本号
include(VicIncrementVersion)
vic_increment_version(GLOBAL)
message(STATUS "GLOBAL version: ${GLOBAL_VERSION}")

# 获取源码版本号
include(VicGetSourceVersion)
vic_get_source_short_version(CODE_REVISION)
message(STATUS "CODE_REVISION: ${CODE_REVISION}")

# 设置项目
project(vic-context LANGUAGES C ASM)
include(VicCopyVersion)
vic_copy_version(${PROJECT_NAME} GLOBAL)
message(STATUS "${PROJECT_NAME} version: ${${PROJECT_NAME}_VERSION}")
message(STATUS "${PROJECT_NAME} binary dir: ${${PROJECT_NAME}_BINARY_DIR}")
message(STATUS "${PROJECT_NAME} source dir: ${${PROJECT_NAME}_SOURCE_DIR}")
message(STATUS "Project binary dir: ${PROJECT_BINARY_DIR}")
message(STATUS "Project source dir: ${PROJECT_SOURCE_DIR}")

# 设置生成输出路径
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/lib")
set(CMAKE_MODULE_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/mod")
set(CMAKE_PACKAGE_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/${PACKAGE_DIR_NAME}")

# 设置C编译参数
#set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=gnu99 -Wall -Werror -fno-strict-aliasing")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Werror -fno-strict-aliasing")
#if(CMAKE_C_COMPILER STREQUAL clang)
#    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-error=unused-const-variable")
#endif()
#set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -O0 -D_DEBUG")
#set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}")

# 输出信息
message(STATUS "CMAKE_CACHE_VERSION: ${CMAKE_CACHE_MAJOR_VERSION}.${CMAKE_CACHE_MINOR_VERSION}.${CMAKE_CACHE_PATCH_VERSION}")
message(STATUS "Cmake build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Compiler: ${CMAKE_C_COMPILER}")
message(STATUS "Compile flag: ${CMAKE_C_FLAGS}")
message(STATUS "Debug mode flag: ${CMAKE_C_FLAGS_DEBUG}")
message(STATUS "RelWithDebInfo mode flag: ${CMAKE_C_FLAGS_RELWITHDEBINFO}")
message(STATUS "Release mode flag: ${CMAKE_C_FLAGS_RELEASE}")
message(STATUS "MinSizeRel mode flag: ${CMAKE_C_FLAGS_MINSIZEREL}")
message(STATUS "CMake root dir: ${CMAKE_ROOT}")
message(STATUS "Cmake binary dir: ${CMAKE_BINARY_DIR}")
message(STATUS "Cmake source dir: ${CMAKE_SOURCE_DIR}")
message(STATUS "Cmake current binary dir: ${CMAKE_CURRENT_BINARY_DIR}")
message(STATUS "Cmake current source dir: ${CMAKE_CURRENT_SOURCE_DIR}")
message(STATUS "CMake module dir: ${CMAKE_MODULE_PATH}")
message(STATUS "Runtime output dir: ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
message(STATUS "Library output dir: ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
message(STATUS "Archive output dir: ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}")
message(STATUS "Module output dir: ${CMAKE_MODULE_OUTPUT_DIRECTORY}")
message(STATUS "Package output dir: ${CMAKE_PACKAGE_OUTPUT_DIRECTORY}")

include(VicAbi)
vic_get_abi(VIC_ABI)
message(STATUS "VIC_ABI: ${VIC_ABI}")
include(VicAddressModel)
vic_get_address_model(VIC_ADDRESS_MODEL)
message(STATUS "VIC_ADDRESS_MODEL: ${VIC_ADDRESS_MODEL}")
include(VicArchitecture)
vic_get_architecture(VIC_ARCHITECTURE)
message(STATUS "VIC_ARCHITECTURE: ${VIC_ARCHITECTURE}")
include(VicBinaryFormat)
vic_get_binary_format(VIC_BINARY_FORMAT)
message(STATUS "VIC_BINARY_FORMAT: ${VIC_BINARY_FORMAT}")

#包含头文件目录
include_directories(${PROJECT_SOURCE_DIR})

#包含库目录
link_directories(${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
link_directories(${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})
link_directories(${CMAKE_MODULE_OUTPUT_DIRECTORY})

#包含子目录
add_subdirectory(src)

if(BUILD_WITHOUT_EXAMPLE)
    message(STATUS "Build without example project.")
else()
    #add_subdirectory(example)
endif()

if(BUILD_WITHOUT_UNITTEST)
    message(STATUS "Build without unittest project.")
else()
    #add_subdirectory(unittest)
endif()

#安装文件
install(DIRECTORY "vic" DESTINATION "include" FILES_MATCHING PATTERN "*.h" PATTERN "exclude1.h" EXCLUDE PATTERN "exclude2*" EXCLUDE)
install(CODE "MESSAGE(\"Project ${PROJECT_NAME} install message.\")")

include(InstallRequiredSystemLibraries)
#set(CPACK_CMAKE_GENERATOR "Unix Makefiles")

find_program(DPKG NAMES dpkg)
if(DPKG)
    execute_process(
        COMMAND dpkg --print-architecture
        OUTPUT_VARIABLE PACKAGE_ARCHITECTURE OUTPUT_STRIP_TRAILING_WHITESPACE
    )
else()
    if(VIC_ARCHITECTURE STREQUAL i386)
        set(PACKAGE_ARCHITECTURE i386)
    elseif(VIC_ARCHITECTURE STREQUAL amd64)
        set(PACKAGE_ARCHITECTURE amd64)
    elseif(VIC_ARCHITECTURE STREQUAL armel)
        set(PACKAGE_ARCHITECTURE armel)
    elseif(VIC_ARCHITECTURE STREQUAL armhf)
        set(PACKAGE_ARCHITECTURE armhf)
    elseif(VIC_ARCHITECTURE STREQUAL arm64)
        set(PACKAGE_ARCHITECTURE arm64)
    elseif(VIC_ARCHITECTURE STREQUAL mips)
        set(PACKAGE_ARCHITECTURE mipsel)
    elseif(VIC_ARCHITECTURE STREQUAL mipsel)
        set(PACKAGE_ARCHITECTURE mipsel)
    elseif(VIC_ARCHITECTURE STREQUAL powerpc)
        set(PACKAGE_ARCHITECTURE powerpc)
    elseif(VIC_ARCHITECTURE STREQUAL ppc64el)
        set(PACKAGE_ARCHITECTURE ppc64el)
    elseif(VIC_ARCHITECTURE STREQUAL sparc)
        set(PACKAGE_ARCHITECTURE sparc)
    endif()
endif()
message(STATUS "PACKAGE_ARCHITECTURE: ${PACKAGE_ARCHITECTURE}")

set(CPACK_INSTALL_PREFIX "/usr")
set(CPACK_OUTPUT_FILE_PREFIX "${CMAKE_PACKAGE_OUTPUT_DIRECTORY}")
set(CPACK_PACKAGE_CONTACT ${AUTHOR_CONTACT})
set(CPACK_PACKAGE_DESCRIPTION "Vic coroutine library.")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_SOURCE_DIR}/README.md")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Vic coroutine library.")
set(CPACK_PACKAGE_NAME ${PROJECT_NAME})
set(CPACK_PACKAGE_VENDOR "${CPACK_PACKAGE_CONTACT}")
set(CPACK_PACKAGE_VERSION_MAJOR ${${PROJECT_NAME}_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${${PROJECT_NAME}_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${${PROJECT_NAME}_VERSION_PATCH})
set(CPACK_PACKAGE_VERSION "${${PROJECT_NAME}_VERSION}")
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CMAKE_HOST_SYSTEM_NAME}")
if(PACKAGE_ARCHITECTURE)
    set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_FILE_NAME}-${PACKAGE_ARCHITECTURE}")
endif()
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE")
set(CPACK_RESOURCE_FILE_README "${CMAKE_SOURCE_DIR}/README.md")

#set(CPACK_SOURCE_GENERATOR "TGZ;ZIP")
set(CPACK_STRIP_FILES "")

#NSIS: Null Soft Installer
#NSIS64: Null Soft Installer (64-bit)
#STGZ: Self extracting Tar GZip compression
#TBZ2: Tar BZip2 compression
#TGZ: Tar GZip compression
#TZ: Tar Compress compression
#WIX: MSI file format via WiX tools
#ZIP: ZIP file format
#DEB: deb file format
#RPM: rpm file format
#set(CPACK_GENERATOR "STGZ;ZIP") #NSIS;NSIS64;STGZ;TBZ2;TGZ;TZ;WIX;ZIP
if(CPACK_GENERATOR_STGZ)
    if(CPACK_GENERATOR)
        set(CPACK_GENERATOR "${CPACK_GENERATOR};STGZ")
    else()
        set(CPACK_GENERATOR "STGZ")
    endif()
endif()
if(CPACK_GENERATOR_TBZ2)
    if(CPACK_GENERATOR)
        set(CPACK_GENERATOR "${CPACK_GENERATOR};TBZ2")
    else()
        set(CPACK_GENERATOR "TBZ2")
    endif()
endif()
if(CPACK_GENERATOR_TGZ)
    if(CPACK_GENERATOR)
        set(CPACK_GENERATOR "${CPACK_GENERATOR};TGZ")
    else()
        set(CPACK_GENERATOR "TGZ")
    endif()
endif()
if(CPACK_GENERATOR_TZ)
    if(CPACK_GENERATOR)
        set(CPACK_GENERATOR "${CPACK_GENERATOR};TZ")
    else()
        set(CPACK_GENERATOR "TZ")
    endif()
endif()
if(CPACK_GENERATOR_ZIP)
    if(CPACK_GENERATOR)
        set(CPACK_GENERATOR "${CPACK_GENERATOR};ZIP")
    else()
        set(CPACK_GENERATOR "ZIP")
    endif()
endif()

if(DPKG AND NOT WIN32 AND CPACK_GENERATOR_DEFAULT)
    message(STATUS "Cpack generate deb package.")
    if(CPACK_GENERATOR)
        set(CPACK_GENERATOR "${CPACK_GENERATOR};DEB")
    else()
        set(CPACK_GENERATOR "DEB")
    endif()
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "${PACKAGE_ARCHITECTURE}") #Mandatory: YES
    #set(CPACK_DEBIAN_PACKAGE_BREAKS "")
    #set(CPACK_DEBIAN_PACKAGE_CONFLICTS "")
    #set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${CMAKE_CURRENT_SOURCE_DIR/prerm;${CMAKE_CURRENT_SOURCE_DIR}/postrm")
    #set(CPACK_DEBIAN_PACKAGE_DEBUG "")
    #set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6 (>= 2.13), g++ (>= 4.7)")
    #set(CPACK_DEBIAN_PACKAGE_DESCRIPTION "") #Mandatory: YES Default: CPACK_PACKAGE_DESCRIPTION_SUMMARY
    #set(CPACK_DEBIAN_PACKAGE_ENHANCES "")
    #set(CPACK_DEBIAN_PACKAGE_HOMEPAGE "${AUTHOR_HOMEPAGE}") #The URL of the web site for this package.
    #set(CPACK_DEBIAN_PACKAGE_MAINTAINER "${CPACK_PACKAGE_CONTACT}") #Mandatory: YES Default: CPACK_PACKAGE_CONTACT
    #set(CPACK_DEBIAN_PACKAGE_NAME "") #Mandatory: YES Default: CPACK_PACKAGE_NAME(lower case)
    #set(CPACK_DEBIAN_PACKAGE_PREDEPENDS "")
    set(CPACK_DEBIAN_PACKAGE_PRIORITY "optional") #optional, standard, extra. Mandatory: YES
    #set(CPACK_DEBIAN_PACKAGE_PROVIDES "") #A virtual package is one which appears in the Provides control field of another package.
    #set(CPACK_DEBIAN_PACKAGE_RECOMMENDS "recommend")
    #set(CPACK_DEBIAN_PACKAGE_REPLACES "")
    set(CPACK_DEBIAN_PACKAGE_SECTION "libdevel")
    #set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS "")
    #set(CPACK_DEBIAN_PACKAGE_SUGGESTS "suggest")
    #set(CPACK_DEBIAN_PACKAGE_VERSION "") #Mandatory: YES Default: CPACK_PACKAGE_VERSION
endif()

find_program(RPMBUILD NAMES rpmbuild)
if(RPMBUILD AND NOT WIN32 AND CPACK_GENERATOR_DEFAULT)
    message(STATUS "Cpack generate rpm package.")
    if(CPACK_GENERATOR)
        set(CPACK_GENERATOR "${CPACK_GENERATOR};RPM")
    else()
        set(CPACK_GENERATOR "RPM")
    endif()
    #set(CPACK_RPM_CHANGELOG_FILE "")
    #set(CPACK_RPM_COMPRESSION_TYPE "") #lzma, xz, bzip2 and gzip
    #set(CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST "")
    #set(CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "")
    #set(CPACK_RPM_GENERATE_USER_BINARY_SPECFILE_TEMPLATE "")
    #set(CPACK_RPM_PACKAGE_ARCHITECTURE "")
    #set(CPACK_RPM_PACKAGE_DEBUG "")
    set(CPACK_RPM_PACKAGE_DESCRIPTION "${CPACK_PACKAGE_DESCRIPTION_SUMMARY}")
    set(CPACK_RPM_PACKAGE_GROUP "unknown") #Mandatory: YES Default: unknown
    set(CPACK_RPM_PACKAGE_LICENSE "unknown") #Mandatory: YES Default: unknown
    #set(CPACK_RPM_PACKAGE_NAME "") #Mandatory: YES Default: CPACK_PACKAGE_NAME
    #set(CPACK_RPM_PACKAGE_OBSOLETES "")
    #set(CPACK_RPM_PACKAGE_PROVIDES "")
    #set(CPACK_RPM_PACKAGE_RELEASE "") #Mandatory: YES Default: 1
    #set(CPACK_RPM_PACKAGE_RELOCATABLE "") #Default: CPACK_PACKAGE_RELOCATABLE
    #set(CPACK_RPM_PACKAGE_REQUIRES "libc6 >= 2.13, g++ >= 4.7")
    #set(CPACK_RPM_PACKAGE_SUGGESTS "")
    #set(CPACK_RPM_PACKAGE_SUMMARY "") #Mandatory: YES Default: CPACK_PACKAGE_DESCRIPTION_SUMMARY
    #set(CPACK_RPM_PACKAGE_URL "${AUTHOR_HOMEPAGE}")
    #set(CPACK_RPM_PACKAGE_VENDOR "") #Mandatory: YES Default: CPACK_PACKAGE_VENDOR
    #set(CPACK_RPM_PACKAGE_VERSION "") #Mandatory: YES Default: CPACK_PACKAGE_VERSION
    #set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE "")
    #set(CPACK_RPM_PRE_INSTALL_SCRIPT_FILE "")
    #set(CPACK_RPM_SPEC_MORE_DEFINE "")
    #set(CPACK_RPM_USER_BINARY_SPECFILE "")
    #set(CPACK_RPM_USER_FILELIST "")
endif()

message(STATUS "CPACK_GENERATOR: ${CPACK_GENERATOR}")
include(CPack)

