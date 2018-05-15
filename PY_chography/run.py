#python script to run reconstruction algorithm
from __future__ import division
import matplotlib.pyplot as plt
import numpy as np
import scipy.io
from reconstruct import reconstruct
import time

#FileName = 'mock_cl_256.mat'
FileName = 'meniscus.mat'
DATA = scipy.io.loadmat(FileName)

iters = 5
t0 = time.time()
obj,objFT = reconstruct(DATA,iters)
print(objFT.shape)
t1 = time.time()
print('total computation time: ' + str((t1-t0)/60)+'m')

plt.imshow(np.angle(obj),cmap='hsv')
plt.show()
plt.imshow(np.abs(obj),cmap='gray')
plt.show()
