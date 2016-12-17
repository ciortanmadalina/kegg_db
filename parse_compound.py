#!/usr/bin/python3
import re
import sys
import utils
#print ('Number of arguments:', len(sys.argv), 'arguments.', str(sys.argv))

if len(sys.argv) != 2 :
    print('You provided ' ,(len(sys.argv) - 1 ) , ' arguments. \n Please run parse_module.py <module_name>')
    sys.exit(2)

compound = sys.argv[1]
compoundsFileName = 'output/insert_compound.sql'

#read file
data=utils.getFileContent(compound)


names=utils.getSectionString("NAME", data)
formula=utils.getSectionString("FORMULA", data)
mass=utils.getSectionString("EXACT_MASS",data)

compoundsFile = open (compoundsFileName, 'a')
compoundsFile.write(
"INSERT INTO raw_compound (id, name, formula, mass) VALUES ('" + compound + "' , '" + names + "' , '"+ formula  + "' , '" +  mass + "');\n")

compoundsFile.close()

