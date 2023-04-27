"""
	locate_spikes_quiroga(xf::Array{Float64, 1}, xf_detect::Array{Float64, 1}, thr::Float64, w_pre::Int, w_post::Int, ref::Float64, detect::String) 
		-> idx::Array{Int64, 1}, nspk::Int

Detect individual spike times.

Script derived from the Quiroga's package Wave_clus.

### Arguments
- `xf::Array{Float64, 1}` : band-pass filtered data vector, used in spike-sorting.
- `xf_detect::Array{Float64, 1}` : band-pass filtered data vector, used in spike-detection.
- `thr::Float64` : minimum threshold for detection (See Quiroga).
- `w_pre::Int` : number of pre-event data points stored.
- `w_post::Int` : number of post-event data points stored.
- `ref::Float64` : detector dead time (in ms).
- `detect::String` : type of threshold ("neg", "pos", "both").

### Return
- `idx::Array{Int64, 1}` : indices of the detected spikes.
- `nspk::Int` : number of spikes detected.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com
"""

function locate_spikes_quiroga(xf::Array{Float64, 1}, xf_detect::Array{Float64, 1}, thr::Float64, w_pre::Int, w_post::Int, ref::Float64, detect::String)
	idx = zeros(Int64, 0) # output array with indices (need to be Int because Float cannot work as an array index later)

	if detect == "pos"
	    # Detect positive threshold crossings...
	    nspk = 0;

	    # finds all the absolute values of the elements from the array that are bigger than thr
	    xf_detect_over_thr = findall(xf_detect[w_pre+2:end-w_post-2] .> thr)
	    # broadcast applies the function + between each element of the array and w_pre+1
	    xaux = broadcast(+, xf_detect_over_thr , w_pre+1);
	    xaux0 = 0;
	    
	    for i in 1:length(xaux)
	        if xaux[i] >= xaux0 + ref
	            A = xf[xaux[i]:xaux[i]+Int64(floor(ref/2))-1]
	            iaux = findall(A .== maximum(A)) # introduces alignment
	            nspk = nspk + 1; # needs? the global tag if we want to modify its value inside the loop scope
	            append!(idx, iaux .+ (xaux[i] -1));
	            xaux0 = idx[nspk];
	        end
	    end
	elseif detect == "neg"
	    # Detect negative threshold crossings...
	    nspk = 0;

	    # finds all the absolute values of the elements from the array that are bigger than thr
	        xf_detect_over_thr = findall(xf_detect[w_pre+2:end-w_post-2] .< -thr)
	    # broadcast applies the function + between each element of the array and w_pre+1
	    xaux = broadcast(+, xf_detect_over_thr , w_pre+1);
	    xaux0 = 0;
	    
	    for i in 1:length(xaux)
	        if xaux[i] >= xaux0 + ref
	            A = xf[xaux[i]:xaux[i]+Int64(floor(ref/2))-1]
	            iaux = findall(A .== minimum(A)) # introduces alignment
	            nspk = nspk + 1; # needs? the global tag if we want to modify its value inside the loop scope
	            append!(idx, iaux .+ (xaux[i] -1));
	            xaux0 = idx[nspk];
	        end
	    end        
	elseif detect == "both"
	    # Detect both positive and negative threshold crossings...
	    nspk = 0;

	    # finds all the absolute values of the elements from the array that are bigger than thr
	    xf_detect_over_thr = findall(abs.(xf_detect[w_pre+2:end-w_post-2]) .> thr)
	    # broadcast applies the function + between each element of the array and w_pre+1
	    xaux = broadcast(+, xf_detect_over_thr , w_pre+1);
	    xaux0 = 0;
	            
	    for i in 1:length(xaux)
	        if xaux[i] >= xaux0 + ref
	            A = abs.(xf[xaux[i]:xaux[i]+Int64(floor(ref/2))-1])
	            iaux = findall(A .== maximum(A)) # introduces alignment
	            nspk = nspk + 1; # needs? the global tag if we want to modify its value inside the loop scope
	            append!(idx, iaux .+ (xaux[i] -1));
	            xaux0 = idx[nspk];
	        end
	    end
	end

	return idx, nspk
end
