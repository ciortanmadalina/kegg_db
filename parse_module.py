#!/usr/bin/python3
import re
import sys

print ('Number of arguments:', len(sys.argv), 'arguments.', str(sys.argv))

if len(sys.argv) != 2 :
    print('You provided ' ,(len(sys.argv) - 1 ) , ' arguments. \n Please run parse_module.py <module_name>')
    sys.exit(2)

module = sys.argv[1]

moduleReactionFileName = 'insert_module_reaction.sql'
reactionCompoundsFileName = 'insert_reaction_compound.sql'

#read file
f=open(module)
data=f.read()
f.close()

'''
Retrieves paragraph section by name (REACTION),
returns an array whitespace trimmed
'''
def getSectionArray(name):
    pattern = re.compile(r"" + name + "((.*\n)*?)[A-Z]+")
    resultLines = pattern.search(data).group(1).strip().split('\n')
    return [ r.strip() for r in resultLines]

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
        reaction_name= re.split('\+|,', reaction_name)[0]
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

#Method invocations

reactions = getSectionArray("REACTION")
parseReactions(reactions)

