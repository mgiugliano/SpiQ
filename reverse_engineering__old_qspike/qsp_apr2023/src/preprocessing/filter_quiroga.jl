using DSP
using Statistics # median method is in this library

"""
	filter_quiroga(data::Array{Float64, 1}, detect_fmin::Float64, detect_fmax::Float64, sort_fmin::Float64, sort_fmax::Float64, stdmin::Int, stdmax::Int, sr::Int) 
		-> xf::Array{Float64, 1}, xf_detect::Array{Float64, 1}, noise_std_detect::Float64, noise_std_sorted::Float64, thr::Float64, thrmax::Float64

Perform a causal filtering on the raw data based on DSP functions filtfilt() and Elliptic(). 

Script derived from the Quiroga's package Wave_clus, to perform band-pass zero-phase digital filtering. 
Uses a Band-pass elliptic filter, fourth order, between fmin and fmax,  0.1 dB of ripple in the passband, and 
a stopband 40 dB down from  the peak value in the passband.

### Arguments
- `data::Array{Float64, 1}` : raw data.
- `detect_fmin::Float64` : high pass filter for detection.
- `detect_fmax::Float64` : low pass filter for detection.
- `sort_fmin::Float64` : high pass filter for sorting.
- `sort_fmax::Float64` : low pass filter for sorting.
- `stdmin::Int` : minimum threshold for detection.
- `stdmax::Int` : maximum threshold for detection.
- `sr::Int` : sampling rate (Hz).

### Return
- `xf::Array{Float64,1}` : band-pass filtered data vector, used in spike-sorting.
- `xf_detect::Array{Float64,1}` : band-pass filtered data vector, used in spike-detection.
- `noise_std_detect::Float64` : noise standard deviation, used in spike-detection (See Quiroga).
- `noise_std_sorted::Float64` : noise standard deviation, used in spike-sorting (See Quiroga).
- `thr::Float64` : minimum threshold for detection (See Quiroga).
- `thrmax::Float64` : maximum threshold for detection (See Quiroga).

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com
"""


function filter_quiroga(data::Array{Float64,1}, detect_fmin::Float64, detect_fmax::Float64, sort_fmin::Float64, 
	sort_fmax::Float64, stdmin::Int, stdmax::Int, sr::Int)

	fmin = sort_fmin *2/sr;
	fmax = sort_fmax *2/sr;
	fmin_detect = detect_fmin *2/sr;
	fmax_detect = detect_fmax *2/sr;

	myfilter = digitalfilter(Bandpass(fmin,fmax),Elliptic(2, 0.1, 40))
	myfilter_detect = digitalfilter(Bandpass(fmin_detect,fmax_detect),Elliptic(2, 0.1, 40))
	xf = filtfilt(myfilter, data);
	xf_detect = filtfilt(myfilter_detect, data);

	lx = length(xf); # Number of data point of the filtered data.

	# The threshold for event detection is now computed, based on the settings
	# (i.e., minimal and maximal threshold) and on the basis of the median of the filtered data.

	noise_std_detect = median(abs.(xf_detect))/0.6745; # Julia does not automatically apply scalar functions, like abs, to elements of an array. 
	                                                   # You should instead tell Julia this is what you want, and broadcast the scalar function abs
	noise_std_sorted = median(abs.(xf))/0.6745;        # or you can use "dot-notation", which is more ideomatic
	thr              = stdmin * noise_std_detect;
	thrmax           = stdmax * noise_std_sorted;

	return xf, xf_detect, noise_std_detect, noise_std_sorted, thr, thrmax
end