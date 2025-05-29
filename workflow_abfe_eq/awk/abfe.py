#!/usr/bin/env python3

import sys
import alchemlyb
from loguru import logger
from alchemlyb.workflows import ABFE

#..save output to external file
logger.remove()
logger.add("results.txt")

#..set dir
dir=sys.argv[1]
print(dir)

#..analyze data
workflow = ABFE(units='kcal/mol', software='GROMACS', dir=dir,
                prefix='dhdl', suffix='xvg', T=298, outdirectory='./')
#workflow.run(skiptime=20, uncorr='dhdl', threshold=50, estimators=('MBAR', 'BAR', 'TI'), overlap='O_MBAR.pdf', breakdown=True, forwrev=10)
workflow.run(skiptime=0, uncorr='dhdl', threshold=50, estimators=('TI'), overlap='O_MBAR.pdf', breakdown=True)
exit()
