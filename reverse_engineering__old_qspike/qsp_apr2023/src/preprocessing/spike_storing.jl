using Dierckx # Add Dierckx library for interpolations in Julia

"""
	spike_storing(xf::Array{Float64, 1}, xf_detect::Array{Float64, 1}, idx::Array{Int64, 1}, w_pre::Int, w_post::Int, nspk::Int, int_factor::Int, thrmax::Float64, interpolation::String, detect::String)
		-> spikes::Array{Float64, 2}, xf_enlarged::Array{Float64, 1}

Store the detected waveforms from each electrode in a raw format with a predefined waveform size specified in the parameters file.

Script derived from the Quiroga's package Wave_clus.

### Arguments
- `xf::Array{Float64, 1}` : band-pass filtered data vector, used in spike-sorting.
- `xf_detect::Array{Float64, 1}` : band-pass filtered data vector, used in spike-detection.
- `idx::Array{Int64, 1}` : indices of the detected spikes.
- `w_pre::Int` : number of pre-event data points stored.
- `w_post::Int` : number of post-event data points stored.
- `nspk::Int` : number of spikes detected.
- `int_factor::Int` : interpolation factor.
- `thrmax::Float64` : maximum threshold for detection (See Quiroga).
- `interpolation::String` : interpolation with cubic splines ("n","y").
- `detect::String` : type of threshold ("neg", "pos", "both").

### Return
- `spikes::Array{Float64, 2}` : matrix with the waveforms of the detected spikes (one spike per row).
- `xf_enlarged::Array{Float64, 1}` : enlarged `xf` to avoid final trimming problems.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com
"""


function spike_storing(xf::Array{Float64, 1}, xf_detect::Array{Float64, 1}, idx::Array{Int64, 1}, w_pre::Int, w_post::Int, 
	nspk::Int, int_factor::Int, thrmax::Float64, interpolation::String, detect::String)

	ls = w_pre + w_post; # Size of the waveform sample to store
	spikes = zeros(nspk, ls+4); # Memory pre-allocation
	xf_enlarged = [xf ; zeros(w_post, 1)] # Enlarges 'xf' to avoid final trimming problems; it was xf=[xf zeros(1,w_post)];

	for i in 1:nspk # For each event detected, store the waveform, unless is too large (i.e., it's an artifact)
	    if maximum(abs.(xf_enlarged[idx[i]-w_pre : idx[i] + w_post])) .< thrmax
	        spikes[i,:] = xf_enlarged[idx[i]-w_pre-1 : idx[i]+w_post+2];
	    else
	        println("Artifact removed!");
	    end
	end
	    
	# Erase indexed that were artifacts
	aux = findall(spikes[:, w_pre] .== 0);
	spikes[aux, :] = [];
	idx[aux] = [];
	    
	nspk_sort = size(spikes, 1);
	s = 1:size(spikes, 2);
	ints = 1 / int_factor:1 / int_factor:size(spikes,2);
	intspikes = zeros(1, length(ints));
	spikes1 = zeros(nspk_sort, ls);

	if interpolation == "n"
	    spikes[:, end-1:end] = []; # eliminates borders that were introduced for interpolation
	    spikes[:, 1:2] = [];
	elseif interpolation == "y"
	    # Does interpolation
	    if detect == "pos"
	        for i in 1:nspk_sort
	            spl = Spline1D(s, spikes[i,:]); # the first interpolated value is different than with matlab
	            intspikes[:] = spl(ints);
	            A = intspikes[w_pre*int_factor:w_pre*int_factor+8];
	            iaux = findall(A .== maximum(A))[1] + (w_pre*int_factor - 1);
	            spikes1[i, w_pre:-1:1] = intspikes[iaux:-int_factor:iaux-w_pre*int_factor+int_factor];
	            spikes1[i, w_pre+1:ls] = intspikes[iaux+int_factor:int_factor:iaux+w_post*int_factor];
	        end
	    elseif detect == "neg"
	        for i in 1:nspk_sort
	            spl = Spline1D(s, spikes[i,:]); # the first interpolated value is different than with matlab
	            intspikes[:] = spl(ints);
	            A = intspikes[w_pre*int_factor:w_pre*int_factor+8];
	            iaux = findall(A .== maximum(A))[1] + (w_pre*int_factor - 1);
	            spikes1[i, w_pre:-1:1] = intspikes[iaux:-int_factor:iaux-w_pre*int_factor+int_factor];
	            spikes1[i, w_pre+1:ls] = intspikes[iaux+int_factor:int_factor:iaux+w_post*int_factor];
	        end
	    elseif detect == "both"
	        for i in 1:nspk_sort
	            spl = Spline1D(s, spikes[i,:]); # the first interpolated value is different than with matlab
	            intspikes[:] = spl(ints);
	            A = abs.(intspikes[w_pre*int_factor:w_pre*int_factor+8]);
	            iaux = findall(A .== maximum(A))[1] + (w_pre*int_factor - 1);
	            spikes1[i, w_pre:-1:1] = intspikes[iaux:-int_factor:iaux-w_pre*int_factor+int_factor];
	            spikes1[i, w_pre+1:ls] = intspikes[iaux+int_factor:int_factor:iaux+w_post*int_factor];
	        end
	    end
	    
	    spikes = spikes1;
	    spikes1 = nothing;
	end 

	return spikes, xf_enlarged
end