"""
	largest_burst(spikesInfo::Array{Float64, 2}, info::INFO, bursts::BURSTS)

Largest_burst calculates the largest population burst present at the recording file. It also plots sample rasters 
and PSTHs centering the  detected largest burst for 10 seconds and 1 second, as well as the raw trace of the burst.

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
"""

function largest_burst(spikesInfo::Array{Float64, 2}, info::INFO, bursts::BURSTS)

	####### Find the largest burst #######
	A = spikesInfo[:, 1];

	T     = info.T;
	D     = 3.;
	edges = 0:D:T+D;
	numberChannels = length(unique!(abs.(spikesInfo[:, 3])));

	psth = fit(Histogram, spikesInfo[:, 1], edges).weights;

	# Find the largest burst index
	M = findall(psth .== maximum(psth));
	maxBurstIndex = M[1];

	# !! some kind of artifact fixing?
	while (maximum(psth)>50)
		psth[maxBurstIndex] = 0;
		M = findall(psth .== maximum(psth));
		maxBurstIndex = M[1];
	end

	# Stores the indexes that will be used later
	if edges[maxBurstIndex] - 5000. < 0.
		t1a = 0.;
	else
		t1a = edges[maxBurstIndex] - 5000.;
	end

	if edges[end] < (edges[maxBurstIndex] + 5000.)
		t1b = edges[end];
	else
		t1b = edges[maxBurstIndex] + 5000.;
	end


	if edges[maxBurstIndex] - 500. < 0.
		t2a = 0.;
	else
		t2a = edges[maxBurstIndex] - 500.;
	end


	if edges[end] < (edges[maxBurstIndex] + 500.)
		t2b = edges[end];
	else
		t2b = edges[maxBurstIndex] + 500.;
	end

	####### Plots the largest burst in a 10 seconds window #######
	D     = 30.;
	bursts.largest_burst_bin = D;
	edges = 0:D:T+D;

	psth = fit(Histogram, spikesInfo[:, 1], edges).weights;

	indx = findall((spikesInfo[:, 1] .>= t1a) .& (spikesInfo[:, 1] .<= t1b));
	spks = spikesInfo[indx, :]; # All spikes before T

	edges = 0:D:T;

	plt.clf();
	plt.figure(figsize=(12,12));

	ax1 = plt.subplot(2, 1, 1);
	ax1.set_title("Largest population burst", fontsize=20);
	ax1.set_ylabel("Electrode", fontsize=18);

	for h in 1:length(indx)
		ax1.eventplot([spks[h, 1] / 1000], lineoffsets=abs(spks[h, 2]), color=:black); # Plotted in seconds
	end

	ax2 = plt.subplot(2, 1, 2, sharex=ax1);
	ax2.plot(edges ./ 1000, psth, color=:black);
	ax2.set_xlim(t1a ./ 1000, t1b ./ 1000);
	ax2.set_ylabel("Spike count", fontsize=18);
	ax2.set_xlabel("Time [s]", fontsize=18);

	plt.tight_layout();
	plt.savefig(string(info.outpath, "largest_burst.pdf"), format="pdf");


	####### Plots the largest burst in a 1 second window #######
	D     = 10.;
	bursts.largest_burst_bin_zoomed_in = D;
	edges = 0:D:T+D;

	psth = fit(Histogram, spikesInfo[:, 1], edges).weights;

	indx = findall((spikesInfo[:, 1] .>= t2a) .& (spikesInfo[:, 1] .<= t2b));
	spks = spikesInfo[indx, :]; # All spikes before T


	edges = 0:D:T;

	plt.clf();
	plt.figure(figsize=(12,12));

	ax1 = plt.subplot(2, 1, 1);
	ax1.set_title("Largest population burst (zoomed in)", fontsize=20);
	ax1.set_ylabel("Electrode", fontsize=18);

	for h in 1:length(indx)
		ax1.eventplot([spks[h, 1] / 1000], lineoffsets=abs(spks[h, 2]), color=:black); # Plotted in seconds
	end

	ax2 = plt.subplot(2, 1, 2, sharex=ax1);
	ax2.plot(edges ./ 1000, psth, color=:black);
	ax2.set_xlim(t2a ./ 1000, t2b ./ 1000);
	ax2.set_ylabel("Spike count", fontsize=18);
	ax2.set_xlabel("Time [s]", fontsize=18);

	plt.tight_layout();
	plt.savefig(string(info.outpath, "largest_burst_zoom.pdf"), format="pdf");



	####### Plots the largest burst raw data #######

	# !! this is the same as active_electrodes
	electrodes = unique(abs.(spikesInfo[:,3])); # using e.g., the ids
	electrodes_names = unique(abs.(spikesInfo[:,2])); # using e.g., the decorated names
	nElectrodes = length(electrodes);     # number of electrodes available
	nSpikes = zeros(Int, nElectrodes);  # array to contain the #events / chan

	for h in 1:nElectrodes
		nSpikes[h] = length(findall(abs.(spikesInfo[:, 3]) .== electrodes[h]));
	end

	index = sortperm(nSpikes, rev=true);

	ii1a = Int(max(t1a * info.sr * 0.001, 1));
	ii1b = Int(min(t1b * info.sr * 0.001, info.sr * 0.001 * T - 1));
	ii2a = Int(max(t2a * info.sr * 0.001, 1));
	ii2b = Int(min(t2b * info.sr * 0.001, info.sr * 0.001 * T - 1));

	channelsFiles = filter!(s->occursin(r"elec_[0-9a-zA-Z]+\.dat", s), readdir(info.prepath));
	numberChannels = length(channelsFiles);

	if (numberChannels < 1)
		println("*.dat files not found. Largest burst raw data is not going to be plotted.");
		return;
	end


	K = 25.;
	tm = (ii1a:ii1b) / info.sr;

	fmin = 400 * 2 / info.sr;
	fmax = 3000 * 2/ info.sr;

	plt.clf();
	plt.figure(figsize=(12, 8));

	for h in 1:min(10, numberChannels)
		kk = Int(electrodes[index[h]]);
		tmp = read_bin(string(info.prepath, channelsFiles[kk]), info.Ns) .* 1000000;

		myfilter = digitalfilter(Bandpass(fmin, fmax),Elliptic(2, 0.1, 40));
		tmp_filt = filtfilt(myfilter, tmp);

		tmp_filt = tmp_filt[ii1a:ii1b];

		plt.plot(tm, 2*K*(h-1) .+ tmp_filt, label=string("Electrode ", Int(electrodes_names[index[h]])));
	end

	#plt.ylim(-2*K, 2*K*10);
	
	plt.xlabel("Time [s]", fontsize=18);
	plt.ylabel("Raw voltage [uV]", fontsize=18);
	plt.legend(loc="upper right");

	plt.xlim(t1a / 1000, t1b / 1000);
	plt.title("Largest population burst (raw voltage traces)", fontsize=20);
	plt.tight_layout();
	plt.savefig(string(info.outpath, "largest_burst_raw.pdf"), format="pdf");

	plt.xlim(t2a / 1000, t2b / 1000);
	plt.title("Largest population burst (zoom, raw voltage traces)", fontsize=20);
	plt.tight_layout();
	plt.savefig(string(info.outpath, "largest_burst_rawzoom.pdf"), format="pdf");
end