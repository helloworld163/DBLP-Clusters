from __future__ import division
from numpy import *
import numpy.random as random
import numpy.linalg as linalg
import matplotlib.pyplot as plt
import sklearn.metrics.pairwise as dist
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
    #'''
    '''
    X = array([[1.,1],[1.5,2],[3,4],[5,7],[3.5,5],[4.5,5],[3.5,4.5]])
    Y = array([[1,0],[0.5,0.5],[.4,.6],[1,0],[0,1],[0,1],[0,1]])
    N = 7
    '''
    #normalize X, only do if using cosine
    X /= (sum(X**2, axis=1)**0.5).reshape(N,1)
    #print X
    #print any((Y>0) & (Y<0.2))
    for m in [1.1,1.3,1.5,1.7,1.9,2.1,2.3,2.5]:
        for k in [7,8,9,10,11,12]:
            st = time.time()
            #m is fuzziness factor
            print
            print "*********************"
            centers, weights = kMeansCos(X,k,m)
            print time.time() - st
            print "*********************"
            #tpfn is true positives with false negatives
            allOrNothingMistakes, accuracy, precision, recall, tpfn  = hardLabelEval(Y, weights, k)
            print "allOrNothingMistakes", allOrNothingMistakes, "out of", N
            print "Accuracy", accuracy, "--->", sum(accuracy)/9
            print "Precision", precision, "--->", precision.dot(tpfn)/sum(tpfn)
            print "Recall", recall, "--->", recall.dot(tpfn)/sum(tpfn)
            print "TPFN", tpfn

def kMeansEuc(X,k,m,centers=[]):
    N,d = X.shape
    if len(centers) == 0:
        #generate k random centers from points in X
        centers = X[random.permutation(N)[:k]].copy()
    num_iter = 0
    new_centers = zeros([k,d])
    old_weights = ones([N,k])
    weights = zeros([N,k])
    #stop if num_iter == 20 or if labels don't change
    while num_iter < 100 and abs(weights-old_weights).max() > 0.01:
        num_iter += 1
        old_weights = weights.copy()
        #print "Center", centers
        #print "centers", apply_along_axis(linalg.norm, 1, centers)
        for i in range(N):
            #print "X[i]", X[i]
            c_dist = dist.pairwise_distances(centers, X[i], metric='euclidean')
            #membership updates use euclidean distance squared
            #print "center_dist", c_dist
            zero_index = where(c_dist == 0)[0]
            if len(zero_index) != 0:
                weights[i] = zeros(k)
                weights[i][zero_index] = 1
            else:
                temp_sum = sum(c_dist**(-2./(m-1)))
                weights[i] = (1/((c_dist**(2./(m-1)))*temp_sum)).reshape(k)
            new_centers += (weights[i]**m).reshape(k,1)*X[i]
        #print "Weights", weights
        #print "New", new_centers
        for i in range(k):
            centers[i] = new_centers[i]/(float)(sum((weights[:,i])**m))
        #print "newC", centers
        new_centers = zeros([k,d])
    print "Number Iterations for k", k, "clusters with fuzziness", m, "is", num_iter, "and runtime is",
    return centers, weights

def kMeansCos(X,k,m,centers=[]):
    N,d = X.shape
    if len(centers) == 0:
        #generate k random centers from points in X
        centers = X[random.permutation(N)[:k]]
    num_iter = 0
    new_centers = zeros([k,d])
    old_weights = ones([N,k])
    weights = zeros([N,k])
    #stop if num_iter == 20 or if labels don't change
    while num_iter < 100 and abs(weights-old_weights).max() > 0.01:
        num_iter += 1
        old_weights = weights.copy()
        #print "Center", centers
        #print "centers", apply_along_axis(linalg.norm, 1, centers)
        for i in range(N):
            #unit length so don't need to divide by lengths
            #print "X", X[i]
            c_dist = (1 - centers.dot(X[i])).reshape(k,1)
            c_dist[c_dist < 1e-14] = 0
            #print "center_dist", c_dist
            zero_index = where(c_dist == 0)[0]
            if len(zero_index) != 0:
                weights[i] = zeros(k)
                weights[i][zero_index] = 1
            else:
                temp_sum = sum(c_dist**(-1./(m-1)))
                #print "B", (1/((c_dist**(1./(m-1)))*temp_sum)).reshape(k)
                weights[i] = (1/((c_dist**(1./(m-1)))*temp_sum)).reshape(k)
            new_centers += (weights[i]**m).reshape(k,1)*X[i]
        #print "Weights", weights
        #print "New", new_centers
        for i in range(k):
            centers[i] = new_centers[i]/(float)((sum((((weights[:,i])**m).dot(X))**2))**0.5)
        #print "newC", centers
        new_centers = zeros([k,d])
    print "Number Iterations for k =", k, "clusters with fuzziness m =", m, "is", num_iter, "and runtime is",
    return centers, weights

def hardLabelEval(Y, weights, k):
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
    return allOrNothingMistakes, accuracy, precision, recall, sum(Y,axis=0)

if __name__ == '__main__':
    args = sys.argv
    if len(args) != 3:
        print "Must provide path and file title: python graphToMatrix.py path title"
    else:
        main(args[1], args[2])