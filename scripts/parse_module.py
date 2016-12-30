#!/usr/bin/python3
import re
import sys
import utils

#print ('Number of arguments:', len(sys.argv), 'arguments.', str(sys.argv))

if len(sys.argv) != 2 :
    print('You provided ' ,(len(sys.argv) - 1 ) , ' arguments. \n Please run parse_module.py <module_name>')
    sys.exit(2)

module = sys.argv[1]

moduleReactionFileName = 'output/insert_module_reaction.sql'
reactionCompoundsFileName = 'output/insert_reaction_compound.sql'
reactionOrderFileName = 'output/insert_reaction_order.sql'

#read file
data=utils.getFileContent(module)


def parseReactions(lineReactions):
    moduleReactionsFile = open(moduleReactionFileName, 'a')
    reactionCompoundsFile = open (reactionCompoundsFileName, 'a')
    reactionOrderFile = open(reactionOrderFileName, 'a')
    reactions = []

    for line in lineReactions:
        # line looks like R05605  C04442 -> C00022 + C00118
        tokens = line.split()
        lineReactions = re.split('\+|,', tokens[0])

        type = 'INPUT'
        for i in range(1, len(tokens)):
            if tokens[i] == '+':
                continue
            if tokens[i] == '->':
                type = 'OUTPUT'
                continue
            for reaction_name in lineReactions:
                reactionCompoundsFile.write(
                "INSERT INTO raw_reaction_compound (reaction, compound, type) VALUES ( '" + reaction_name + "' , '"
                + tokens[i]  + "' , '" +  type + "' );\n")
        reactions.append(lineReactions)
    print('reactions', reactions)

    existingReactions = []
    for i in range(len(reactions)):
        for j in range(len(reactions[i])):
            moduleReactionsFile.write(
                "INSERT INTO raw_module_reaction (module, reaction) VALUES ( '"
                + module + "' , '" + reactions[i][j] + "' );\n")
            if i > 0:
                for parentReaction in reactions[i-1]:
                    #INSERT INTO raw_reaction_order (parentid, childid, module, loop) VALUES ('n6', 'n1', 'm1', true);
                    loop = "true" if (reactions[i][j] in existingReactions) else "false"
                    reactionOrderFile.write(
                "INSERT INTO raw_reaction_order (parentid, childid, module, loop) VALUES ( '"
                + parentReaction + "' , '" + reactions[i][j] +  "' , " + loop + " );\n")
                    print(parentReaction + '- ' +  reactions[i][j] , loop)
            existingReactions.append(reactions[i][j])
    print (existingReactions)
    moduleReactionsFile.close()
    reactionCompoundsFile.close()
    reactionOrderFile.close()
    #better clean up in bash
    #utils.removeDuplicateLines(moduleReactionFileName)
    #utils.removeDuplicateLines(reactionCompoundsFileName)

#Method invocations

reactions = utils.getSectionArray("REACTION", data,  "\n")
parseReactions(reactions)
