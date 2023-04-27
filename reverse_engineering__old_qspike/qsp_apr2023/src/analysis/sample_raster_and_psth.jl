"""
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
"""

function sample_raster_and_psth(spikesInfo::Array{Float64, 2}, info::INFO)
	if info.T<300000
		T = info.T;
	else
		T = 300000;
	end

	indx = findall(spikesInfo[:, 1] .<= T);
	spks = spikesInfo[indx, :]; # All spikes before T

	D     = 100.;
	edges = 0:D:T+D;
	numberChannels = length(spks);
	psth = fit(Histogram, spks[:, 1], edges).weights;

	edges = 0:D:T;

	plt.clf();
	plt.figure(figsize=(12,12));

	ax1 = plt.subplot(2, 1, 1);
	ax1.set_title("Sample spontaneous activity [first 300 sec]", fontsize=20);
	ax1.set_ylabel("Electrode", fontsize=18);
	for h in 1:length(indx)
		ax1.eventplot([spks[h, 1] / 1000], lineoffsets=abs(spks[h, 2]), color=:black); # Plotted in seconds
	end

	ax2 = plt.subplot(2, 1, 2, sharex=ax1);
	ax2.plot(edges ./ 1000, psth, color=:black); # Plotted in seconds
	ax2.set_ylabel("Spike count", fontsize=18);
	ax2.set_xlabel("Time [s]", fontsize=18);

	plt.tight_layout();
	plt.savefig(string(info.outpath, "sample_raster_psth.pdf"), format="pdf");
end