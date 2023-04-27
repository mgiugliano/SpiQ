"""
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
"""

function active_electrodes(spikesInfo::Array{Float64, 2}, info::INFO)
	electrodes = unique(abs.(spikesInfo[:,2])); # using e.g., the decorated names
	nElectrodes = length(electrodes);     # number of electrodes available
	nSpikes = zeros(Int, nElectrodes);  # array to contain the #events / chan

	for h in 1:nElectrodes
		nSpikes[h] = length(findall(abs.(spikesInfo[:, 2]) .== electrodes[h]));
	end

	info.nActiveElectrodes = length(findall(nSpikes .> (0.02 * info.T / 1000.0)));

	D = maximum(nSpikes) / 20;
	edges = 1:D:maximum(nSpikes)+D;

	hNspikes = fit(Histogram, nSpikes, edges).weights;

	plt.clf();
	plt.figure(figsize=(12, 8));
	edges = 1:D:maximum(nSpikes);
	plt.bar(edges, hNspikes, width=D, align="edge");
	plt.xlim(left=1, right=maximum(nSpikes));
	plt.xlabel(string("# Events in ", maximum(spikesInfo[:,1]) / 1000., " secs"), fontsize=18);
	plt.ylabel("# Electrodes", fontsize=18); # !! why is it the number of electrodes?
	plt.title(string("Active electrodes (i.e., >0.02 Hz): ", info.nActiveElectrodes, " out of ", 
		nElectrodes," (", 100*info.nActiveElectrodes/nElectrodes,"%)"), fontsize=20);
	plt.tight_layout();
	plt.savefig(string(info.outpath, "active_electrodes.pdf"), format="pdf");
end