#!/usr/bin/python3
import re
import sys

def getFileContent(name) :
    # read file
    f = open(name)
    data = f.read()
    f.close()
    return data

def getSectionString(name, data):
    pattern = re.compile(r"" + name + "((.*\n)*?)[A-Z]+")
    search = pattern.search(data)
    if search != None:
        result = search.group(1).strip().replace('\n', '')
        return re.sub(r'\s+', ' ', result)  # all spaces have been removed
    return ''


def getSectionArray(name, data, split):
    pattern = re.compile(r"" + name + "((.*\n)*?)[A-Z]+")

    search = pattern.search(data)
    if search != None:
      resultLines = search.group(1).strip().split(split)
      return [ r.strip() for r in resultLines]
    return []


def removeDuplicateLines(filename):
    uniqlines = set(open(filename).readlines())
    f = open(filename, 'w')
    f.writelines(set(uniqlines))
    f.close()
