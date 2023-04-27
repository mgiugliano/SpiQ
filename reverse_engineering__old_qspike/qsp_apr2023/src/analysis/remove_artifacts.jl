"""
	remove_artifacts(A::Array{Float64, 2}, info::INFO) -> C::Array{Float64, 2}

Remove artifacts from the detected spike time stamps. An artifact is defined as very high number of 
spikes (50) within a single bin of 3 ms, returning a matrix `C` with the cleaned data.

### Arguments
- `A::Array{Float64, 2}` : matrix with Nx3 dimensions, being N the number of spikes, and where the columns are:
	- First column is the spike time stamp.
	- Second column is the electrode name. 
	- Third column is the electrode number.
- `info::INFO` : structure that stores the general information of the analysis.

### Return
- `C::Array{Float64, 2}` : matrix with Nx3 dimensions, being N the number of spikes, and where the columns are:
	- First column is the spike time stamp.
	- Second column is the electrode name. 
	- Third column is the electrode number.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com
"""

function remove_artifacts(A::Array{Float64, 2}, info::INFO)
	T = info.T;
	D = 3.;
	edges = 0:D:T+D;
	psth = fit(Histogram, A[:, 1], edges).weights;

	ARTIFACTS = edges[findall(psth .> 50)];

	B = copy(A);
	n = 0;
	for k in 1:length(ARTIFACTS)
		indx = findall(abs.(A[:, 1] .- ARTIFACTS[k] .- 0.5*D) .< (0.5*D));
		B[indx, 1] .= NaN;
		n = n + length(indx);
	end

	C = zeros(size(B, 1) - n, 3);
	m = 1;
	for k in 1:size(B, 1)
		if !isnan(B[k, 1])
			C[m, :] .= B[k, :];
			m += 1;
		end
	end

	return C;
end
