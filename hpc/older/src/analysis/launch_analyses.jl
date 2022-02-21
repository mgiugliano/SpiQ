using Printf, JLD2, FileIO, Plots
using StatsBase
using Statistics
using DSP
using PyPlot
const plt = PyPlot

#If not declared as mutable an struct cannot be modified after calling its constructor
mutable struct INFO
	prepath::String                # preprocessed files path
	outpath::String                # output files path
	expName::String 			   # experiment name
    T::Float64                     # recording duration [msec]
    Ns::Int                       # duration in number of samples
    sr::Int                       # sampling rate [Hz]
    nActiveElectrodes::Int        # number of active electrodes
end

mutable struct BURSTS
    Nburst::UInt
    DUR::Vector{Float64}
    meanDUR::Float64
    stdDUR::Float64
    IBI::Vector{Float64}
    meanIBI::Float64
    stdIBI::Float64
    tpeaks::Vector{Float64}
    trights::Vector{Float64}
    tlefts::Vector{Float64}
    Tdur::Float64
    Nspikes::UInt                 # !! this information is not necessary here
    #Nspikes_IB::UInt              # and is never used
    #SPIKES::Vector{Float64}
    TH::Float64
    pelt_matrix::Array{Float64, 2}
    burst_detect_bin::Float64
	largest_burst_bin::Float64
	largest_burst_bin_zoomed_in::Float64
end


include("../preprocessing/read_bin.jl")
include("info_file.jl")
include("simple_spike_sorting.jl")
include("remove_artifacts.jl")
include("active_electrodes.jl")
include("sample_raster_and_psth.jl")
include("frequency_distribution.jl")
include("burst_analysis_mm.jl")
include("plot_pelt_matrix.jl")
include("largest_burst.jl")
include("improved_plot_waves.jl")
include("closest_factors.jl")
include("write_global_info_to_text.jl")
include("generate_latex_file.jl")

"""
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
"""

function launch_analyses(preprocessedTag::String, processedTag::String, expName::String)
	
	# fs is different in Windows and Unix-like systems
	if Sys.iswindows()
	    fs = '\\';
	else
	    fs = '/';
	end
	    
	preprocessedPath = string(preprocessedTag, fs, expName, fs);
	processedPath = string(processedTag, fs, expName, fs);

	# Creates the OUTPUT_PROCESSED_FILES/expName directory if it doesn't exists
	try
	    mkdir(processedPath);
	    println(@sprintf "%s dir created." processedPath);
	catch err
	    println(@sprintf "%s dir already exists. Nothing done." processedPath);
	end

	plt.pygui(false);

	#################################################################
	# Variables

	info = INFO(preprocessedPath, string(processedTag, fs, expName, fs), expName, 0.0, 0, 0, 0);

	#################################################################


	######################################################################################
	        
	channelsFiles = filter!(s->occursin("_spikes.jld2", s) ,readdir(preprocessedPath));
	numberChannels = length(channelsFiles);

	if numberChannels < 1
		println("No *_spikes.jld2 files found in "* preprocessedPath *". Stopping...");
		return;
	end

	spikesInfo = Array{Any}(undef, numberChannels, 4);
	channelsNames = Array{String}(undef, numberChannels);
	# spikesInfo is a Nx4 matrix containing, for each of the N channels:
	#     1: spikes indices array
	#     2: channel name
	#     3: channel number
	#	  4: vector with the waves of each spike found in that channel

	for i in 1:numberChannels
	    channelFile = channelsFiles[i];
	    channelsNames[i] = replace(channelFile, "_spikes.jld2"=>"");

	    # If channel name is an integer just parse it, else use the id
	    channelNumber = try
	    	parse(Int, channelsNames[i]);
	    catch
	    	i;
	    end
	    channelId = i;
	    
	    @load string(preprocessedPath, channelFile) spikes idx noise_std_detect noise_std_sorted thr thrmax;
	    
	    spikesInfo[i, 1] = idx;
		spikesInfo[i, 2] = channelNumber;
		spikesInfo[i, 3] = channelId;
		spikesInfo[i, 4] = spikes;
	end

	err_str = "unknown task";
	try
		println("\nReading information file...")
		err_str = "reading information file";
		info_file(preprocessedPath, expName, info);
		println("Done!");
	
		println("\nPlotting spikes waves...")
		err_str = "plotting spikes waves";
		improved_plot_waves(spikesInfo, info, channelsNames);
		println("Done!");
	
		println("\nStoring spikes information...")
		err_str = "storing spikes information";
		A = simple_spike_sorting(spikesInfo, channelsNames);
		println("Done!");

		spikesInfo[:, 1] .= nothing; # Free this memory space
		spikesInfo[:, 2] .= nothing; # Free this memory space
		spikesInfo[:, 3] .= nothing; # Free this memory space
		spikesInfo[:, 4] .= nothing; # Free this memory space
		spikesInfo = nothing; # Free this memory space
	
		println("\nRemoving artifacts...")
		err_str = "removing artifacts";
		C = remove_artifacts(A, info);
		println("Done!");
	
		println("\nSearching active electrodes...")
		err_str = "searching active electrodes";
		active_electrodes(C, info);
		println("Done!");
	
		println("\nPlotting sample raster and histogram...")
		err_str = "plotting sample raster and histogram";
		sample_raster_and_psth(C, info);
		println("Done!");
	
		println("\nCalculating frequency distribution...")
		err_str = "calculating frequency distribution";
		frequency_distribution(C, info);
		println("Done!");
	
		println("\nPerforming burst analysis...")
		err_str = "performing burst analysis";
		bursts = burst_analysis_mm(C, info);
		println("Done!");
	
		println("\nFinding largest burst...")
		err_str = "finding largest burst";
		largest_burst(C, info, bursts);
		println("Done!");

		write_IBI_to_text(info, bursts);
	
		println("\nWriting global information to file...")
		err_str = "writing global information to file";
		write_global_info_to_text(info, bursts);
		println("Done!");

		write_bursts_firing_rates(info, bursts, C);
		write_general_stat_to_text(info, bursts);

		TrialDataPath = string(processedPath, "/TrialData_$(info.expName).jld2")        
        @save TrialDataPath C info
        
        mypath = string(processedPath, "/channelsNames.jld2")
        @save mypath channelsNames
	
		println("\nGenerating LaTeX file...")
		err_str = "generating LaTeX file";
		generate_latex_file(info, bursts);
		println("Done!");
	catch err
		@error "Error in analysis when "*err_str*": " sprint(showerror, err) stacktrace(catch_backtrace());
		println(stacktrace(catch_backtrace()))

		return;
	end
end