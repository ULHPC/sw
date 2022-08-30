## Debugging notes

The most classical issue (especially after testing builds within the `sw` project) is related to **Permission Denied**
If that happens, ask to ULHPC ops team to run

```
~resif/git/github.com/ULHPC/sw/scripts/post-install.sh -v <version> {test | prod}  -g [-x ]
```

Otherwise, in alphabetical order of the software...

#### Dakota

Sanity checks require 8 MPI processes...
Launch the build with `sbatch --ntasks-per-node 8 -c 1 ./scripts/[...] -v <version> math`


#### GROMACS

Sanity checks require 4 MPI processes...
Launch the build with `sbatch --ntasks-per-node 4 -c 7 ./scripts/[...] -v <version> bio`


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


#### Singularity

See also the easyconfig under `easyconfigs/s/Singularity/`:

```bash
INSTALLATION_PATH=your_installation_path   # see EBROOTSINGULARITY, don't miss GPU builds
chown root:root $INSTALLATION_PATH/Singularity/*/etc/singularity/singularity.conf
chown root:root $INSTALLATION_PATH/Singularity/*/etc/singularity/capability.json
chown root:root $INSTALLATION_PATH/Singularity/*/etc/singularity/ecl.toml
chown root:root $INSTALLATION_PATH/Singularity/*/libexec/singularity/bin/*-suid
chmod 4755 $INSTALLATION_PATH/Singularity/*/libexec/singularity/bin/*-suid
chmod +s $INSTALLATION_PATH/Singularity/*/libexec/singularity/bin/*-suid
```
