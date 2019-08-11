#!/usr/bin/python3
import setuptools
import os
import sys
import re


with open("README.MD", "r") as fh:
    long_description = fh.read()

if 'GIT_TAG' in os.environ and os.environ['GIT_TAG']:
    version = os.environ['GIT_TAG'].replace('release/','')
else:
    version = '0.1.dev_'+os.environ['BRANCH']+'_'+os.environ['BUILD_NUMBER']

print('version:',version)
setuptools.setup(
     name='astinxml',  
     version=version,
     author="Arpad Magosanyi",
     author_email="mag@kodekonveyor.com",
     description="Obtains the AST of a project and dumps it in XML.",
     long_description=long_description,
     long_description_content_type="text/markdown",
     url="https://github.com/kode-konveyor/astinxml",
     package_dir = {'': 'src'},
     packages=['astinxml'],
     classifiers=[
         "Programming Language :: Python :: 3",
         "License :: OSI Approved :: GNU General Public License v3 or later (GPLv3+)",
         "Operating System :: OS Independent",
     ],

 )
