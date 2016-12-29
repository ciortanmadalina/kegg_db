#!/usr/bin/python3
import re
import sys
import utils

compound = sys.argv[1]
compoundsFileName = 'output/insert_compound.sql'

#read file
data=utils.getFileContent(compound)


names=utils.getSectionString("NAME", data)
names= names.replace("'", "''")
formula=utils.getSectionString("FORMULA", data)
mass=utils.getSectionString("EXACT_MASS",data)

compoundsFile = open (compoundsFileName, 'a')
compoundsFile.write(
"INSERT INTO raw_compound (id, name, formula, mass) VALUES ('" + compound + "' , '" + names + "' , '"+ formula  + "' , '" +  mass + "');\n")

compoundsFile.close()

