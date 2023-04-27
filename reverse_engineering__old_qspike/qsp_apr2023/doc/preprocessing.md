# Scripts

## main_preprocess
Script that launches the preprocessing of the raw data. The preprocessed data will be saved in .jld2 files.
The preprocessing will run in parallel using all the availables CPU cores.

### Arguments
- `outdir::String` : general path were the preprocessed data will be saved.
- `name::String` : stream name.
- `nSamples::Int` : number of samples of the stream.
- `sr::Int` : sampling rate (Hz).
- `nElec::Int` : number of elec channels.
- `channelsElec::Array{String, 1}` : names of the elec channels.
- `nDigi::Int` : number of digi channels.
- `channelsDigi::Array{String, 1}` : names of the digi channels.
- `nAnlg::Int` : number of anlg channels.
- `channelsDigi::Array{String, 1}` : names of the anlg channels.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com

# Functions

## processchanMG
	processchanMG(paramsPath::String, channel::String, type::String, path::String, ofname::String, Nsamples::Int, sr::Int)

Perform the basic preprocessing of binary data file extracted from the .mcd file. It consist in a causal filtering 
of the data, locating spikes in the datastream, and storing the individual spikes for each channel. The preprocessing
is performedfor one channel at a time and stores all detected spikes in a .jld2 file which is later on used for further 
processing and analyses.

### Arguments
- `paramsPath::String` : path to the parameters file.
- `channel::String` : channel name.
- `type::String` : channel type.
- `path::String` : full outputh path.
- `ofname::String` : full input file name.
- `NSamples::Int` : number of samples of the stream.
- `sr::Int` : sampling rate (Hz).

### Examples
```jldoctest
julia> processchanMG("..", "47", "elec", "data/OUTPUT_PREPROCESSED_FILES", "data/OUTPUT_PREPROCESSED_FILES/trace1/trace1_elec_47.dat", 200000, 10000)
```

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com


## read_bin
	read_bin(filename::String, N::Int) -> data::Array{Float64,1}

Read the binary data from an elec channel .dat file and returns it as a Julia vector.

### Arguments
- `filename::String` : full input file name.
- `N::Int` : number of samples of the file.

### Return
- `data::Array{Float64,1}` : vector with the data read from the file.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com


## read_bin_digi
	read_bin_digi(filename::String, N::Int) -> data::Array{Float64,1}

Read the binary data from a digi channel .dat file and returns it as a Julia vector.

### Arguments
- `filename::String` : full input file name.
- `N::Int` : number of samples of the file.

### Return
- `data::Array{Float64,1}` : vector with the data read from the file.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com


## filter_quiroga
	filter_quiroga(data::Array{Float64, 1}, detect_fmin::Float64, detect_fmax::Float64, sort_fmin::Float64, sort_fmax::Float64, stdmin::Int, stdmax::Int, sr::Int)
	
	-> xf::Array{Float64, 1}, xf_detect::Array{Float64, 1}, noise_std_detect::Float64, noise_std_sorted::Float64, thr::Float64, thrmax::Float64

Perform a causal filtering on the raw data based on DSP functions filtfilt() and Elliptic(). 

Script derived from the Quiroga's package Wave_clus, to perform band-pass zero-phase digital filtering. Uses a band-pass elliptic filter, fourth order, between fmin and fmax,  0.1 dB of ripple in the passband, and a stopband 40 dB down from  the peak value in the passband.

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


## locate_spikes_quiroga
	locate_spikes_quiroga(xf::Array{Float64, 1}, xf_detect::Array{Float64, 1}, thr::Float64, w_pre::Int, w_post::Int, ref::Float64, detect::String) 

	-> idx::Array{Int64, 1}, nspk::Int

Detect individual spike times.

Script derived from the Quiroga's package Wave_clus.

### Arguments
- `xf::Array{Float64, 1}` : band-pass filtered data vector, used in spike-sorting.
- `xf_detect::Array{Float64, 1}` : band-pass filtered data vector, used in spike-detection.
- `thr::Float64` : minimum threshold for detection (See Quiroga).
- `w_pre::Int` : number of pre-event data points stored.
- `w_post::Int` : number of post-event data points stored.
- `ref::Float64` : detector dead time (in ms).
- `detect::String` : type of threshold ("neg", "pos", "both").

### Return
- `idx::Array{Int64, 1}` : indices of the detected spikes.
- `nspk::Int` : number of spikes detected.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com


## spike_storing
	spike_storing(xf::Array{Float64, 1}, xf_detect::Array{Float64, 1}, idx::Array{Int64, 1}, w_pre::Int, w_post::Int, nspk::Int, int_factor::Int, thrmax::Float64, interpolation::String, detect::String)
		
	-> spikes::Array{Float64, 2}, xf_enlarged::Array{Float64, 1}

Store the detected waveforms from each electrode in a raw format with a predefined waveform size specified in the parameters file.

Script derived from the Quiroga's package Wave_clus.

### Arguments
- `xf::Array{Float64, 1}` : band-pass filtered data vector, used in spike-sorting.
- `xf_detect::Array{Float64, 1}` : band-pass filtered data vector, used in spike-detection.
- `idx::Array{Int64, 1}` : indices of the detected spikes.
- `w_pre::Int` : number of pre-event data points stored.
- `w_post::Int` : number of post-event data points stored.
- `nspk::Int` : number of spikes detected.
- `int_factor::Int` : interpolation factor.
- `thrmax::Float64` : maximum threshold for detection (See Quiroga).
- `interpolation::String` : interpolation with cubic splines ("n","y").
- `detect::String` : type of threshold ("neg", "pos", "both").

### Return
- `spikes::Array{Float64, 2}` : matrix with the waveforms of the detected spikes (one spike per row).
- `xf_enlarged::Array{Float64, 1}` : enlarged `xf` to avoid final trimming problems.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com 
