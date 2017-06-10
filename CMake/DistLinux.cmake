install( TARGETS Phoenix RUNTIME DESTINATION . )
install( DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/QML DESTINATION . )
install( DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/Metadata DESTINATION . )

if( PORTABLE_MODE )
        install( FILES ${CMAKE_CURRENT_BINARY_DIR}/PHOENIX-PORTABLE DESTINATION . )
endif()
