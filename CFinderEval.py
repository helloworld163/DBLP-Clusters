'''
CSE 546 Final Project
Code which takes the output of the CFinder method and evaluates the results
'''

from __future__ import division
from numpy import *
import pickle
import sys
import os.path
import math
import contextlib
from collections import defaultdict
'''
id, name, field, total articles, percentage
Note author names are distinct
'''
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
    set_printoptions(precision=3)
    numClusters = 0
    a_id = []
    f = open('communities_18','r')
    for line in f:
        numClusters += 1
        a_id.extend(line.split(':')[1].split(' ')[1:-1])
    print "TOTAL AUTHORS IN FILE", len(a_id)
    print "TOTAL AUTHORS", unique(genfromtxt('coAuthors.csv', delimiter = ' ', dtype = float64).flatten()).shape
    a_id = unique(array(a_id))
    a_id.sort()
    f.close()
    print "AID", a_id.shape
    print "NUM CLUSTERS", numClusters
    Y = zeros([a_id.shape[0],9])
    #read in labels
    f = open('/Users/ljorr1/Documents/First Year/Machine Learning/FinalProject/DBLP-Clusters/MeansClustering/labels.csv','r')
    for line in f:
        split = line.split(',')
        possible_index = where(a_id==split[0])[0]
        #print len(where(a_id==split[0])[0])
        if len(possible_index) != 0:
            if len(possible_index) != 1:
                print "Major problem with", possible_index, "and", split[1]
            Y[possible_index[0]][M[split[1]]] = (float)(split[2])
    f.close()

    f = open('communities_18','r')
    clusters = zeros([numClusters, 9])
    classification = defaultdict(list)
    for line in f:
        clusterNum = (int)(line.split(':')[0])
        line = line.split(':')[1]
        aList = line.split(' ')[1:-1]
        for au in aList:
            classification[au].append(clusterNum)
            clusters[clusterNum] += Y[a_id==au].reshape(9)
        clusters[clusterNum] /= sum(clusters[clusterNum])
        clusters[clusterNum][clusters[clusterNum] < 0.2] = 0
        clusters[clusterNum] /= sum(clusters[clusterNum])
    print "CLUSTERS\n", clusters
    #print "CLASSIFICATIONS\n", classification
    f.close()
    #calculate error
    result = zeros([a_id.shape[0],9])
    for au in classification.keys():
        total = 0
        weight = 1/len(classification[au])
        if weight != 1:
            print "AU", au
        for clusterNum in classification[au]:
            result[a_id==au] += weight*clusters[clusterNum]
    result = where(result < 0.2, 0, 1)
    Y[Y > 0] = 1
    Y = Y.astype(int)
    diff = abs(Y-result)
    summed = Y+result
    allOrNothingMistakes = sum(any(diff == 1, axis=1))
    print "Sum Correct" , sum(1-diff,axis=0), "out of", Y.shape[0]
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
    tpfn = sum(Y,axis=0)
    print "allOrNothingMistakes", allOrNothingMistakes, "out of", Y.shape[0]
    print "Accuracy", accuracy, "--->", sum(accuracy)/9
    print "Precision", precision, "--->", precision.dot(tpfn)/sum(tpfn)
    print "Recall", recall, "--->", recall.dot(tpfn)/sum(tpfn)
    
        

def labelEval(Y, weights, k):
    labels = weights.T.dot(Y)
    for j in range(k):
        labels[j] = where(labels[j] < labels[j].max(),0,1)
    print "Center Labels\n", labels
    result = weights.dot(labels)
    result /= sum(result, axis=1).reshape(result.shape[0],1)
    result = where(result < 0.2, 0, 1)
    #print "Result", result
    #labels were already thesholded
    Y[Y > 0] = 1
    Y = Y.astype(int)
    summed = Y+result
    allOrNothingMistakes = sum(any(diff == 1, axis=1))
    print "Sum Correct" , sum(1-diff,axis=0), "out of", Y.shape[0]
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



if __name__=='__main__':
    main()