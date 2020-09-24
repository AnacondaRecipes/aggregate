set LMDB_INCLUDE=%PREFIX%\Library\include
set LMDB_LIBPATH=%PREFIX%\Library\lib

nmake /f NTMakefile ^
        VERBOSE=1  ^
        DB_LIB=libdb61.lib ^
        STATIC=no  ^
        NTLM=1 ^
        GSSAPI=MIT ^
        SQL=SQLITE3 ^
        SRP=1 ^
        OTP=1 ^
        install
