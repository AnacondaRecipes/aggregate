project(apr-iconv)

cmake_minimum_required(VERSION 2.8.12)

SET(APR_INCLUDE_DIR         "${CMAKE_INSTALL_PREFIX}/include"           CACHE STRING "Directory with APR include files")
SET(APR_LIBRARIES           "${CMAKE_INSTALL_PREFIX}/lib/libapr-1.lib"  CACHE STRING "APR library to link with")

SET(APRICONV_INCLUDE_DIRECTORIES
  ${CMAKE_CURRENT_SOURCE_DIR}/include
  ${CMAKE_CURRENT_SOURCE_DIR}/lib
  ${APR_INCLUDE_DIR}/include
)

SET(APRICONV_SRC
  lib/api_version.c
  lib/iconv.c
  lib/iconv_ccs.c
  lib/iconv_ces.c
  lib/iconv_ces_euc.c
  lib/iconv_ces_iso2022.c
  lib/iconv_int.c
  lib/iconv_module.c
  lib/iconv_uc.c
  )

# libapriconv-1 is shared, apriconv-1 is static
ADD_LIBRARY(libapriconv-1 SHARED ${APRICONV_SRC} libapriconv.rc)
SET(install_targets ${install_targets} libapriconv-1)
TARGET_INCLUDE_DIRECTORIES(libapriconv-1 PUBLIC ${APRICONV_INCLUDE_DIRECTORIES})
TARGET_LINK_LIBRARIES(libapriconv-1 ${APR_LIBRARIES})
SET_TARGET_PROPERTIES(libapriconv-1 PROPERTIES COMPILE_DEFINITIONS "API_DECLARE_EXPORT;WINNT")

ADD_LIBRARY(apriconv-1 STATIC ${APRICONV_SRC})
SET(install_targets ${install_targets} apriconv-1)
TARGET_INCLUDE_DIRECTORIES(apriconv-1 PUBLIC ${APRICONV_INCLUDE_DIRECTORIES})
TARGET_LINK_LIBRARIES(apriconv-1 ${APR_LIBRARIES})
SET_TARGET_PROPERTIES(apriconv-1 PROPERTIES COMPILE_DEFINITIONS "API_DECLARE_STATIC")

# Installation

INSTALL(TARGETS ${install_targets}
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
       )

INSTALL(DIRECTORY include/ DESTINATION include)

set(APRICONV_CCS_MODULES
  adobe-stdenc
  adobe-symbol
  adobe-zdingbats
  big5
  cns11643-plane1
  cns11643-plane14
  cns11643-plane2
  cp037
  cp038
  cp10000
  cp10006
  cp10007
  cp10029
  cp1006
  cp10079
  cp10081
  cp1026
  cp273
  cp274
  cp275
  cp277
  cp278
  cp280
  cp281
  cp284
  cp285
  cp290
  cp297
  cp420
  cp423
  cp424
  cp437
  cp500
  cp737
  cp775
  cp850
  cp851
  cp852
  cp855
  cp856
  cp857
  cp860
  cp861
  cp862
  cp863
  cp864
  cp865
  cp866
  cp868
  cp869
  cp870
  cp871
  cp874
  cp875
  cp880
  cp891
  cp903
  cp904
  cp905
  cp918
  cp932
  cp936
  cp949
  cp950
  dec-mcs
  ebcdic-at-de-a
  ebcdic-at-de
  ebcdic-ca-fr
  ebcdic-dk-no-a
  ebcdic-dk-no
  ebcdic-es-a
  ebcdic-es-s
  ebcdic-es
  ebcdic-fi-se-a
  ebcdic-fi-se
  ebcdic-fr
  ebcdic-it
  ebcdic-pt
  ebcdic-uk
  ebcdic-us
  gb12345
  gb_2312-80
  hp-roman8
  iso-8859-1
  iso-8859-10
  iso-8859-13
  iso-8859-14
  iso-8859-15
  iso-8859-2
  iso-8859-3
  iso-8859-4
  iso-8859-5
  iso-8859-6
  iso-8859-7
  iso-8859-8
  iso-8859-9
  iso-ir-10
  iso-ir-102
  iso-ir-103
  iso-ir-11
  iso-ir-111
  iso-ir-121
  iso-ir-122
  iso-ir-123
  iso-ir-128
  iso-ir-13
  iso-ir-139
  iso-ir-14
  iso-ir-141
  iso-ir-142
  iso-ir-143
  iso-ir-146
  iso-ir-147
  iso-ir-15
  iso-ir-150
  iso-ir-151
  iso-ir-152
  iso-ir-153
  iso-ir-154
  iso-ir-155
  iso-ir-158
  iso-ir-16
  iso-ir-17
  iso-ir-18
  iso-ir-19
  iso-ir-2
  iso-ir-21
  iso-ir-25
  iso-ir-27
  iso-ir-37
  iso-ir-4
  iso-ir-47
  iso-ir-49
  iso-ir-50
  iso-ir-51
  iso-ir-54
  iso-ir-55
  iso-ir-57
  iso-ir-60
  iso-ir-61
  iso-ir-69
  iso-ir-70
  iso-ir-8-1
  iso-ir-8-2
  iso-ir-84
  iso-ir-85
  iso-ir-86
  iso-ir-88
  iso-ir-89
  iso-ir-9-1
  iso-ir-9-2
  iso-ir-90
  iso-ir-91
  iso-ir-92
  iso-ir-93
  iso-ir-94
  iso-ir-95
  iso-ir-96
  iso-ir-98
  iso-ir-99
  iso646-dk
  iso646-kr
  jis_x0201
  jis_x0208-1983
  jis_x0212-1990
  johab
  koi8-r
  koi8-ru
  koi8-u
  ksx1001
  mac-ce
  mac-croatian
  mac-cyrillic
  mac-dingbats
  mac-greek
  mac-iceland
  mac-japan
  mac-roman
  mac-romania
  mac-thai
  mac-turkish
  mac-ukraine
  macintosh
  osd_ebcdic_df04_1
  osd_ebcdic_df04_15
  shift_jis
  us-ascii
  windows-1250
  windows-1251
  windows-1252
  windows-1253
  windows-1254
  windows-1255
  windows-1256
  windows-1257
  windows-1258
  )

foreach(module ${APRICONV_CCS_MODULES})
  add_library(${module} SHARED ccs/${module}.c)
  target_include_directories(${module} PUBLIC ${APRICONV_INCLUDE_DIRECTORIES})
  target_link_libraries(${module} libapriconv-1)
  set_target_properties(${module} PROPERTIES SUFFIX ".so")
  add_dependencies(${module} libapriconv-1)
endforeach()

set(APRICONV_CES_MODULES
  euc-jp
  euc-kr
  euc-tw
  gb2312
  iso-10646-ucs-2
  iso-10646-ucs-4
  iso-2022-cn
  iso-2022-jp-2
  iso-2022-jp
  iso-2022-kr
  ucs2-internal
  ucs4-internal
  unicode-1-1-utf-7
  utf-16
  utf-8
  _tbl_simple
  )

foreach(module ${APRICONV_CES_MODULES})
  add_library(${module} SHARED ces/${module}.c)
  target_include_directories(${module} PUBLIC ${APRICONV_INCLUDE_DIRECTORIES})
  target_link_libraries(${module} libapriconv-1)
  set_target_properties(${module} PROPERTIES SUFFIX ".so")
  add_dependencies(${module} libapriconv-1)
endforeach()

INSTALL(TARGETS ${APRICONV_CCS_MODULES} ${APRICONV_CES_MODULES}
        RUNTIME DESTINATION bin/iconv
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
       )
