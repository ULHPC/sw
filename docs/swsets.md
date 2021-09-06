# Software Sets

Software sets holds a categorised list of software.
In RESIF2, this notion was tied to a YAML file listing the EB files that should be built from a given environment (see for instance `swsets/default.yaml` under (deprecated) `ULHPC/resifconfig` repository)

To get rid of these YAML files while relying exclusively on Easybuild, this repository maintain a set of easyconfigs defining Module bundles (i.e. using the [`Bundle`](https://easybuild.readthedocs.io/en/latest/version-specific/generic_easyblocks.html#bundle) easyblock, or the [`Toolchain`](https://easybuild.readthedocs.io/en/latest/version-specific/generic_easyblocks.html#toolchain) one (derived from the Bundle one) for the ULHPC environment.
This defines a bundle of modules, which only generate module files, nothing to build/install.

It also facilitates the _reproducible_ and _self-contained_ deployment of the complete software stack, coupled with a strong versioning policy between environments and (typically) yearly release cycles based on EasyBuild toolchain releases.

## ULHPC Toolchains, programming languages and compilers

**[Technical Documentation](https://hpc-docs.uni.lu/environment/modules/#ulhpc-toolchains-and-software-set-versioning)**

| __Name__  | __Type__  | 2019(a) (_deprecated_) |  __2019b__ (`old`) |  __2020a__ (`prod`) | __2020b__ | __2021a*__ (`devel`) |
|-----------|-----------|------------------------|--------------------|---------------------|-----------|----------------------|
| `GCCCore` | compiler  |                  8.2.0 |              8.3.0 |               9.3.0 |    10.2.0 |               10.3.0 |
| `foss`    | toolchain |                  2019a |              2019b |               2020a |     2020b |                2021a |
| `intel`   | toolchain |                  2019a |              2019b |               2020a |     2020b |                2021a |
| binutils  |           |                 2.31.1 |               2.32 |                2.34 |      2.35 |                 2.36 |
| Python    |           |     3.7.2 (and 2.7.15) | 3.7.4 (and 2.7.16) | 3.8.2  (and 2.7.18) |     3.8.6 |                3.9.2 |
| LLVM      | compiler  |                  8.0.0 |              9.0.1 |              10.0.1 |    11.0.0 |               11.1.0 |
| OpenMPI   | MPI       |                  3.1.4 |              3.1.4 |               4.0.3 |     4.0.5 |                4.1.1 |

_*: projections at the time of writing _

ULHPC software set are aligned with the common toolchains releases of EasyBuild (see Component versions in the  [foss](https://easybuild.readthedocs.io/en/master/Common-toolchains.html#component-versions-in-foss-toolchain) and the [intel](https://easybuild.readthedocs.io/en/master/Common-toolchains.html#component-versions-in-intel-toolchain) toolchains )

These versions define completely the environment set for ULHPC software set, structured as bundles as explained below.

When developing a new bundle, copy the previous version and adapt the versions of the software listed.
You can quickly check for a given swset version (Ex: `2020b`) the _probable_ good versions for the software listed in a bundle (Ex: `ULHPC-toolchains-2020b.eb` blindly copied) as follows:

```bash
$ ./scripts/suggest-easyconfigs -v 2020b -s $(cat easyconfigs/u/ULHPC-toolchains/ULHPC-toolchains-2020b.eb| egrep "\s+\('" | cut -d "'" -f 2 | uniq | xargs echo)
           GCCcore: GCCcore-10.2.0.eb
              foss: foss-2020b.eb
             intel: intel-2020b.eb
              LLVM: LLVM-11.0.0-GCCcore-10.2.0.eb
             Clang: Clang-11.0.1-gcccuda-2020b.eb
              NASM: NASM-2.15.05-GCCcore-10.2.0.eb
             CMake: CMake-3.18.4-GCCcore-10.2.0.eb
           Doxygen: Doxygen-1.8.20-GCCcore-10.2.0.eb
           ReFrame: ReFrame-3.6.3.eb
             Spack: Spack-0.12.1.eb
           OpenMPI: OpenMPI-4.1.0-GCC-10.2.0.eb
                Go: Go-1.16.6.eb
              Java: Java-16.0.1.eb
             Julia: Julia-1.6.2-linux-x86_64.eb
              Perl: Perl-5.32.0-GCCcore-10.2.0-minimal.eb
            Python: Python-3.8.6-GCCcore-10.2.0.eb
              Ruby: Ruby-2.7.2-GCCcore-10.2.0.eb
              Rust: Rust-1.52.1-GCCcore-10.3.0.eb
                 R: R-keras-2.4.0-foss-2020b-R-4.0.4.eb
             Boost: Boost.Python-1.74.0-GCC-10.2.0.eb
              SWIG: SWIG-4.0.2-GCCcore-10.2.0.eb
               ant: ant-1.10.9-Java-11.eb
               tbb: tbb-2020.3-GCCcore-10.2.0.eb
        sparsehash: sparsehash-2.0.4-GCCcore-10.2.0.eb
             Spark: Spark-3.1.1-fosscuda-2020b.eb
         Anaconda3: Anaconda3-2021.05.eb
               GDB: GDB-10.1-GCCcore-10.2.0.eb
          Valgrind: Valgrind-3.16.1-gompi-2020b.eb
```
It's far from being perfect but it can help to provide a good **draft** version of the bundle you can work on.


## ULHPC Bundles

The dependencies for User Software Set are organized as follows:

![](images/resif_bundles.png)

In details, under `easyconfigs/u`, you will find the following directory/file structure:

```bash
easyconfigs/u
  ├── ULHPC                 #### === Default global bundle for 'regular' nodes ===
  │   └── ULHPC-<version>
  |
  ├── ULHPC-toolchains      ### Toolchains, compilers, debuggers, programming languages...
  │   └── ULHPC-toolchains-<version>.eb #  - toolchain: EasyBuild toolchains
  │                                     #  - compiler:  Compilers
  │                                     #  - debugger:  Debuggers
  │                                     #  - devel:     Development tools
  │                                     #  - lang:      Languages and programming aids
  │                                     #  - mpi:       MPI stacks
  │                                     #  - lib:       General purpose libraries (incl. Communication Libraries, I/O Libraries...)
  │                                     #  - numlib:    Numerical Libraries
  │                                     #  - system:    System utilities (e.g. highly depending on system OS and hardware)
  ├── ULHPC-bd               ### Big Data Analytics
  │   └── ULHPC-bd-<version>.eb
  ├── ULHPC-bio              ### Bioinformatics, biology and biomedical
  │   └── ULHPC-bio-<version>.eb
  ├── ULHPC-cs               ### Computational science, including:
  │   └── ULHPC-cs-<version>.eb         #   - cae:       Computer Aided Engineering (incl. CFD)
  │                                     #   - chem:      Chemistry, Computational Chemistry and Quantum Chemistry
  │                                     #   - data:      Data management & processing tools
  │                                     #   - geo:       Earth Sciences
  │                                     #   - quantum:   Quantum Computing
  │                                     #   - phys: Physics and physical systems simulations
  ├── ULHPC-dl               ### AI / Deep Learning / Machine Learning
  │   └── ULHPC-dl-<version>.eb
  ├── ULHPC-math             ### High-level mathematical software
  │   └── ULHPC-math-<version>.eb
  ├── ULHPC-perf             ### Performance evaluation / Benchmarks
  │   └── ULHPC-perf-<version>.eb
  ├── ULHPC-tools            ### Misc general purpose tools
  │   └── ULHPC-tools-<version>.eb      # - perf:      Performance tools
  ├── ULHPC-visu             ### Visualization, plotting, documentation and typesetting
  │   └── ULHPC-visu-<version>.eb
  │
  └── ULHPC-gpu    #### === Specific GPU versions ===
      └── ULHPC-gpu-<version>.eb
```

They actually inherits  and aggregate from the default [module classes](https://easybuild.readthedocs.io/en/latest/Writing_easyconfig_files.html#module-class):

```bash
eb --show-default-moduleclasses
Default available module classes:

        base:      Default module class
        astro:     Astronomy, Astrophysics and Cosmology
        bio:       Bioinformatics, biology and biomedical
        cae:       Computer Aided Engineering (incl. CFD)
        chem:      Chemistry, Computational Chemistry and Quantum Chemistry
        compiler:  Compilers
        data:      Data management & processing tools
        debugger:  Debuggers
        devel:     Development tools
        geo:       Earth Sciences
        ide:       Integrated Development Environments (e.g. editors)
        lang:      Languages and programming aids
        lib:       General purpose libraries
        math:      High-level mathematical software
        mpi:       MPI stacks
        numlib:    Numerical Libraries
        perf:      Performance tools
        quantum:   Quantum Computing
        phys:      Physics and physical systems simulations
        system:    System utilities (e.g. highly depending on system OS and hardware)
        toolchain: EasyBuild toolchains
        tools:     General purpose tools
        vis:       Visualization, plotting, documentation and typesetting
```
