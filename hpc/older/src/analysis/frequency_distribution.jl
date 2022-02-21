"""
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
"""

function frequency_distribution(spikesInfo::Array{Float64, 2}, info::INFO)
	######## Settings ########
	TRUNCATE_AFTER = 30*60*1000; # [ms] truncate spikes, 0 to not truncate

	SET_X_AXIS_LOG   = 1;        # set 1 to plot w/ log-x

	SET_X_AXIS_STEPS = 20;       # histogram intervals on x axis
	LOWER_DISTANCE   = 0.1;      # [ms] lower considered interval 
	UPPER_DISTANCE   = 5000;     # [ms] upper considered interval 

	NORMALIZE_COUNT  = 1;        # set 1 for yes
	Y_LIMIT          = 1;
	LABELS_EVERY_COL = 1;

	######## Variables ########
	numberChannels = length(spikesInfo[:,1]);

	if TRUNCATE_AFTER != 0
		spikesTimes = filter(x -> x .<= TRUNCATE_AFTER, spikesInfo[:,1]);
	else
		spikesTimes = spikesInfo[:,1];
	end
	
	######## Processing ########

	# Discard those repeated
	unique!(spikesTimes);

	# Sort them
	sort!(spikesTimes);

	# Get the ISIs
	dist = diff(spikesTimes);

	# Get the maximum ISI and round it at upper 10th
	maximal_distance = round(maximum(dist) / 10) * 10;

	# Calculate the x-scale values
	if SET_X_AXIS_LOG == 1
		e_scale = log10(LOWER_DISTANCE):(log10(UPPER_DISTANCE)-log10(LOWER_DISTANCE))/SET_X_AXIS_STEPS:log10(UPPER_DISTANCE);
	    x_scale = zeros(1, length(e_scale));
		
		for i in 1:length(e_scale)
			x_scale[i] = 10^e_scale[i];
		end
	else
		x_scale = LOWER_DISTANCE:(UPPER_DISTANCE-LOWER_DISTANCE)/SET_X_AXIS_STEPS:UPPER_DISTANCE;
	end

	# Calculate the y-scale values
	y_value = zeros(1, length(x_scale)-1);
	for i in 1:length(x_scale)-1
		y_value[i] = length(findall((dist .>= x_scale[i]) .& (dist .< x_scale[i+1])));
	end

	plt.clf();
	plt.figure(figsize=(12,8));
		
	# If we want to normalize the graph
	if NORMALIZE_COUNT == 1
		auxSum = sum(y_value);
		y_value = y_value ./ auxSum;
		plt.ylabel("Normalized interspikes number", fontsize=18);
	else
		plt.ylabel("Interspikes number", fontsize=18);
	end

	# Plot
	for i in 1:length(x_scale)-1
		plt.bar(i-0.5, y_value[i], color=:black);
	end

	labels = []
	for i in 1:length(x_scale)
		push!(labels, @sprintf("%2.2f", x_scale[i]));
	end

	plt.xticks(0:length(x_scale)-1, labels, rotation=90);

	plt.xlabel("Interval [ms]", fontsize=18);
	plt.title(string("Interspike interval distribution [", LOWER_DISTANCE, " ms; ", UPPER_DISTANCE, " ms]"), fontsize=20);

	plt.tight_layout();
	plt.savefig(string(info.outpath, "frequency_distribution.pdf"), format="pdf");
end