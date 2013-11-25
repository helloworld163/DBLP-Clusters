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
    path = "small/"
    #path = ""
    #'''
    if not os.path.exists(path + 'np_coAuthors.npy'):
        X = genfromtxt(path + 'coAuthors_out.csv', delimiter = ',', dtype = float64)
        save(path + 'np_coAuthors', X)
    else:
        X = load(path + 'np_coAuthors.npy')

    N = X.shape[0]
    if not os.path.exists(path + 'np_labels.npy'):
        a_id = genfromtxt(path + 'coAuthors_authors.csv', dtype = str, delimiter = '\n')
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
        save(path + 'np_labels', Y)
    else:
        Y = load(path + 'np_labels.npy')
    #'''
    '''
    X = array([[1.,1],[1.5,2],[3,4],[5,7],[3.5,5],[4.5,5],[3.5,4.5]])
    Y = array([[1,0],[0.5,0.5],[.4,.6],[1,0],[0,1],[0,1],[0,1]])
    N = 7
    '''
    X /= apply_along_axis(linalg.norm, 1, X)
    print X
    print Y
    m = 2
    for k in [2]:
        st = time.time()
        #m is fuzziness factor
        centers, weights = kMeans(X,k,m)
        print "Time", time.time() - st
        #print weights
        #print centers
        #print "CLUSTERS FOR K =", k
        #SS = sumSquares(X, centers, labels, k)
        #print "Sum Square for k =", k, "is", sum(SS)
        totalMistakes = hardLabelMistakes(Y, weights, k)
        print "Unweighted", totalMistakes
        print "Mistake Rate for k =", k, "is", totalMistakes/N, "---->", sum(totalMistakes/N)/9

def kMeans(X,k,m,centers=[]):
    N,d = X.shape
    if len(centers) == 0:
        #generate k random centers from points in X
        centers = X[random.permutation(N)[:k]]
    num_iter = 0
    new_centers = zeros([k,d])
    old_weights = ones([N,k])
    weights = zeros([N,k])
    #stop if num_iter == 20 or if labels don't change
    while num_iter < 20 and abs(weights-old_weights).max() > 0.0001:
        num_iter += 1
        old_weights = weights.copy()
        #print "Center", centers
        #print "centers", apply_along_axis(linalg.norm, 1, centers)
        for i in range(N):
            #print "X[i]", X[i]
            c_dist = dist.pairwise_distances(centers, X[i], metric='euclidean')
            #unit length so don't need to divide by lengths
            #print "X", X[i]
            #c_dist = (1 - centers.dot(X[i])).reshape(k,1)
            #c_dist[c_dist < 1e-14] = 0
            #membership updates use euclidean distance squared
            #print "center_dist", c_dist
            zero_index = where(c_dist == 0)[0]
            if len(zero_index) != 0:
                weights[i] = zeros(k)
                weights[i][zero_index] = 1
            else:
                temp_sum = sum(c_dist**(-2./(m-1)))
                #print "B", (1/((c_dist**(2./(m-1)))*temp_sum)).reshape(k)
                weights[i] = (1/((c_dist**(2./(m-1)))*temp_sum)).reshape(k)
            new_centers += (weights[i]**m).reshape(k,1)*X[i]
        #print "Weights", weights
        #print "New", new_centers
        for i in range(k):
            centers[i] = new_centers[i]/(float)(sum((weights[:,i])**m))
        #print "newC", centers
        new_centers = zeros([k,d])
    print "Number Iterations for k =", k, "is", num_iter
    return centers, weights

def sumSquares(X, centers, labels, k):
    SS = zeros(k)
    for j in range(k):
        X_j = X[labels==j]
        SS[j] = sum(sum((X_j-centers[j])**2,axis=1))
    return SS

def hardLabelMistakes(Y, weights, k):
    labels = weights.T.dot(Y)
    print labels
    for j in range(k):
        labels[j] = where(labels[j] < labels[j].max(),0,1)
    print labels
    result = weights.dot(labels)
    result /= sum(result, axis=1).reshape(result.shape[0],1)
    result = where(result < 0.1, 0, 1)
    #print result
    Y[Y > 0] = 1
    #print Y
    return sum(abs(Y-result),axis=0)






if __name__ == '__main__':
    main()