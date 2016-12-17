#!/usr/bin/python3
import re
import sys
import utils
#print ('Number of arguments:', len(sys.argv), 'arguments.', str(sys.argv))

if len(sys.argv) != 2 :
    print('You provided ' ,(len(sys.argv) - 1 ) , ' arguments. \n Please run parse_module.py <module_name>')
    sys.exit(2)

reaction = sys.argv[1]
outputFileName = 'output/insert_reaction_enzyme.sql'

#read file
data=utils.getFileContent(reaction)


enzymes=utils.getSectionArray("ENZYME", data, None)

outputFile = open (outputFileName, 'a')
for enzyme in enzymes:
    outputFile.write(
        "INSERT INTO raw_reaction_enzyme (reaction, enzyme) VALUES ('" + reaction + "' , '" + enzyme + "' );\n")

outputFile.close()





