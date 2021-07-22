## Debugging notes

#### Buid error Python/{3.7.4,2.7.16}/GCCcore-8.3.0.: generate-posix-vars failed

See [Issue #10308](https://github.com/easybuilders/easybuild-easyconfigs/issues/10308)

```
if test $? -ne 0 ; then \
        echo "generate-posix-vars failed" ; \
        rm -f ./pybuilddir.txt ; \
        exit 1 ; \
fi
/bin/sh: :/usr/local/lib: No such file or directory
```

`LD_LIBRARY_PATH` was wrongly initiated in `.bashrc`, solved as follows:

```diff
-PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig
-LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
+PKG_CONFIG_PATH=${PKG_CONFIG_PATH:=/usr/local/lib/pkgconfig}:/usr/local/lib/pkgconfig
+LD_LIBRARY_PATH=${LD_LIBRARY_PATH:=/usr/local/lib}:/usr/local/lib
```
