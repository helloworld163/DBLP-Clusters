from __future__ import division
from numpy import *
import numpy.random as random
import numpy.linalg as linalg
#import matplotlib.pyplot as plt
#import sklearn.metrics.pairwise as dist
from collections import defaultdict
import os.path
import time
import contextlib
import sys

'''
Areas
 0 - AI
 1 - DB
 2 - GV
 3 - HA
 4 - HCI
 5 - ML
 6 - NC
 7 - PL
 8 - TH

For each author, label is 1x9 vector where each entry represents percentage in research area ordered alphabetically
Example: [0,0,0.6,0,0,0,0.4,0,0] -> 60 percent in GV and 40 percent in NC
'''
#global mapping M of area to integers
M = {'AI':0, 'DB':1, 'GV':2, 'HA':3, 'HCI':4, 'ML':5, 'NC':6, 'PL':7, 'TH':8}

def main():
    #set_printoptions(precision=3)
    X = genfromtxt("INFOMAPXWEIGHTED.csv", delimiter = ',', dtype = int32)
    Y = genfromtxt("INFOMAPYWEIGHTED.csv", delimiter = ',', dtype = int32)
    
    #'''
    '''
    X = array([[1.,1],[1.5,2],[3,4],[5,7],[3.5,5],[4.5,5],[3.5,4.5]])
    Y = array([[1,0],[0.5,0.5],[.4,.6],[1,0],[0,1],[0,1],[0,1]])
    N = 7
    '''
    #normalize X, only do if using cosine
    #X /= (sum(X**2, axis=1)**0.5).reshape(N,1)
    #print X
    #print any((Y>0) & (Y<0.2))
    st = time.time()
    print
    print "*********************"
    #centers, weights = kMeansCos(X,k,m)
    print time.time() - st
    print "*********************"
    #tpfn is true positives with false negatives
    allOrNothingMistakes, accuracy, precision, recall, tpfn  = hardLabelEval(X,Y)
    print "allOrNothingMistakes", allOrNothingMistakes, "out of", X.shape[0]
    print "Accuracy", accuracy, "--->", sum(accuracy)/9
    print "Precision", precision, "--->", precision.dot(tpfn)/sum(tpfn)
    print "Recall", recall, "--->", recall.dot(tpfn)/sum(tpfn)
    print "TPFN", tpfn

def hardLabelEval(X,Y):
    #labels = weights.T.dot(Y)
    #    labels[j] = where(labels[j] < labels[j].max(),0,1)
    #print "Center Labels\n", labels
    #result = weights.dot(labels)
    #result /= sum(result, axis=1).reshape(result.shape[0],1)
    #result = where(result < 0.2, 0, 1)
    #Result is the vector with labels

    result = X
    
    #print "Result", result
    #labels were already thesholded
    Y[Y > 0] = 1
    Y = Y.astype(int)
    diff = abs(Y-result)
    summed = Y+result
    allOrNothingMistakes = sum(any(diff == 1, axis=1))
    print "Sum Correct" , sum(1-diff,axis=0), "out of", Y.shape[0]
    #those that are right will be 0
    accuracy = sum(1-diff,axis=0)/Y.shape[0]
    precision = zeros(9)
    recall = zeros(9)
    for j in range(Y.shape[1]):
        bin = bincount(summed[:,j])
        if len(bin) >= 3:
            tp = bin[2]
        else:
            tp = 0
        result_j = sum(result,axis=0)[j]
        true_j = sum(Y,axis=0)[j]
        precision[j] = tp/result_j if result_j != 0 else 1
        recall[j] = tp/true_j if true_j != 0 else 1
    return allOrNothingMistakes, accuracy, precision, recall, sum(Y,axis=0)

if __name__ == '__main__':
    args = sys.argv
    main()
