# cython: boundscheck = False
# cython: wraparound = False

cimport cython
import numpy as np
from libc.math cimport sqrt
from cython.parallel import parallel, prange

# up till now we're still utilizing only a single thread
# we can use multiple threads and tap into all available CPU cores
# using the parallel functionality;
# to do this we need to release the GIL (this helps python's memory management, 
# but it is also this functionality that does not allow python to use all cores)
# to call a "GIL-less" function, we place nogil after it;
# note that we can't interact with python objects inside
cdef inline double euclidean_distance(double[:, :] X, int i, int j, int N) nogil:

    # declare C types for as many of our variables as possible
    # using cdef:
    cdef:
        int k
        double tmp, d = 0.0
    
    for k in range(N):
        tmp = X[i, k] - X[j, k]
        d += tmp * tmp
    
    return sqrt(d)

def pairwise3(double[:, :] X):
    
    cdef:
        int i, j
        double dist
        int M = X.shape[0], N = X.shape[1]
        double[:, :] D = np.zeros((M, M), dtype = np.float64)
    
    # parallelize this over the outermost loop, using the prange function
    with nogil, parallel():
        for i in prange(M):
            for j in range(M):
                dist = euclidean_distance(X, i, j, N)
                D[i, j] = dist
                D[j, i] = dist

    return D

