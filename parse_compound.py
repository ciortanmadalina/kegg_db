#!/usr/bin/python3
import re
import sys

#print ('Number of arguments:', len(sys.argv), 'arguments.', str(sys.argv))

if len(sys.argv) != 2 :
    print('You provided ' ,(len(sys.argv) - 1 ) , ' arguments. \n Please run parse_module.py <module_name>')
    sys.exit(2)

compound = sys.argv[1]
compoundsFileName = 'output/insert_compound.sql'

#read file
f=open(compound)
data=f.read()
f.close()


def getSectionString(name):
    pattern = re.compile(r"" + name + "((.*\n)*?)[A-Z]+")
    search = pattern.search(data)
    if search != None:
        result = search.group(1).strip().replace('\n', '')
        return re.sub(r'\s+', ' ', result)  # all spaces have been removed
    return ''



def getSectionArray(name):
    pattern = re.compile(r"" + name + "((.*\n)*?)[A-Z]+")
    resultLines = pattern.search(data).group(1).strip().split('\n')
    return [ r.strip() for r in resultLines]

names=getSectionString("NAME")
formula=getSectionString("FORMULA")
mass=getSectionString("EXACT_MASS")

compoundsFile = open (compoundsFileName, 'a')
compoundsFile.write(
"INSERT INTO raw_compound (id, name, formula, mass) VALUES ('" + compound + "' , '" + names + "' , '"+ formula  + "' , '" +  mass + "');\n")

compoundsFile.close()


