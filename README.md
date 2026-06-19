# Digital-Ear
This project aims to emulate the functions of the human ear using MATLAB code, done in several stages. A description of the stages are as below. 

The first stage
1. Calculates the resonant frequency, quality factor, bandwidth, and coefficients of an audio sample.
2. Calculates the coefficients for 128 IIR Filters.
3. Derives FIR filters from the IIR Filters, forming the first 'analysis' filters. This is used to create synthesis filters which are then convoluted together.
4. Filters are used to filter speech data and produce synthesized speech.

The second stage
1. Create a spectral analysis system by first calculating the gain factor for each filter, then calculating the spatial differentiation (represents coupling of cilia and inner hair cells).
2. Simulate inner hair cells using the above, the output of which is electrical energy.

The third stage
1. Use temporal masking methods for efficiency. First rectify the filtered data (stage 1), and determine which peaks would not be heard – which ones would be masked.
2. Synthesize and compare audio samples using the filters and temporal modules created. 



Created for the course ELEC3104 | Digital Signal Processing
