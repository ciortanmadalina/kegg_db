#!/usr/bin/python3
import re
import sys
import utils
print ('Number of arguments:', len(sys.argv), 'arguments.', str(sys.argv))

if len(sys.argv) != 2 :
    print('You provided ' ,(len(sys.argv) - 1 ) , ' arguments. \n Please run parse_module.py <module_name>')
    sys.exit(2)

enzyme = sys.argv[1]
outputFileName = 'output/insert_enzyme.sql'

#read file
data=utils.getFileContent(enzyme)


names=utils.getSectionString("NAME", data)

outputFile = open (outputFileName, 'a')
outputFile.write(
        "INSERT INTO raw_enzyme (id, name) VALUES ('" + enzyme + "' , '" + names + "');\n")

outputFile.close()





