if [[ `uname` == "MINGW64_NT-10.0" ]]; then
    cp $RECIPE_DIR/site.cfg $PREFIX/site.cfg
    echo library_dirs = $LIBRARY_LIB  >> $PREFIX/site.cfg
    echo include_dirs = $LIBRARY_INC  >> $PREFIX/site.cfg
else
    cp $RECIPE_DIR/site.cfg $PREFIX/site.cfg
    echo library_dirs = $PREFIX/lib  >> $PREFIX/site.cfg
    echo include_dirs = $PREFIX/include  >> $PREFIX/site.cfg
fi
