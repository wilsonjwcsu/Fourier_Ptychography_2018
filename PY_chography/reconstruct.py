from __future__ import division
import numpy as np
from numpy.fft import fftn, ifftn, fftshift, ifftshift

def reconstruct(DATA,iterations):
    ## Define Parameters
    # Define Optical Parameters

    wavelength = DATA['wavelength']
    LED_spacing = DATA['LED_spacing']
    matrix_spacing = DATA['matrix_spacing']
    x_offset = DATA['x_offset']
    y_offset = DATA['y_offset']
    NA_obj = DATA['NA_obj']
    px_size = DATA['px_size']
    Images = DATA['Images']

    m_s,n_s = Images[0][0].shape
    array_dimensions = Images.shape
    arraysize = array_dimensions[0]

    ## Define Calculated Parameters
    LED_limit = LED_spacing*(arraysize - 1)/2
    LED_positions = np.linspace(float(-LED_limit),float(LED_limit),int(2*(LED_limit/LED_spacing)+1))
    k = 2 * np.pi / wavelength;    # wavevector magnitude
    # lists of transverse wavevectors
    kx_list = -k*np.sin(np.arctan((LED_positions + x_offset) / matrix_spacing));
    ky_list = -k*np.sin(np.arctan((LED_positions + y_offset) / matrix_spacing));

    kx_list=kx_list[0]
    ky_list=ky_list[0]
    # Pixel Size and NA calculations
    px_size_synth = px_size/4;

    # calculate subimage size
    # size of sub images in pixels
    m_r = m_s*(px_size / px_size_synth);
    n_r = m_r;

    # maximum spatial frequency for sub-image
    kt_max_sub = k * NA_obj;

    # maximum spatial frequency for reconstructed image
    # Use synthetic NA plus only the margin needed for subimage oversampling.
    # also take matrix offset into account
    max_offset = np.max(np.abs([x_offset, y_offset]));
    NA_matrix = np.sin(np.arctan((LED_limit + max_offset) / matrix_spacing));
    kt_max_rec = k * (NA_matrix + NA_obj);

    # spatial frequency axes for spectrums of images
    kx_axis_sub = np.linspace(-kt_max_sub[0],kt_max_sub[0],n_s);
    ky_axis_sub = np.linspace(-kt_max_sub[0],kt_max_sub[0],m_s);

    # grid of spatial frequencies for each pixel of reconstructed spectrum
    # same for subimage spectrum
    [kx_g_sub,ky_g_sub] = np.meshgrid(kx_axis_sub,ky_axis_sub);

    ## retrieve phase iteratively

    # initialize object
    dtype = np.complex64
    '''
    objectFT = np.zeros(shape=[int(m_r),int(n_r)]).astype(dtype)
    '''
    img = Images[int(np.floor(arraysize/2)),int(np.floor(arraysize/2))]
    objectFTguess = fftshift(fftn(img))
    pad_width = int((m_r-img.shape[0])/2)
    objectFT = np.pad(objectFTguess,pad_width=pad_width,mode='constant').astype(dtype)


    # only need to generate one CTF, since it will be applied to the
    # sub-images after they are extracted from the reconstructed image
    # spectrum, and thus will not move around (relative to the sub-image).
    CTF = (kx_g_sub**2 + ky_g_sub**2) < kt_max_rec**2

    # define convergence tolerance:
    for iters in range(iterations):
        print("Iteration: " + str(iters))
        for i in range(arraysize):       # one per row of LEDs
            for j in range(arraysize):   # one per column of LEDs
                kx_center = np.round((kx_list[j] + kt_max_rec)/2/kt_max_rec*(n_r - 1)) + 1
                ky_center = np.round((ky_list[i] + kt_max_rec)/2/kt_max_rec*(m_r - 1)) + 1
                kx_low = np.round(kx_center - (n_s)/2)
                kx_high = np.round(kx_center + (n_s)/2)
                ky_low = np.round(ky_center - (m_s)/2)
                ky_high = np.round(ky_center + (m_s)/2)
                # extract piece of spectrum
                kx = np.array([np.arange(int(kx_low),int(kx_high))],dtype=int)
                ky = np.array([np.arange(int(ky_low),int(ky_high))],dtype=int)

                pieceFT = objectFT[ky.T,kx]
                #apply CTF and digital correction
                pieceFT_constrained= (m_s/m_r)**2 * np.multiply(pieceFT,CTF)
                # iFFT
                piece = ifftn(ifftshift(pieceFT_constrained))
                # Replace intensity with intensity of sampled Images
                piece_replaced = (m_r/m_s)**2 * np.sqrt(np.abs(Images[i,j]))*np.exp(1j*np.angle(piece))
                # FFT
                piece_replacedFT=fftshift(fftn(piece_replaced))*CTF
                # place updated intensity back into frequency space object
                #objectFT[ky.T,kx] += piece_replacedFT
                objectFT[ky.T,kx] = piece_replacedFT+pieceFT-pieceFT_constrained
    # compute reconstructed object
    object = ifftn(ifftshift(objectFT))
    return object,objectFT
