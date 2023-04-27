
"""
	plot_pelt_matrix(new_pelt_matrix::Array{Float64, 3}, edges, OUTPATH::String)

Auxiliary method. Plot the burst profile across different electrodes.

### Arguments
- `new_pelt_matrix::Array{Float64, 3}` : a 3D matrix containing
	- 1D: number of electrodes.
	- 2D: event raster during the burst.
	- 3D: bursts.
- `edges` : binned edges of time values.
- `OUTPATH::String` : path of the preprocessed data files.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com
"""

function plot_pelt_matrix(new_pelt_matrix::Array{Float64, 3}, edges, OUTPATH::String)
	rows = size(new_pelt_matrix, 1);
	pm = mean(new_pelt_matrix, dims=3);
	x_ticks = (-edges[end-1]/2:(edges[2]-edges[1]):edges[end]/2)*0.001;

	p1 = Plots.plot(edges, mean(pm, dims=1)[1, :, 1], fill=0, 
		color=:grey, linecolor=:black, legend=false, xticks=(edges, x_ticks), 
		title = string("Avegare population burst profile (bin size ", edges[2]-edges[1]," ms)"),
		ylabel="# spikes/burst/bin", xrotation = 90);

	p2 = Plots.plot(edges, pm[1,:].+1, fill = 1);
	for channel in 2:rows
		p2 = Plots.plot!(edges, pm[channel,:].+channel, fill = channel);
	end

	p2 = Plots.plot!(legend=false, xticks=(edges, x_ticks), ylabel="# electrodes", xlabel="Time (s)", xrotation = 90);

	p = Plots.plot(p1, p2, layout = Plots.grid(2,1,heights=[0.15,0.82]), size=(800,600));
	Plots.savefig(p, string(OUTPATH, "vanpelt_plot_complete.pdf"));
end