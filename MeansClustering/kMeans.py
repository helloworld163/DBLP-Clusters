'''
CSE 546 Final Project
Standard k-means method with soft labeling
'''

from __future__ import division
from numpy import *
import numpy.random as random
import numpy.linalg as linalg
import matplotlib.pyplot as plt
import sklearn.metrics.pairwise as dist
from collections import defaultdict
import os.path
import time
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

def main(path, title):
    set_printoptions(precision=3)
    #path = ""
    #'''
    if not os.path.exists(path + 'np_' + title + '.npy'):
        X = genfromtxt(path + title + '_out.csv', delimiter = ',', dtype = float64)
        save(path + 'np_' + title, X)
    else:
        X = load(path + 'np_' + title + '.npy')

    N = X.shape[0]
    if not os.path.exists(path + 'np_' + title + 'labels.npy'):
        a_id = genfromtxt(path + title + '_authors.csv', dtype = str, delimiter = '\n')
        Y = zeros([N,9])
        #read in labels
        f = open('labels.csv','r')
        for line in f:
            split = line.split(',')
            possible_index = where(a_id==split[0])[0]
            #print len(where(a_id==split[0])[0])
            if len(possible_index) != 0:
                if len(possible_index) != 1:
                    print "Major problem with", possible_index, "and", split[1]
                Y[possible_index[0]][M[split[1]]] = (float)(split[2])
        f.close()
        save(path + 'np_' + title + 'labels', Y)
    else:
        Y = load(path + 'np_' + title + 'labels.npy')

    X /= (sum(X**2, axis=1)**0.5).reshape(N,1)
    interResults = []
    intraResults = []
    for k in [2,4,6,8,10,12,14,16,18]:
        st = time.time()
        centers, labels = kMeansCos(X,k)
        print "Time", time.time() - st
        #print centers
        print "CLUSTERS FOR K =", k
        #want min intra distance
        intraDist = intraSumCos(X,centers,labels,k)
        print "intraDist", intraDist, "--->", sum(intraDist)/k
        intraResults.append(sum(intraDist)/k)
        #want max inter distance
        interDist = interSumCos(centers,k)
        print "interDist", interDist, "--->", sum(interDist)/k
        interResults.append(sum(interDist)/k)
        allOrNothingMistakes, accuracy, precision, recall, tpfn  = softLabelEval(Y, labels, k)
        print "allOrNothingMistakes", allOrNothingMistakes, "out of", N
        print "Accuracy", accuracy, "--->", sum(accuracy)/9
        print "Precision", precision, "--->", precision.dot(tpfn)/sum(tpfn)
        print "Recall", recall, "--->", recall.dot(tpfn)/sum(tpfn)
        print "TPFN", tpfn
    print "------------------------"
    for i in range(len(interResults)):
        print intraResults[i], ",", interResults[i]
    print "------------------------"


def kMeansCos(X,k,centers=[]):
    N,d = X.shape

    if len(centers) == 0:
        #generate k random centers from points in X
        centers = X[random.permutation(N)[:k]].copy()
    num_iter = 0
    old_labels = array([0 for i in range(N)])
    labels = array([-1 for i in range(N)])
    #cluster_size = zeros(k)
    new_centers = zeros([k,d])
    #stop if num_iter == 20 or if labels don't change
    while num_iter < 20 and sum(abs(labels-old_labels)) != 0:
        num_iter += 1
        old_labels = labels.copy()
        for i in range(N):
            bestC = argmin(dist.pairwise_distances(centers, X[i].reshape(1,d), metric='cosine'))
            #print "bestC", bestC
            labels[i] = bestC
            new_centers[bestC] = new_centers[bestC] + X[i]
        for i in range(k):
            centers[i] = new_centers[i]/(float)(sum(new_centers[i]**2)**0.5)
        #print "newC", centers
        new_centers = zeros([k,d])
        cluster_size = zeros(k)
    print "Number Iterations for k =", k, "is", num_iter
    return centers, labels

def softLabelEval(Y, labels, k):
    allOrNothingMistakes = 0
    accuracy = zeros(9)
    #true positives
    tps = zeros(9)
    #true positives and false negatives
    tpfns = zeros(9)
    #true positive and false positives
    tpfps = zeros(9)
    for j in range(k):
        Y_j = Y[labels==j]
        #print "Y_j", Y_j
        #get cluster label
        label_j = sum(Y_j,axis=0)/sum(Y_j)
        #print "L1", label_j
        #thresholding
        label_j = where(label_j < 0.2, 0, 1)
        print "L", j, "=", label_j
        #labels already thresholded to remove small percentages
        Y_j[Y_j > 0] = 1
        Y_j = Y_j.astype(int)

        diff = abs(Y_j-label_j)
        summed = Y_j+label_j
        allOrNothingMistakes += sum(any(diff == 1, axis=1))
        print "Sum Correct" , sum(1-diff,axis=0), "out of", Y_j.shape[0]
        accuracy += sum(1-diff,axis=0)
        for i in range(Y_j.shape[1]):
            bin = bincount(summed[:,i])
            if len(bin) >= 3:
                tps[i] += bin[2]
            tpfps[i] += label_j[i]*Y_j.shape[0]
            tpfns[i] += sum(Y_j,axis=0)[i]
    precision = zeros(9)
    recall = zeros(9)
    for i in range(Y.shape[1]):
        precision[i] += tps[i]/tpfps[i] if tpfps[i] != 0 else 1
        recall[i] += tps[i]/tpfns[i] if tpfns[i] != 0 else 1
    accuracy /= Y.shape[0]
    return allOrNothingMistakes, accuracy, precision, recall, tpfns

def intraSumCos(X, centers, labels, k):
    SD = zeros(k)
    binned = bincount(labels)
    for j in range(k):
        #average sum distance by total weight associated with cluster j
        SD[j] = sum(1 - X[labels==j].dot(centers[j]))/binned[j]
    return SD

def interSumCos(centers, k):
    SD = zeros(k)
    for j in range(k):
        #average pairwise distance between centroids
        SD[j] = sum(1 - centers.dot(centers[j]))/(k-1)
    return SD

if __name__ == '__main__':
    args = sys.argv
    if len(args) != 3:
        print "Must provide path and file title: python graphToMatrix.py path title"
    else:
        main(args[1], args[2])