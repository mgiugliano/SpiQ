# Scripts

## main_analysis
Script that launches the analysis of the preprocessed data. Several figures and a .tex file will be generated with the results.

### Arguments
- `preprocessedTag::String` : general path that contains the preprocessed data.
- `processedTag::String` : general path were the results of the analysis will be saved.
- `expName::String` : stream name.

### Examples
```jldoctest
julia --project=../Project.toml main_analysis.jl "data/OUTPUT_PREPROCESSED_FILES" "data/OUTPUT_PROCESSED_FILES" "trace1"
```

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com


# Data structures
### INFO
- `prepath::String` : preprocessed files path.               
- `outpath::String` : output files path.               
- `expName::String` : recording name.			   
- `T::Float64` : recording duration (ms).                    
- `Ns::Int` : number of samples of the recording.
- `sr::Int` : recording sampling rate (Hz).
- `nActiveElectrodes::Int` : number of active electrodes.


### BURSTS
- `Nburst::UInt` : number of bursts.
- `DUR::Vector{Float64}` : duration of each burst.
- `meanDUR::Float64` : mean duration of the bursts.
- `stdDUR::Float64` : standard deviation of the duration of the bursts.
- `IBI::Vector{Float64}` : interbursts intervals.
- `meanIBI::Float64` : mean interbursts intervals.
- `stdIBI::Float64` : standard deviation of the interbursts intervals.
- `tpeaks::Vector{Float64}` : times of the bursts peaks.
- `trights::Vector{Float64}` : times of the bursts right edges.
- `tlefts::Vector{Float64}` : times of the bursts left edges.
- `Tdur::Float64` : time after which the recording is truncated (ms).
- `Nspikes::UInt` : total number of spikes detected.              
- `TH::Float64` : fixed burst threshold.
- `pelt_matrix::Array{Float64, 2}` : Van Pelt matrix.
- `burst_detect_bin::Float64` : bin size to detect the bursts (ms).
- `largest_burst_bin::Float64` : bin size for the largest bursts (ms).
- `largest_burst_bin_zoomed_in::Float64` : bin size for the zoomed largest bursts (ms).


# Functions

## active_electrodes
	active_electrodes(spikesInfo::Array{Float64, 2}, info::INFO)

Calculate the number of electrodes with an average rate of >0.02 Hz, throughout the (recording) session.
Save the result in `info` and makes a plot.

### Arguments
- `spikesInfo::Array{Float64, 2}` : matrix with Nx3 dimensions, being N the number of spikes, and where the columns are:
	- First column is the spike time stamp.
	- Second column is the electrode name. 
	- Third column is the electrode number.
- `info::INFO` : structure that stores the general information of the analysis.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com


## burst_analysis_mm
	burst_analysis_mm(spikesInfo::Array{Float64, 2}, info::INFO) -> bursts::BURSTS

Detect the bursts as per the Burst detection algorithm described in Van Pelt et al., 2004; IEEE Trans. Biomed. Eng., 51(11):2051-62.
Stores the results of the analysis in `bursts` and makes a plot.

### Arguments
- `spikesInfo::Array{Float64, 2}` : matrix with Nx3 dimensions, being N the number of spikes, and where the columns are:
	- First column is the spike time stamp.
	- Second column is the electrode name. 
	- Third column is the electrode number.
- `info::INFO` : structure that stores the general information of the analysis.

### Return
- `bursts::BURSTS` : structure that stores the results of the burst analysis.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com


## closest_factors
	closest_factors(N::Int) -> factors::Array{Int, 2}

Auxiliary method. Finds the pair of factors of an integer `N` that are closer between them.

### Arguments
- `N::Int` : number of which calculate the factors.

### Return
- `factors::Array{Int, 2}` : closest factor of `N`.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com


## frequency_distribution
	frequency_distribution(spikesInfo::Array{Float64, 2}, info::INFO)

Plot a frequency distribution histogram of the spikes activity.

### Arguments
- `spikesInfo::Array{Float64, 2}` : matrix with Nx3 dimensions, being N the number of spikes, and where the columns are:
	- First column is the spike time stamp.
	- Second column is the electrode name. 
	- Third column is the electrode number.
- `info::INFO` : structure that stores the general information of the analysis.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com


## generate_latex_file
	generate_latex_file(info::INFO, bursts::BURSTS)

Generate a latex file for automated report generation at the end of the preprocessing and analysis. 
The generated latex file includes information from activity information file and the figures.

### Arguments
- `info::INFO` : structure that stores the general information of the analysis.
- `bursts::BURSTS` : structure that stores the results of the burst analysis.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com



## improved_plot_waves
	improved_plot_waves(spikesInfo::Array{Any, 2}, info::INFO, channelsNames::Array{String, 1})

Plot the waveforms of activities detected by each electrodes during a recording session. The plotting of negative and positive activities are plotted separately in two subplots with means of the individual waveforms detected by each electrodes.

### Arguments
- `spikesInfo::Array{Any, 2}` : 2D array containing, for each channel (row):
	- Column 1: spikes indices array
	- Column 2: channel name
	- Column 3: channel number
	- Column 4: vector with the waves of each spike found in that channel
- `info::INFO` : structure that stores the general information of the analysis.
- `channelsNames::Array{String, 1}` : auxiliary array that stores the channels names in string format.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com



## info_file
	info_file(preprocessedPath::String, expName::String, info::INFO)

Load the information of the stream stored in the file `preprocessedPath`/`expName`/`expName`_info.txt and save it in `info`.

### Arguments
- `preprocessedPath::String` : general path that contains the preprocessed data.
- `expName::String` : stream name.
- `info::INFO` : structure that stores the general information of the analysis.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com



## largest_burst
	largest_burst(spikesInfo::Array{Float64, 2}, info::INFO, bursts::BURSTS)

Largest_burst calculates the largest population burst present at the recording file. It also plots sample rasters and PSTHs centering the  detected largest burst for 10 seconds and 1 second, as well as the raw trace of the burst.

### Arguments
- `spikesInfo::Array{Float64, 2}` : matrix with Nx3 dimensions, being N the number of spikes, and where the columns are:
	- First column is the spike time stamp.
	- Second column is the electrode name. 
	- Third column is the electrode number.
- `info::INFO` : structure that stores the general information of the analysis.
- `bursts::BURSTS` : structure that stores the results of the burst analysis.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com



## launch_analyses
	launch_analyses(preprocessedTag::String, processedTag::String, expName::String)

Performs an analysis over the preprocessed .jld2 spikes files.

### Arguments
- `preprocessedTag::String` : general path that contains the preprocessed data.
- `processedTag::String` : general path were the results of the analysis will be saved.
- `expName::String` : stream name.

### Examples
```jldoctest
julia> launch_analyses("data/OUTPUT_PREPROCESSED_FILES", "data/OUTPUT_PROCESSED_FILES", "trace1")
```

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com



## plot_pelt_matrix
	plot_pelt_matrix(new_pelt_matrix::Array{Float64, 3}, edges, OUTPATH::String)

Auxiliary method. Plot the burst profile across different electrodes.

### Arguments
- `new_pelt_matrix::Array{Float64, 3}` : a 3D matrix containing
	- 1D: number of electrodes.
	- 2D: event raster during the burst.
	- 3D: bursts.
- `edges` : binned edges of time values.
- `OUTPATH::String` : path of the preprocessed data files.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com



## remove_artifacts
	remove_artifacts(A::Array{Float64, 2}, info::INFO) -> C::Array{Float64, 2}

Remove artifacts from the detected spike time stamps. An artifact is defined as very high number of spikes (50) within a single bin of 3 ms, returning a matrix `C` with the cleaned data.

### Arguments
- `A::Array{Float64, 2}` : matrix with Nx3 dimensions, being N the number of spikes, and where the columns are:
	- First column is the spike time stamp.
	- Second column is the electrode name. 
	- Third column is the electrode number.
- `info::INFO` : structure that stores the general information of the analysis.

### Return
- `C::Array{Float64, 2}` : matrix with Nx3 dimensions, being N the number of spikes, and where the columns are:
	- First column is the spike time stamp.
	- Second column is the electrode name. 
	- Third column is the electrode number.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com



## sample_raster_and_psth
	sample_raster_and_psth(spikesInfo::Array{Float64, 2}, info::INFO)

Plot sample raster and psth of the first 300 seconds.

### Arguments
- `spikesInfo::Array{Float64, 2}` : matrix with Nx3 dimensions, being N the number of spikes, and where the columns are:
	- First column is the spike time stamp.
	- Second column is the electrode name. 
	- Third column is the electrode number.
- `info::INFO` : structure that stores the general information of the analysis.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com



## simple_spike_sorting
	simple_spike_sorting(spikesInfo::Array{Any, 2}, channelsNames::Array{String, 1}) -> A::Array{Float64, 2}

Perform simple spike sorting from the activities detected by the electrodes. Based on the data from \*\_spikes.jld2 files, now stored in spikesInfo, a new matrix `A` is returned. Based on the shape of the spike (positive or negative) a negative sign is added infront of the electrode name and number.

### Arguments
- `spikesInfo::Array{Any, 2}` : 2D array containing, for each channel (row):
	- Column 1: spikes indices array
	- Column 2: channel name
	- Column 3: channel number
	- Column 4: vector with the waves of each spike found in that channel
- `channelsNames::Array{String, 1}` : auxiliary array that stores the channels names in string format.

### Return
- `A::Array{Float64, 2}` : matrix with Nx3 dimensions, being N the number of spikes, and where the columns are:
	- First column is the spike time stamp.
	- Second column is the electrode name. 
	- Third column is the electrode number.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com


## write_global_info_to_text
	write_global_info_to_text(info::INFO, bursts::BURSTS)

Write the global INFO file to the disk as \*\_Activity_Information.txt in the output directory.

### Arguments
- `info::INFO` : structure that stores the general information of the analysis.
- `bursts::BURSTS` : structure that stores the results of the burst analysis.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com 
