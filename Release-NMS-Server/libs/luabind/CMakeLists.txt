CMAKE_MINIMUM_REQUIRED(VERSION 3.12)

SET(lb_sources
    src/class.cpp
	src/class_info.cpp
	src/class_registry.cpp
	src/class_rep.cpp
	src/create_class.cpp
	src/error.cpp
	src/exception_handler.cpp
	src/function.cpp
	src/inheritance.cpp
	src/link_compatibility.cpp
	src/object_rep.cpp
	src/open.cpp
	src/pcall.cpp
	src/scope.cpp
	src/stack_content_by_name.cpp
	src/weak_ref.cpp
	src/wrapper_base.cpp
)

SET(lb_headers

)

ADD_LIBRARY(luabind ${lb_sources} ${lb_headers})

# luabind CALLS lua (lua_pushstring, lua_gettop, ...) but never declared it, so CMake
# had no idea the two were related. Consumers only ever listed both side by side in a
# variable, and a fixed order cannot work here: luabind is a static archive that gets
# read more than once during a link, and an archive only hands over the object files
# needed at the moment it is read. object_rep.cpp.o was pulled in by a later mention of
# luabind - after liblua had already been processed and (under GCC's default
# --as-needed on Debian/Ubuntu) discarded - leaving ~200 undefined lua_* references
# when linking zone. Clang does not default to --as-needed, which is the only reason
# it linked at all.
#
# Declaring the dependency PUBLIC lets CMake place lua after luabind for every consumer
# and repeat it when required, which is correct on GNU ld, MSVC and clang alike.
IF(LUA_IMPL_LIBRARY)
    TARGET_LINK_LIBRARIES(luabind PUBLIC ${LUA_IMPL_LIBRARY})
ENDIF()


IF(UNIX)
    set_source_files_properties(${lb_sources} PROPERTY COMPILE_FLAGS -Wno-deprecated-declarations)
ENDIF(UNIX)

IF(MSVC)
	set_source_files_properties(${lb_sources} PROPERTY COMPILE_FLAGS " /W0 " )
ENDIF(MSVC)

SET(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)
