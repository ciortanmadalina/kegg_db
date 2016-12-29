#!/usr/bin/python3
import re
import sys
import utils
#print ('Number of arguments:', len(sys.argv), 'arguments.', str(sys.argv))

if len(sys.argv) != 2 :
    print('You provided ' ,(len(sys.argv) - 1 ) , ' arguments. \n Please run parse_module.py <module_name>')
    sys.exit(2)

pathway = sys.argv[1]
pathwayFileName = 'output/insert_pathway.sql'

#read file
data=utils.getFileContent(pathway)


name=utils.getSectionString("NAME", data)
description=utils.getSectionString("DESCRIPTION", data)
pathwayClass=utils.getSectionString("CLASS",data)

pathwayFile = open (pathwayFileName, 'a')
pathwayFile.write(
"INSERT INTO raw_pathway (id, name, description, class) VALUES ('" + pathway + "' , '" + name + "' , '"+ description  + "' , '" +  pathwayClass + "');\n")
pathwayFile.close()

