"""
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
"""

function burst_analysis_mm(spikesInfo::Array{Float64, 2}, info::INFO)
	##################################### 1. Settings #####################################

	BURST_BIN       = 25.;  # 25 ms - bin size to detect the bursts
	PELT_FACTOR     = 0.05; # define start and stop bin as 5% of the peak ampl.

	TRUNK_RECORDING_AFTER = info.T;

	PRECISE_LIMITS  = 0;    # set anything but 0 to have a sub-ms precision
	                        # but watch out: it gets extremely slow and useless!!

	SN_RATIO_THRESHOLD = 0; # when events are > than X time the recurrent
							# activity*active channels -> this is a burst
							# if 0, a fixed BURST_THRESHOLD will be used.

	BURST_THRESHOLD    = 100;  # fixed threshold on every recording
	FORCE_MINIMUM_TH   = 100;  # if dynamic threshold is < than X, set X.

	PLOT         = 1; # set anything but 0 to plot some data (useful to debug)
	SHOW_SUMMARY = 0; # set anything but 0 to show a summary at the end

	#######################################################################################

	bursts = BURSTS(0, [], 0, 0, [], 0, 0, [], [], [], 0, 0, 0, Array{Float64,2}(undef, 0, 0), 0, 0, 0);

	RECORDING_BIN = 1000.0 / info.sr; # millisec

	if isempty(spikesInfo[:,1])
	    println("No spikes found,... we stop here.");
	    return bursts;
	end   
	

	###################### 2. Creating and filling the raster_matrix ######################

	rows = length(unique!(abs.(spikesInfo[:,3]))); # Number of channels
	cols = length(0:RECORDING_BIN:TRUNK_RECORDING_AFTER); # ms of recording

	channelsIdx = unique!(abs.(spikesInfo[:,3])); # Indexes of channels


	# The number of active electrodes must be at least a sixth part of the total
	if info.nActiveElectrodes <= length(rows) / 6
	    println("No active electrodes,... we stop here.");
	    return bursts;
	end
	
	raster_matrix = falses(rows, cols);

	@printf "Allocated raster matrix: %d rows, %d columns\n" rows cols

	for i in 1:length(spikesInfo[:, 1]) # For each spike

		# Get channel index in the raster
		chIdx = findall(x->x==abs(spikesInfo[i, 3]), channelsIdx)[1]

	    # Set the raster to true in the time where there was a spike
	    # MATLAB Int(x) does not trunc but round
	    raster_matrix[Int(chIdx), round(Int, spikesInfo[i, 1] / RECORDING_BIN)] = true;
	end

	@printf "Raster matrix filled\n"


	################### 3. Creating a pelt_matrix for the raster_matrix ###################
	# Second matrix with 4 rows and length(0:BURST_BIN:TRUNK_RECORDING_AFTER) cols
	# row1: active channels in a BURST_BIN sliding window [BURST_BIN*(i-1):BURST_BIN/2*i]
	# row2: idem but with number of spikes
	# row3: row1*row2
	# row4: detect if is a peak or not (is used in the peak detection)

	pelt_cols = length(0:BURST_BIN:TRUNK_RECORDING_AFTER);
	pelt_matrix = zeros(4, pelt_cols);

	for i in 1:pelt_cols-1
	    start_time = (i-1) * BURST_BIN; # time in ms
	    stop_time = i * BURST_BIN;
	    
	    # Find the equivalent in raster_matrix index
	    start_raster_i = round(Int, start_time / RECORDING_BIN);
	    if start_raster_i < 1
	        start_raster_i = 1;
	    end
	    
	    stop_raster_i = round(Int, stop_time / RECORDING_BIN);
	    if stop_raster_i > cols
	        stop_raster_i = cols;
	    end
	    
	    t_raster_matrix = sum(raster_matrix[:, start_raster_i:stop_raster_i], dims=2);
	    pelt_matrix[1, i] = length(findall(t_raster_matrix .!= 0));
	    pelt_matrix[2, i] = sum(t_raster_matrix);
	    pelt_matrix[3, i] = pelt_matrix[1, i] * pelt_matrix[2, i];
	end

	if SN_RATIO_THRESHOLD != 0 # !! I think this must be SN_RATIO_THRESHOLD and not BURST_THRESHOLD
	    BURST_THRESHOLD = SN_RATIO_THRESHOLD * mean(pelt_matrix[1,:]) * mean(pelt_matrix[2,:]);
	    if BURST_THRESHOLD < FORCE_MINIMUM_TH
	        BURST_THRESHOLD = FORCE_MINIMUM_TH;
	    end
	end


	if PLOT != 0
		plt.clf();
		# PyPlot starts plotting from index 0 but our vector indexes start at 1
	    plt.plot(1:length(pelt_matrix[3,:]), pelt_matrix[3,:], label="active chan * events/bin")
	    plt.plot(1:length(pelt_matrix[1,:]), pelt_matrix[1,:], "ro", label="active chan")
	    plt.plot(1:length(pelt_matrix[2,:]), pelt_matrix[2,:], "gx", label="events")
	    #plt.show()
	end

	######################## 4. Detecting peaks in the pelt matrix ########################
	# Def: a peak is the max(row3) > BURST_THRESHOLD between two points
	# <= PELT_FACTOR*max(row3)

	# pelt_burst_i is a vector with burst_n elements, that also are vector with 3 elements
	# !! OLD: is a matrix with #burst lines and 3 columns
	# column 1: pelt_matrix index for the left limit
	# column 2: pelt_matrix index for the peak
	# column 3: pelt_matrix index for the right limit

	DDD = round(300.0 / BURST_BIN, RoundToZero);
	@printf "Detecting burst peaks...\n";
	burst_n = 0;
	pelt_burst_i = [];
	i = 1;

	while i < pelt_cols
	    if (pelt_matrix[1, i] >= (info.nActiveElectrodes / 4.0))
	        burst_n += 1;
	        
	        tmp_peak_i = i+1;
	        tmp_peak_v = pelt_matrix[1, i];
	        
	        while (pelt_matrix[1, tmp_peak_i] > tmp_peak_v) & (tmp_peak_i < pelt_cols)
	            tmp_peak_v = pelt_matrix[1, tmp_peak_i];
	            tmp_peak_i = tmp_peak_i + 1;
	        end

	        pelt_peak_i = Int(tmp_peak_i - 1);
	        
	        pelt_left_i = Int(max(1, pelt_peak_i - DDD));
	        pelt_right_i = Int(min(pelt_peak_i + DDD, pelt_cols));
	        
	        push!(pelt_burst_i, [pelt_left_i pelt_peak_i pelt_right_i]);
	        
	        i = pelt_right_i + round(Int, DDD/2, RoundToZero);
	    else
	        i += 1;
	    end
	end
	    
	if burst_n == 0
	    println("No burst found,... we stop here.");
	    return bursts;
	end


	for i in 1:burst_n
	    peak_i = pelt_burst_i[i][2];
	    threshold = PELT_FACTOR * pelt_matrix[3, peak_i];
	    
	    ti = peak_i-1;
	    if ti <= 1
	        ti = 1;
	    end
	    while (pelt_matrix[3, ti] > threshold) & (ti > 1)
	        ti -= 1;
	    end
	    pelt_left_i = ti;
	    #-------------------------------------------------
	    ti = peak_i+1;
	    if ti >= pelt_cols
	        ti = pelt_cols;
	    end
	    while (pelt_matrix[3, ti] > threshold) & (ti < pelt_cols)
	        ti += 1;
	    end
	    pelt_right_i = ti;
	    #--------------------------------------------------
	    pelt_burst_i[i][1] = pelt_left_i;
	    pelt_burst_i[i][3] = pelt_right_i;
	end

	@printf "Done\n"

	#println(pelt_burst_i[1:end])
	    
	if PLOT != 0
	    #plt.plot(pelt_matrix[3,:], label="active chan * events/bin")
	    #plt.plot(pelt_matrix[1,:], "ro", label="active chan")
	    #plt.plot(pelt_matrix[2,:], "gx", label="events")
	    plt.vlines(getindex.(pelt_burst_i, 1), 0, 1000, colors="cyan")
	    plt.vlines(getindex.(pelt_burst_i, 2), 0, 1000, colors="magenta")
	    plt.vlines(getindex.(pelt_burst_i, 3), 0, 1000, colors="yellow")

	    if (length(pelt_matrix[3,:]) > 1000)
	    	plt.xlim(0, 1000);
	    end

	    plt.savefig(string(info.outpath, "burst_detail.pdf"));
	end
	    
	############### 5. Convert pelt_matrix indices in raster_matrix indices ################
	# now we have pelt_burst_i with the index of pelt_matrix_indices for every
	# burst: [left, peak, right]

	# left has to be converted in the left index in the raster_bin
	# peak => center
	# right => right

	len_pelt_burst = length(pelt_burst_i);
	raster_burst_i = Array{Int}(undef, len_pelt_burst, 3);

	raster_burst_i[:,1] = (getindex.(pelt_burst_i, 1) .- 1) .* Int(BURST_BIN / RECORDING_BIN) .+ 1;
	raster_burst_i[:,2] = (getindex.(pelt_burst_i, 2) .- 1) .* Int(BURST_BIN / RECORDING_BIN) .+ round(0.5 * BURST_BIN / RECORDING_BIN);
	raster_burst_i[:,3] = (getindex.(pelt_burst_i, 3) .- 1) .* Int(BURST_BIN / RECORDING_BIN) .+ round(BURST_BIN / RECORDING_BIN);

	# if an index is bigger than cols,... set it to cols
	raster_burst_i[raster_burst_i[:,1] .> cols, 1] .= cols;
	raster_burst_i[raster_burst_i[:,2] .> cols, 2] .= cols;
	raster_burst_i[raster_burst_i[:,3] .> cols, 3] .= cols;

	######################### 6. Detecting the real burst limits ###########################

	t_lefts = zeros(len_pelt_burst);
	t_rights = zeros(len_pelt_burst);
	t_peaks = zeros(len_pelt_burst);

	@printf "Detecting burst limits...\n"

	# !! why printbackspace?

	for i in 1:len_pelt_burst
	    
	    # !! print thing in line 363
	    
	    # left 50% limit
	    raster_start_i::Int = raster_burst_i[i, 1];
	    totspikesL = sum(raster_matrix[:, raster_start_i:raster_burst_i[i, 2]]);
	    totspikesLL = totspikesL;
	    
	    while (totspikesLL >= 0.5*totspikesL) & (totspikesL != 0) & (raster_start_i < raster_burst_i[i, 2])
	        if PRECISE_LIMITS != 0 
	            raster_start_i += 1; # add RECORDING_BIN every step !! RECORDING_BIN or 1?
	        else
	            raster_start_i += (1 / RECORDING_BIN); # add 1 ms every step
	        end
				
			if (raster_start_i >= raster_burst_i[i, 2])
				raster_start_i = raster_burst_i[i, 2];
			end
			
			totspikesLL = sum(raster_matrix[:, raster_start_i:raster_burst_i[i, 2]]);
		end
		
		if totspikesL == 0
			raster_start_i = raster_burst_i[i, 2];
		end
		
		#right 50% limit
		raster_stop_i::Int = raster_burst_i[i, 2];
		totspikesR = sum(raster_matrix[:, raster_stop_i:raster_burst_i[i, 3]]);
		totspikesRR = totspikesR;
		
		while (totspikesRR >= 0.5*totspikesR) & (totspikesR != 0) & (raster_stop_i < raster_burst_i[i, 3])
			if PRECISE_LIMITS != 0 
				raster_stop_i += 1; # add RECORDING_BIN every step !! RECORDING_BIN or 1?
			else
				raster_stop_i += (1 / RECORDING_BIN); # add 1 ms every step
			end
			
			if (raster_stop_i >= raster_burst_i[i, 3])
				raster_stop_i = raster_burst_i[i, 3];
			end
			
			totspikesRR = sum(raster_matrix[:, raster_stop_i:raster_burst_i[i, 3]]);
		end
		
		if totspikesR == 0
			raster_stop_i = raster_burst_i[i, 2];
		end
		
		# 50% borders
		t_lefts[i] = raster_start_i * RECORDING_BIN;
		t_peaks[i] = raster_burst_i[i, 2] * RECORDING_BIN;
		t_rights[i] = raster_stop_i * RECORDING_BIN;
		
		# !! fix the left and right borders by duplicating the distance between border and peak
		t_lefts[i] -= (t_peaks[i] - t_lefts[i]);
		t_rights[i] += (t_rights[i] - t_peaks[i]);
	end

	# !! again the print_backspace thing

	# !! I think this can be done in the big loop
	#=
	# fix the left and right borders by duplicating the distance between border and peak
	for i in 1:len_pelt_burst
		t_lefts[i] -= (t_peaks[i] - t_lefts[i]);
		t_rights[i] += (t_rights[i] - t_peaks[i]);
	end
	=#
				
	@printf "Done\n"
			
			
	########## Mufti code ########
	# this will create a matrix to store the bursts with events across all electrodes

	left_max = maximum(raster_burst_i[:, 2] - raster_burst_i[:, 1]);
	right_max = maximum(raster_burst_i[:, 3] - raster_burst_i[:, 2]);
	max_distance = left_max + right_max;
	mid_ind = Int(ceil(max_distance / 2));

	if left_max > mid_ind
		max_distance += (left_max + 1 - mid_ind) * 2;
		mid_ind = Int(ceil(max_distance / 2));
	end

	if right_max > mid_ind
		max_distance += (right_max + 1 - mid_ind) * 2;
		mid_ind = Int(ceil(max_distance / 2));
	end

	max_distance = Int(ceil(max_distance)); # Has to be an integer

	bursts_across_electrodes = zeros(len_pelt_burst, max_distance); # !! not used
	t = LinRange(0, max_distance*RECORDING_BIN, max_distance); # !! not used

	burst_in_electrodes = zeros(rows, max_distance);
	psth_bin = 10;
	#edges = 0:psth_bin:max_distance*RECORDING_BIN;
	edges = 0:psth_bin:(max_distance*RECORDING_BIN) + psth_bin; # !! MATLAB includes the last edge as a last bin, but Julia doesn't so we need to force it
	new_pelt_matrix = zeros(rows, length(edges)-1, burst_n); # !! maybe length(edges)-1 so then it fits with the weights of the hist


	for xx in 1:rows
		for bur in 1:burst_n
			temp_bursts_in_electrodes = zeros(1, max_distance);
			norm_ind = raster_burst_i[bur, :] .- raster_burst_i[bur, 1]; # !! almost always are the same values

			if norm_ind[3] > max_distance
				norm_ind[3] = max_distance;
			end

			offset_ind = mid_ind - norm_ind[2];


			new_ind = norm_ind .+ offset_ind;

			temp_bursts_in_electrodes[new_ind[1] + 1:new_ind[3]] = raster_matrix[xx, raster_burst_i[bur, 1] + 1:raster_burst_i[bur, 3]];
			new_pelt_matrix[xx, :, bur] = fit(Histogram, getindex.(findall(temp_bursts_in_electrodes .> 0), 2) .* RECORDING_BIN, edges).weights;
		end
	end


	edges = 0:psth_bin:max_distance*RECORDING_BIN; # !! For the plot
	plot_pelt_matrix(new_pelt_matrix, edges, info.outpath);
	

	############################# 7. Saving burst information ##############################

	bursts.Nburst 	  = length(t_peaks);
	bursts.DUR        = t_rights - t_lefts;
	bursts.meanDUR    = mean(t_rights - t_lefts);
	bursts.stdDUR     = std(t_rights - t_lefts);
	bursts.IBI        = t_rights[2:end] - t_lefts[1:end-1];
	bursts.meanIBI    = mean(t_rights[2:end] - t_lefts[1:end-1]);
	bursts.stdIBI     = std(t_rights[2:end] - t_lefts[1:end-1]);
	bursts.tpeaks     = t_peaks;
	bursts.trights    = t_rights;
	bursts.tlefts     = t_lefts;
	bursts.Tdur       = TRUNK_RECORDING_AFTER;
	bursts.Nspikes	  = length(spikesInfo[:, 1]);
	bursts.TH         = BURST_THRESHOLD;
	bursts.pelt_matrix = pelt_matrix;
	bursts.burst_detect_bin = BURST_BIN;
	
	println("Number of bursts: ", bursts.Nburst);
	println("Average duration: ", bursts.meanDUR);
				
	return bursts; 
end