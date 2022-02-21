using Printf, JLD2, FileIO, SparseArrays

include("read_bin.jl")
include("read_bin_digi.jl")
include("filter_quiroga.jl")
include("locate_spikes_quiroga.jl")
include("spike_storing.jl")

"""
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
"""

function processchanMG(paramsPath::String, channel::String, type::String, path::String, ofname::String, Nsamples::Int, sr::Int)
	delete_dat_files = 0; # if set to 1, removes automatically the binary files


	# Read the parameters from "parameters.txt" ##################################################
	fp = open(@sprintf "%s/parameters.txt" paramsPath);
	lines = readlines(fp);

	detect_fmin = parse(Float64, lines[1]); 	# high pass filter for detection
	detect_fmax = parse(Float64, lines[2]); 	# low pass filter for detection (default 1000)
	sort_fmin   = parse(Float64, lines[3]); 	# high pass filter for sorting
	sort_fmax   = parse(Float64, lines[4]); 	# low pass filter for sorting (default 3000)
	stdmin      = parse(Int, lines[5]); 		# minimum threshold for detection
	stdmax      = parse(Int, lines[6]); 		# maximum threshold for detection
	detect      = lines[7]; 					# type of threshold ("neg", "pos", "both")
	w_pre       = parse(Int, lines[8]); 		# number of pre-event data points stored (default 20)
	w_post      = parse(Int, lines[9]); 		# number of post-event data points stored (default 44)
	ref         = parse(Float64, lines[10]); 	# detector dead time (in ms)
	int_factor  = parse(Int, lines[11]); 		# interpolation factor
	interpolation = lines[12]; 					# interpolation with cubic splines ("n","y")
	savingxf    = lines[13]; 					# saving xf files? ("n","y")
	filterxf    = lines[14]; 					# filter the data or not at all? ("n","y")
	    
	close(fp);

	ref = ref * sr * 1e-3; # spike detector dead time in #samples (see above)
	###############################################################################################

	if type == "elec"
		println("processchanMG: Importing channel ", ofname, " into Julia...");
		data = read_bin(ofname, Nsamples); # !!what is 6000000? something of the channel, it is different for each, i'm replacing it with Nsamples which was unused
		println("Done!");

		xf, xf_detect, noise_std_detect, noise_std_sorted, thr, thrmax = filter_quiroga(data, detect_fmin, detect_fmax, sort_fmin, sort_fmax, stdmin, stdmax, sr);

		idx, nspk = locate_spikes_quiroga(xf, xf_detect, thr, w_pre, w_post, ref, detect);
		spikes, xf_enlarged = spike_storing(xf, xf_detect, idx, w_pre, w_post, nspk, int_factor, thrmax, interpolation, detect);
		idx = idx .* 1e3 ./ sr; # Convert the spike times in msec (from # sample)

		#file_to_cluster = @sprintf "%s_spikes.jld2" ofname[1:end-4]
		file_to_cluster = @sprintf "%s/%s_spikes.jld2" path channel; # !!
		println("processchanMG: Saving spikes waveforms to ", file_to_cluster);

		@save file_to_cluster spikes idx noise_std_detect noise_std_sorted thr thrmax
		println("processchanMG: Done!")

		if savingxf != "n"
		    #xffname = @sprintf "%s_xf.jld2" ofname[1:end-4];
		    xffname = @sprintf "%s/%s_xf.jld2" path channel; # !!
		    println("processchanMG: Saving filtered data to ", xffname);
		    @save xffname "xf_enlarged";
		    println("processchanMG: Done!");
		end

		xf = nothing;
		xf_detect = nothing;
		xf_enlarged = nothing;

		if delete_dat_files == 1
		    println("processchanMG: Deleting the raw data from the disk");
		    rm(ofname);
		    println("processchanMG: Done!");
		end
	elseif type == "digi"
		# processing signals from digital
		println("processchanMG: Importing channel ", ofname, " into Julia...");
		data = read_bin_digi(ofname, Nsamples); # !!what is 6000000? something of the channel, it is different for each, i'm replacing it with Nsamples which was unused
		println("Done!");
		file_to_cluster = @sprintf "%s/%s_stimuli.jld2" path channel;

		println("processchanMG: Saving stimuli to ", file_to_cluster);
		stim_value = sparse(data)
		@save file_to_cluster sr stim_value;
		println("Done!");

		data = nothing;
		stim_value = nothing;

		if delete_dat_files == 1
		    rm(ofname);
		end
	end
end