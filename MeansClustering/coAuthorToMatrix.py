from __future__ import division
from numpy import *
import scipy.sparse as scipy
from collections import defaultdict
import csv
import sys

def main(filename):
    f = open(filename, 'r')
    index = defaultdict(lambda: -1)
    edges = defaultdict(list)
    authorList = []
    N = 0
    for line in f:
        #authors are in alphabetical order when outputted
        authors = line.strip().split(',')
        #ensures don't relabel an author
        if index[authors[0]] == -1:
            index[authors[0]] = N
            authorList.append([authors[0]])
            N = N+1
        if index[authors[1]] == -1:
            index[authors[1]] = N
            authorList.append([authors[1]])
            N = N+1
        #check if weighted graph
        if len(authors) == 3:
            edges[authors[0]].append([authors[1],(int)(authors[2])])
        else:
            edges[authors[0]].append([authors[1], 1])
    matrix = zeros([N,N])
    for author in edges.keys():
        for coa in edges[author]:
            matrix[index[author]][index[coa[0]]] = coa[1]
            matrix[index[coa[0]]][index[author]] = coa[1]
    save(filename.rsplit('/',1)[0]+'/np_'+filename.split('/')[-1].split('.')[0], matrix)
    # print index
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