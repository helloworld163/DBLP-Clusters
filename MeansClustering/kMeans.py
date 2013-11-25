from __future__ import division
from numpy import *
import numpy.random as random
import numpy.linalg as linalg
#import scipy.spatial.distance as dist
import matplotlib.pyplot as plt
import sklearn.metrics.pairwise as dist
from collections import defaultdict
import os.path
import time

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
    if not os.path.exists('np_coAuthors.npy'):
        X = genfromtxt('coAuthors_out.csv', delimiter = ',', dtype = float64)
        save('np_coAuthors', X)
    else:
        X = load('np_coAuthors.npy')

    N = X.shape[0]
    if not os.path.exists('np_labels.npy'):
        a_id = genfromtxt('coAuthors_authors.csv', dtype = str, delimiter = '\n')
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
        save('np_labels', Y)
    else:
        Y = load('np_labels.npy')

    #for k in [2,3,4,5,6,7,8,9,10]:
    for k in [2,8,10,12,14,16,18]:
        st = time.time()
        centers, labels = kMeans(X,k)
        print "Time", time.time() - st
        #print centers
        print "CLUSTERS FOR K =", k
        #SS = sumSquares(X, centers, labels, k)
        #print "Sum Square for k =", k, "is", sum(SS)
        totalMistakes = softLabelMistakes(Y, labels, k)
        print "Mistake Rate for k =", k, "is", totalMistakes/N, "---->", sum(totalMistakes/N)/9

def kMeans(X,k,centers=[]):
    N,d = X.shape

    if len(centers) == 0:
        #generate k random centers from points in X
        centers = X[random.permutation(N)[:k]]
    num_iter = 0
    old_labels = array([0 for i in range(N)])
    labels = array([-1 for i in range(N)])
    cluster_size = zeros(k)
    new_centers = zeros([k,d])
    #stop if num_iter == 20 or if labels don't change
    while num_iter < 20 and sum(abs(labels-old_labels)) != 0:
        num_iter += 1
        old_labels = labels.copy()
        for i in range(N):
            #bestC = argmin(dist.pairwise_distances(centers, X[i], metric='euclidean'))
            bestC = argmin(dist.pairwise_distances(centers, X[i].reshape(1,N), metric='cosine'))
            #bestC = argmin([dist.euclidean(X[i], centers[j]) for j in range(k)])
            #print "bestC", bestC
            labels[i] = bestC
            new_centers[bestC] = new_centers[bestC] + X[i]
            cluster_size[bestC] += 1
        for i in range(k):
            centers[i] = new_centers[i]/(float)(cluster_size[i])
        #print "newC", centers
        new_centers = zeros([k,d])
        cluster_size = zeros(k)
    print "Number Iterations for k =", k, "is", num_iter
    return centers, labels

def sumSquares(X, centers, labels, k):
    SS = zeros(k)
    for j in range(k):
        X_j = X[labels==j]
        SS[j] = sum(sum((X_j-centers[j])**2,axis=1))
    return SS

def softLabelMistakes(Y, labels, k):
    totalMistakes = zeros(9)
    for j in range(k):
        Y_j = Y[labels==j]
        #print "Y_j", Y_j
        #get cluster label
        label_j = sum(Y_j,axis=0)/sum(Y_j)
        #print "L1", label_j
        #thresholding
        label_j[label_j < 0.1] = 0
        label_j /= sum(label_j)
        label_j[label_j > 0] = 1
        print "L", j, "=", label_j
        #labels already thresholded to remove small percentages
        Y_j[:,Y_j > 0] = 1
        #print Y_j
        #print sum(abs(label_j-Y_j),axis=0)
        totalMistakes += sum(abs(label_j-Y_j),axis=0)
    print totalMistakes
    return totalMistakes






if __name__ == '__main__':
    main()