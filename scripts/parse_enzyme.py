#!/usr/bin/python3
import re
import sys
import utils

enzyme = sys.argv[1]
outputFileName = 'output/insert_enzyme.sql'

#read file
data=utils.getFileContent(enzyme)


names=utils.getSectionString("NAME", data)
names=names.replace("'", "''") #escape single quote for postgres
outputFile = open (outputFileName, 'a')
outputFile.write(
        "INSERT INTO raw_enzyme (id, name) VALUES ('" + enzyme + "' , '" + names + "');\n")

outputFile.close()





