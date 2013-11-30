from __future__ import division
from numpy import *
import scipy.sparse as scipy
from collections import defaultdict
import csv
import sys

def main(filename):
    f = open(filename, 'r')
    path = filename.rsplit('/',1)[0] + '/'
    filedescr = filename.rsplit('/',1)[1].split('.')[0]
    rowIndex = defaultdict(lambda: -1)
    colIndex = defaultdict(lambda: -1)
    fweights = defaultdict(list)
    conferenceLinks = defaultdict(list)
    authorList = []
    R = 0
    C = 0
    fac = 2
    for line in f:
        #authors appear in author[0] and author[1] columns (not symmetric)
        authors = line.strip().split(',')
        #ensures don't relabel an author with different rowIndex
        if rowIndex[authors[0]] == -1:
            rowIndex[authors[0]] = R
            authorList.append([authors[0]])
            R = R+1
        if colIndex[authors[1]+'_'+authors[2]] == -1:
            colIndex[authors[1]+'_'+authors[2]] = C
            C = C+1
        if authors[0]==authors[1]:
            conferenceLinks[authors[2]].append([authors[0],(int)(authors[3])])
        else:
            fweights[authors[0]].append([authors[1]+'_'+authors[2],(int)(authors[3])])
    matrix = zeros([R,C])
    for conf in conferenceLinks.keys():
        for a1 in conferenceLinks[conf]:
            for a2 in conferenceLinks[conf]:
                if a1[0] == a2[0]:
                    matrix[rowIndex[a1[0]]][colIndex[a2[0]+'_'+conf]] = fac*a1[1]
                else:
                    matrix[rowIndex[a1[0]]][colIndex[a2[0]+'_'+conf]] = a1[1]
                #change weight for author with him/herself
    for author in fweights.keys():
        for coa in fweights[author]:
            #multiply by f factor
            matrix[rowIndex[author]][colIndex[coa[0]]] += fac*coa[1]
    save(path + 'np_'+filedescr, matrix)
    # print rowIndex
    # print colIndex
    # print authorList
    # print matrix
    with open(filename.split('.')[0] + '_authors.' + filename.split('.')[1], 'w') as outcsv:   
        writer = csv.writer(outcsv, delimiter=',')
        writer.writerows(authorList)
    f.close()


if __name__=='__main__':
    args = sys.argv
    if len(args) != 2:
        print "Must provide filename: python graphToMatrix.py filename"
    else:
        main(args[1])