###############################################################################
### hooks/ulhpc.py
### Author: UL HPC Team <hpc-team@uni.lu>
###
### Copyright (c) 2020-2021 UL HPC Team <hpc-team@uni.lu>
### .
###          Easybuild Hooks for UL HPC Facility Software deployment
###
###############################################################################
# - Hook documentation: https://easybuild.readthedocs.io/en/latest/Hooks.html
# - Sample hook from HPC2N hooks
#    https://github.com/easybuilders/easybuild-framework/blob/develop/contrib/hooks/hpc2n_hooks.p
###################

import os
import yaml

import pprint

from distutils.version import LooseVersion
from easybuild.framework.easyconfig.format.format import DEPENDENCY_PARAMETERS
from easybuild.tools.filetools import apply_regex_substitutions
from easybuild.tools.build_log import EasyBuildError
from easybuild.tools.modules import get_software_root
from easybuild.tools.systemtools import get_shared_lib_ext

# eb --avail-hooks
# List of supported hooks (in order of execution):
#         start_hook
#         parse_hook
#         pre_fetch_hook
#         post_fetch_hook
#         pre_ready_hook
#         post_ready_hook
#         pre_source_hook
#         post_source_hook
#         pre_patch_hook
#         post_patch_hook
#         pre_prepare_hook
#         post_prepare_hook
#         pre_configure_hook
#         post_configure_hook
#         pre_build_hook
#         post_build_hook
#         pre_test_hook
#         post_test_hook
#         pre_install_hook
#         post_install_hook
#         pre_extensions_hook
#         post_extensions_hook
#         pre_postproc_hook
#         post_postproc_hook
#         pre_sanitycheck_hook
#         post_sanitycheck_hook
#         pre_cleanup_hook
#         post_cleanup_hook
#         pre_module_hook
#         post_module_hook
#         pre_permissions_hook
#         post_permissions_hook
#         pre_package_hook
#         post_package_hook
#         pre_testcases_hook
#         post_testcases_hook
#         end_hook

def parse_hook(ec, *args, **kwargs):
    # Installation key and license section - Use a special YAML file to provide the entries
    # Example can be found in config/custom/licenses_keys.yml.sample
    if os.getenv('LICENSES_YAML_FILE') is not None:
         with open(os.getenv('LICENSES_YAML_FILE')) as f:
                 data = yaml.load(f, Loader=yaml.FullLoader)
                 software = data.get(ec.name,None)
                 if software is not None :
                     print("Installing extras for {0}".format(ec.name))
                     for parameter in software:
                         if isinstance(software[parameter],dict) and software[parameter].get('version',None) is not None:
                             # We have multiple version and this parameter differs
                             ec[parameter]=software[parameter]["version"][ec.version]
                         else:
                             ec[parameter]=software[parameter]

    # Fix individual eb
    if ec.name == 'impi':
        # Slurm Process Management Interface (PMI) library path, as installed by slurm-libpmi RPM package
        slurm_libpmi_path = '/usr/lib64/libpmi.so'
        # ec.log.info("[parse hook] export I_MPI_PMI_LIBRARY=%s for impi module" % slurm_libpmi_path)
        # os.environ['I_MPI_PMI_LIBRARY'] = slurm_libpmi_path
        ec.log.info("[parse hook] Set I_MPI_PMI_LIBRARY to '%s' for impi module as modextravars" % slurm_libpmi_path)
        ec['modextravars'].update({'I_MPI_PMI_LIBRARY': slurm_libpmi_path})
        #ec.log.info(ec.asdict())
        ec['skipsteps'].append('sanitycheck')
    elif ec.name.lower() == 'cgal':
        # Issue on skylake only (fix is optarch = False)
        if os.getenv('SYS_ARCH') == 'skylake':
            ec['toolchainopts'].update({'optarch': False})
    elif ec.name.lower() == 'gromacs':
        if os.getenv('RESIF_ARCH') == 'gpu':
            ec['runtest'] = False
    elif ec.name.lower() == 'pytorch':
        if os.getenv('RESIF_ARCH') != 'gpu':
            ec['runtest'] = False
