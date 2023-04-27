"""
	improved_plot_waves(spikesInfo::Array{Any, 2}, info::INFO)

Plot the waveforms of activities detected by each electrodes during a recording session. The plotting of negative and 
positive activities are plotted separately in two subplots with means of the individual waveforms detected by each 
electrodes.

### Arguments
- `spikesInfo::Array{Any, 2}` : 2D array containing, for each channel (row):
	- Column 1: spikes indices array
	- Column 2: channel name
	- Column 3: channel number
	- Column 4: vector with the waves of each spike found in that channel
- `info::INFO` : structure that stores the general information of the analysis.
- `channelsNames::Array{String, 1}` : auxiliary array that stores the channels names in string format.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com
"""

function improved_plot_waves(spikesInfo::Array{Any, 2}, info::INFO, channelsNames::Array{String, 1})
	numberChannels = length(spikesInfo[:, 1]);

	posMeans = [];
	negMeans = [];
	posStd = [];
	negStd = [];

	plotTitles = [];

	MAX = -999;
	MIN = 999;

	for i in 1:numberChannels
		indp = [];
		indn = [];
		spikesAux = spikesInfo[:, 4][i];
		nSpikes = size(spikesAux, 1);
		
		for m in 1:nSpikes
			tmq = spikesAux[m, :] .- mean(spikesAux[m, 50:64]);
			
			if tmq[20] > 0
				push!(indp, m);
			else
				push!(indn, m);
			end
		end
		
		mwave = mean(spikesAux[indp, :], dims=1);
		mwave = mwave .- mean(mwave[50:64]);
		swave = std(spikesAux[indp, :], dims=1);
		MAX = max(MAX, maximum(mwave));
		MIN = min(MIN, minimum(mwave));
		
		push!(posMeans, mwave);
		push!(posStd, swave);
		
		
		
		mwave = mean(spikesAux[indn, :], dims=1);
		mwave = mwave .- mean(mwave[50:64]);
		swave = std(spikesAux[indn, :], dims=1);
		MAX = max(MAX, maximum(mwave));
		MIN = min(MIN, minimum(mwave));
		
		push!(negMeans, mwave);
		push!(negStd, swave);
			
		#push!(plotTitles, spikesInfo[:, 2][i]);
		push!(plotTitles, channelsNames[i]);			
	end

	if numberChannels != 60
		# If it is not a 60 electrodes MEA just plot the channels in numerical order
		factors = closest_factors(numberChannels);

		posPlot = Plots.plot(vec.(posMeans), layout = Plots.grid(factors[1], factors[2]), 
				legend=false, 
				title=["[$i]" for j = 1:1, i=plotTitles],
				titleloc = :right, titlefont = font(6), 
				ylims=(MIN, MAX), ticks=nothing);
		Plots.savefig(posPlot, string(info.outpath, "positive_waves.pdf"));

		negPlot = Plots.plot(vec.(negMeans), layout = Plots.grid(factors[1], factors[2]), 
			legend=false, 
			title=["[$i]" for j = 1:1, i=plotTitles],
			titleloc = :right, titlefont = font(6),
			ylims=(MIN, MAX), ticks=nothing);
		Plots.savefig(negPlot, string(info.outpath, "negative_waves.pdf"));
	else
		# If it is a 60 electrodes MEA plot the channels as distributed in the device
		sp1 = findall(x->string(x)[2]=='1', plotTitles)
		sp2 = findall(x->string(x)[2]=='2', plotTitles)
		sp3 = findall(x->string(x)[2]=='3', plotTitles)
		sp4 = findall(x->string(x)[2]=='4', plotTitles)
		sp5 = findall(x->string(x)[2]=='5', plotTitles)
		sp6 = findall(x->string(x)[2]=='6', plotTitles)
		sp7 = findall(x->string(x)[2]=='7', plotTitles)
		sp8 = findall(x->string(x)[2]=='8', plotTitles)

		pblank = Plots.plot(legend=false,grid=false,foreground_color_subplot=:white); # Blank plot to fill the voids

		# Positive
		p1 = Plots.plot(vec.(posMeans)[sp1], title=["[$i]" for j = 1:1, i=plotTitles[sp1]], layout=(1, 6));
		p2 = Plots.plot(vec.(posMeans)[sp2], title=["[$i]" for j = 1:1, i=plotTitles[sp2]], layout=(1, 8));
		p3 = Plots.plot(vec.(posMeans)[sp3], title=["[$i]" for j = 1:1, i=plotTitles[sp3]], layout=(1, 8));
		p4 = Plots.plot(vec.(posMeans)[sp4], title=["[$i]" for j = 1:1, i=plotTitles[sp4]], layout=(1, 8));
		p5 = Plots.plot(vec.(posMeans)[sp5], title=["[$i]" for j = 1:1, i=plotTitles[sp5]], layout=(1, 8));
		p6 = Plots.plot(vec.(posMeans)[sp6], title=["[$i]" for j = 1:1, i=plotTitles[sp6]], layout=(1, 8));
		p7 = Plots.plot(vec.(posMeans)[sp7], title=["[$i]" for j = 1:1, i=plotTitles[sp7]], layout=(1, 8));
		p8 = Plots.plot(vec.(posMeans)[sp8], title=["[$i]" for j = 1:1, i=plotTitles[sp8]], layout=(1, 6));

		l = @layout [i a{0.75w} j;b{1.0w};c{1.0w};d{1.0w};e{1.0w};f{1.0w};g{1.0w};k h{0.75w} l]
		posPlot = Plots.plot(pblank, p1, pblank, p2, p3, p4, p5, p6, p7, pblank, p8, pblank, 
			layout = l, legend=false, titleloc = :right, titlefont = font(8), ylims=(MIN, MAX), ticks=nothing, size=(1152, 1152));
		Plots.savefig(posPlot, string(info.outpath, "positive_waves.pdf"));

		# Negative
		p1 = Plots.plot(vec.(negMeans)[sp1], title=["[$i]" for j = 1:1, i=plotTitles[sp1]], layout=(1, 6));
		p2 = Plots.plot(vec.(negMeans)[sp2], title=["[$i]" for j = 1:1, i=plotTitles[sp2]], layout=(1, 8));
		p3 = Plots.plot(vec.(negMeans)[sp3], title=["[$i]" for j = 1:1, i=plotTitles[sp3]], layout=(1, 8));
		p4 = Plots.plot(vec.(negMeans)[sp4], title=["[$i]" for j = 1:1, i=plotTitles[sp4]], layout=(1, 8));
		p5 = Plots.plot(vec.(negMeans)[sp5], title=["[$i]" for j = 1:1, i=plotTitles[sp5]], layout=(1, 8));
		p6 = Plots.plot(vec.(negMeans)[sp6], title=["[$i]" for j = 1:1, i=plotTitles[sp6]], layout=(1, 8));
		p7 = Plots.plot(vec.(negMeans)[sp7], title=["[$i]" for j = 1:1, i=plotTitles[sp7]], layout=(1, 8));
		p8 = Plots.plot(vec.(negMeans)[sp8], title=["[$i]" for j = 1:1, i=plotTitles[sp8]], layout=(1, 6));

		l = @layout [i a{0.75w} j;b{1.0w};c{1.0w};d{1.0w};e{1.0w};f{1.0w};g{1.0w};k h{0.75w} l]
		negPlot = Plots.plot(pblank, p1, pblank, p2, p3, p4, p5, p6, p7, pblank, p8, pblank,
			layout = l, legend=false, titleloc = :right, titlefont = font(8), ylims=(MIN, MAX), ticks=nothing, size=(1152, 1152));
		Plots.savefig(negPlot, string(info.outpath, "negative_waves.pdf"));
	end

end
