"""
	simple_spike_sorting(spikesInfo::Array{Any, 2}) -> A::Array{Float64, 2}

Perform simple spike sorting from the activities detected by the electrodes. Based on the data from *_spikes.jld2 
files, now stored in spikesInfo, a new matrix `A` is returned. Based on the shape of the spike (positive or negative) 
a negative sign is added infront of the electrode name and number.

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
"""

function simple_spike_sorting(spikesInfo::Array{Any, 2}, channelsNames::Array{String, 1})
	numberChannels = length(spikesInfo[:, 1]);
	totalSpikes = sum(length.(spikesInfo[:,1]));
	A = zeros(totalSpikes, 3);

	offset = 0;
	for i in 1:numberChannels
		indp = [];
		indn = [];
		spikesAux = spikesInfo[:, 4][i];
		nSpikes = size(spikesAux, 1);
		
		#@printf "Found %d spikes in channel %d.\n" nSpikes spikesInfo[:, 2][i]
		@printf "Found %d spikes in channel %s.\n" nSpikes channelsNames[i]
		
		for m in 1:nSpikes
			tmq = spikesAux[m, :] .- mean(spikesAux[m, 50:64]);
			
			if tmq[20] > 0
				push!(indp, m);
			else
				push!(indn, m);
			end
		end
			
		if !isempty(indp)
			a = 1 + offset;
			b = length(indp) + offset;
			
			A[a:b, 1] = spikesInfo[:, 1][i][indp];
			A[a:b, 2] .= spikesInfo[:, 2][i];
			A[a:b, 3] .= spikesInfo[:, 3][i];
			
			offset += length(indp);
		end
		
		if !isempty(indn)
			a = 1 + offset;
			b = length(indn) + offset;
			
			A[a:b, 1] = spikesInfo[:, 1][i][indn];
			A[a:b, 2] .= spikesInfo[:, 2][i] * -1;
			A[a:b, 3] .= spikesInfo[:, 3][i] * -1;
			
			offset += length(indn);
		end
	end 

	return A;
end