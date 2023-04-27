"""
	write_global_info_to_text(info::INFO, bursts::BURSTS)

Write the global INFO file to the disk as *_Activity_Information.txt in the output directory.

### Arguments
- `info::INFO` : structure that stores the general information of the analysis.
- `bursts::BURSTS` : structure that stores the results of the burst analysis.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com
"""

function write_global_info_to_text(info::INFO, bursts::BURSTS)
	fid = open(string(info.outpath, info.expName, "_", "Activity_Information.txt"), "w");

	write(fid, "Activity Information Extracted from the Recording Data\n");
	write(fid, "------------------------------------------------------\n\n\n");
	write(fid, "Recording Duration                  :\t$(info.T) ms\n");
	write(fid, "Number of Samples                   :\t$(info.Ns)\n");
	write(fid, "Sampling Rate                       :\t$(info.sr) Hz\n");
	write(fid, "Number of Active Electrodes         :\t$(info.nActiveElectrodes)\n");
	write(fid, "Number of Spikes                    :\t$(bursts.Nspikes)\n");
	write(fid, "Number of Bursts                    :\t$(bursts.Nburst)\n");
	write(fid, "Mean Burst Duration                 :\t$(bursts.meanDUR) ms\n");
	write(fid, "Standard Deviation of Burst Duration:\t$(bursts.stdDUR) ms\n");
	write(fid, "Mean Inter-Burst-Interval (IBI)     :\t$(bursts.meanIBI) ms\n");
	write(fid, "Standard Deviation of IBI           :\t$(bursts.stdIBI) ms\n");
	write(fid, "Burst Detection Threshold           :\t$(bursts.TH)\n");

	close(fid);
end



function write_general_stat_to_text(info::INFO, bursts::BURSTS)
"""
	As in `write_global_info_to_text`, but in a tab-delimited format.
	
### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Amo - amo.iso@tuta.io
"""
	fid = open(string(info.outpath, "INFO.txt"), "w");
	write(fid, "Number of Active Electrodes\t$(info.nActiveElectrodes)\n");
	write(fid, "Number of Spikes\t$(bursts.Nspikes)\n");
	write(fid, "Number of Bursts\t$(bursts.Nburst)\n");
	write(fid, "Mean Burst Duration\t$(bursts.meanDUR)\n");
	write(fid, "Standard Deviation of Burst Duration\t$(bursts.stdDUR)\n");
	write(fid, "Mean Inter-Burst-Interval (IBI)\t$(bursts.meanIBI)\n");
	write(fid, "Standard Deviation of IBI\t$(bursts.stdIBI)\n");
	close(fid);
end




function write_IBI_to_text(info::INFO, bursts::BURSTS)


"""
	write_IBI_to_text(info::INFO, bursts::BURSTS)

Saves IBIs (in ms) to a *_IBI.txt file in the output directory.

### Arguments
- `info::INFO` : structure that stores the general information of the analysis.
- `bursts::BURSTS` : structure that stores the results of the burst analysis.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com
"""

	fid = open(string(info.outpath, info.expName, "_", "IBI.txt"), "w");

	for i in 1:length(bursts.IBI) # For each IBI
		write(fid, "$(bursts.IBI[i])\n");
	end

	close(fid);
end 


function write_bursts_firing_rates(info::INFO, bursts::BURSTS, spikesInfo::Array{Float64, 2})
"""
	write_burst_spk_count(info::INFO, bursts::BURSTS, spikesInfo::Array{Float64, 2})

Write a tab delimited file to the disk as *_burst_firing_rate.txt in the output 
directory.
containing three columns: burst duration (ms), number of spikes during the burst and 
spiking frequency. The spiking frequency during bursts is normalized by the length 
of the burst.


### Arguments
- `info::INFO`     : structure that stores the general information of the analysis.
- `bursts::BURSTS` : structure that stores the results of the burst analysis.
- `spikesInfo`     : matrix with Nx3 dimensions, being N the number of spikes, 
					 where the columns are:First column is the spike time stamp.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Amo - amo.iso@tuta.io
"""
    fid = open(string(info.outpath, info.expName, "_", "bursts_firing_rates.txt"), "w");
	for i in 1:bursts.Nburst
		left_bound        = abs(bursts.tlefts[i])
		right_bound       = abs(bursts.trights[i])
		burst_spks        = spikesInfo[:,1][left_bound .< spikesInfo[:,1].< right_bound]
		burst_spk_count   = length(burst_spks)		
		burst_dur         = right_bound - left_bound
		burst_firing_rate = (burst_spk_count / burst_dur) * 1000. # Hz
		write(fid, "$(burst_dur)\t$(burst_spk_count)\t$(burst_firing_rate)\n");
	end	
	close(fid);
end 


