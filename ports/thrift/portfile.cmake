include(vcpkg_common_functions)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported. Building static.") # See note below
    set(VCPKG_LIBRARY_LINKAGE static)

    # As per Ben Craig thrift comment see https://issues.apache.org/jira/browse/THRIFT-1834
    # Currently, Thrift is designed to be packaged as a static library. As a static library, the consuming program / dll will only pull in the object files that it needs, so the per-binary size increase should be pretty small.
    # Thrift isn't a very good candidate to become a dynamic library. No attempts are made to preserve binary compatibility, or to provide a C / COM-like interface to make binary compatibility easy.
endif()

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/thrift
    REF 129f332d72facda5d06f87e2b4e5e08bea0b6b44
    SHA512 116737e549cbecdfadcfa1416b84a53efcc31c1aefabfcc6f46a00762c675bf17288da3164a9e1253a5c71430f9bd74efa6141a67d459984524df60fd27551da
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWITH_SHARED_LIB=OFF
        -DWITH_STATIC_LIB=ON
        -DWITH_STDTHREADS=ON
        -DBUILD_TESTING=off
        -DBUILD_JAVA=off
        -DBUILD_C_GLIB=off
        -DBUILD_PYTHON=off
        -DBUILD_CPP=on
        -DBUILD_HASKELL=off
        -DBUILD_TUTORIALS=off
        -DFLEX_EXECUTABLE=${FLEX}
        -DBISON_EXECUTABLE=${BISON}
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/thrift RENAME copyright)

file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*.exe")
if(EXES)
    file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/thrift)
    file(REMOVE ${EXES})
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/thrift)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
vcpkg_copy_pdbs()
