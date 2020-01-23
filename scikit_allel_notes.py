##This is python3
# import scikit-allel
import allel

#Load your vcf
callset = allel.read_vcf('095_popanalysis.vcf', fields='*')
sorted(callset.keys())

#Load data just for a group of samples
callset = allel.read_vcf('example.vcf', samples=['NA00001', 'NA00003'])

##Transform your vcf into a numpy array

allel.vcf_to_npz('example.vcf', 'example.npz', fields='*', overwrite=True)

##load yout new numpy

import numpy as np
callset = np.load('example.npz')
callset

##to imporve memory, transform your vcf into HDF5 format
allel.vcf_to_hdf5('095_popanalysis.vcf', '095_popanalysis.h5', fields='*', overwrite=True)

###Load your new HDF5 files
import h5py
callset = h5py.File('095_popanalysis.h5', mode='r')
callset
