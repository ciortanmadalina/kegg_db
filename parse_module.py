#!/usr/bin/python3
import re
import sys

print ('Number of arguments:', len(sys.argv), 'arguments.', str(sys.argv))

if len(sys.argv) != 2 :
    print('You provided ' ,(len(sys.argv) - 1 ) , ' arguments. \n Please run parse_module.py <module_name>')
    sys.exit(2)

startReadFrom = "REACTION"
module = sys.argv[1]

moduleReactionFileName = 'output/insert_module_reaction.sql'
reactionCompoundsFileName = 'output/insert_reaction_compound.sql'
compoundsFileName = 'output/insert_compound.sql'

def removeDuplicateLines(filename):
    uniqlines = set(open(filename).readlines())
    f = open(filename, 'w')
    f.writelines(set(uniqlines))
    f.close()

def parseReactions(reactions):
    moduleReactionsFile = open(moduleReactionFileName, 'a')
    reactionCompoundsFile = open (reactionCompoundsFileName, 'a')
    for line in reactions:
        # line looks like R05605  C04442 -> C00022 + C00118
        tokens = line.split()
        reaction_name = tokens[0]
        moduleReactionsFile.write("INSERT INTO raw_module_reaction (module, reaction) VALUES '" + module + "' , '" + reaction_name + "');\n")
        type = 'INPUT'
        for i in range(1, len(tokens)):
            if tokens[i] == '+':
                continue
            if tokens[i] == '->':
                type = 'OUTPUT'
                continue
            reactionCompoundsFile.write(
                "INSERT INTO raw_reaction_compound (reaction, compound, type) VALUES '" + reaction_name + "' , '"
                + tokens[i]  + "' , '" +  type + "');\n")

        print(line)
    moduleReactionsFile.close()
    reactionCompoundsFile.close()
    #better clean up in bash
    removeDuplicateLines(moduleReactionFileName)
    removeDuplicateLines(reactionCompoundsFileName)

reactions = []
with open(module, 'r') as f:
    ignore = True
    for line in f:
        if ignore and line.startswith(startReadFrom):
            reactions.append(line[len(startReadFrom):-1].strip())
            ignore = False
            continue
        if ignore == False:
            if re.match(r'\s', line):
                reactions.append(line.strip())
            else:
                ignore=True

parseReactions(reactions)

