# python script to run reconstruction algorithm
import matplotlib.pyplot as plt
from matplotlib import animation
import numpy as np
import scipy.io
from reconstruct import reconstruct
import time

FileName = 'USAF.mat'
DATA = scipy.io.loadmat(FileName)
images = DATA['Images']
i,j = images.shape
f,ax = plt.subplots(i,j);

for i_iters in range(i):
    for j_iters in range(j):
        ax[i_iters,j_iters].imshow(images[i_iters][j_iters])

plt.show()
