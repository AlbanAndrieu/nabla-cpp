# -*- coding: utf-8 -*-
import os
import sys

import SCons

# Writes C project file to disk


def WriteEclipseProjectFile(env, cproject, tree):
    tree.write(cproject + '.new', 'UTF-8')
    env.Execute(
        "sed 's/<cproject/<?fileVersion 4.0.0?><cproject/' < " +
        cproject + '.new > ' + cproject,
    )
    env.Execute('rm ' + cproject + '.new ')

# Modifies .cproject file and adds include directories if file exits


def AddIncludes2EclipseCProject(env):
    includePaths = env['CPPPATH']
    cproject = env.Dir('#').abspath + '/.cproject'
    if os.path.exists(cproject):
        import xml.etree.ElementTree as etree
        tree = etree.parse(cproject)
        # find project options with include paths
        options = tree.getroot().findall(".//option[@valueType='includePath']")
        for config in options:
            for value in config.findall(".//listOptionValue[@kplus_generated='true']"):
                config.remove(value)

            for includePath in includePaths[1:]:
                includePath = includePath.abspath
                if '#' in includePath:
                    includePath = includePath.replace('#', env['sandbox'])
                if '.' == includePath:
                    continue
                etree.SubElement(
                    config, 'listOptionValue', {
                        'value': includePath, 'bulitIn': 'false', 'kplus_generated': 'true',
                    },
                )

    env.WriteEclipseProjectFile(cproject, tree)

# Modifies .cproject file and adds Scons targets for specified module


def AddSconsTarget2Eclipse(env, etree, targetsElement, targetName, targetArguments=None, targetDescription=None):
    if not targetDescription:
        targetDescription = targetName
#    print 'Add target:', targetName, targetArguments, targetDescription
    targetElement = etree.SubElement(
        targetsElement, 'target', {
            'description': targetDescription, 'targetID': 'ch.hsr.ifs.sconsolidator.Builder',
        },
    )
    targetNameElement = etree.SubElement(targetElement, 'buildTargetName')
    targetNameElement.text = targetName
    targetArgumentsElement = etree.SubElement(targetElement, 'buildArguments')
    if targetArguments:
        targetArgumentsElement.text = targetArguments

# Modifies .cproject file and adds Scons targets for libs and binaries


def AddTargets2EclipseProject(env, progDirs, clean=False):
    cproject = env.Dir('#').abspath + '/.cproject'
    if os.path.exists(cproject):
        import xml.etree.ElementTree as etree
        tree = etree.parse(cproject)

        sconsolidator = tree.find(
            ".//storageModule[@moduleId='ch.hsr.ifs.sconsolidator.core.buildtargets']",
        )

        if sconsolidator is None:  # is not None:
            sconsolidator = etree.SubElement(
                tree.getroot(), 'storageModule', {
                    'moduleId': 'ch.hsr.ifs.sconsolidator.core.buildtargets',
                },
            )

        targets = sconsolidator.find('buildTargets')

        if targets is None:  # is not None:
            targets = etree.SubElement(sconsolidator, 'buildTargets')

        if clean:
            for target in targets.findall('.//target'):
                targets.remove(target)

        # add default scons targets
        env.AddSconsTarget2Eclipse(
            etree, targets, 'Eclipse', 'action=includes', '#.Eclipse includes',
        )
        env.AddSconsTarget2Eclipse(
            etree, targets, 'Eclipse', 'action=targets', '#.Eclipse targets',
        )
        env.AddSconsTarget2Eclipse(
            etree, targets, 'Eclipse', 'action=clean_targets', '#.Remove Eclipse targets',
        )
        env.AddSconsTarget2Eclipse(
            etree, targets, 'print_libpath', '-s', '#.Print LD_LIBRARY_PATH',
        )
        env.AddSconsTarget2Eclipse(
            etree, targets, 'print_libpath', '-s --install', '#.Print LD_LIBRARY_PATH (kplushome3)',
        )

        for module in progDirs:
            env.AddSconsTarget2Eclipse(
                etree, targets, str(module), '--install',
            )

    env.WriteEclipseProjectFile(cproject, tree)


def generate(env):
    env.AddMethod(AddSconsTarget2Eclipse, 'AddSconsTarget2Eclipse')
    env.AddMethod(AddTargets2EclipseProject, 'AddTargets2EclipseProject')
    env.AddMethod(AddIncludes2EclipseCProject, 'AddIncludes2EclipseCProject')
    env.AddMethod(WriteEclipseProjectFile, 'WriteEclipseProjectFile')


def exists(env):
    return 1
