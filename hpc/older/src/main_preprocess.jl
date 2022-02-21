"""
Script that launches the preprocessing of the raw data. The preprocessed data will be saved in .jld2 files.
The preprocessing will run in parallel using all the availables CPU cores.

### Arguments
- `outdir::String` : general path were the preprocessed data will be saved.
- `name::String` : stream name.
- `nSamples::Int` : number of samples of the stream.
- `sr::Int` : sampling rate (Hz).
- `nElec::Int` : number of elec channels.
- `channelsElec::Array{String, 1}` : names of the elec channels.
- `nDigi::Int` : number of digi channels.
- `channelsDigi::Array{String, 1}` : names of the digi channels.
- `nAnlg::Int` : number of anlg channels.
- `channelsDigi::Array{String, 1}` : names of the anlg channels.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com
"""

using Distributed
nCores = Sys.CPU_THREADS;
addprocs(nCores, exeflags="--project");

@everywhere include("preprocessing/processchanMG.jl");

outdir = ARGS[1];
name = ARGS[2];
nSamples = parse(Int, ARGS[3]);
sr = parse(Int, ARGS[4]);

# Reads the channels
nElec =  parse(Int, ARGS[5]);
nxtInd = 6 + nElec;
channelsElec = ARGS[6:nxtInd-1];
nDigi =  parse(Int, ARGS[nxtInd]);
frtInd = nxtInd + 1;
nxtInd = frtInd + nDigi;
channelsDigi = ARGS[frtInd:nxtInd-1];
nAnlg =  parse(Int, ARGS[nxtInd]);
frtInd = frtInd + 1;
nxtInd = nxtInd + nAnlg;
channelsAnlg = ARGS[frtInd:nxtInd-1];

path = string(outdir, "/", name);

println(outdir);
println(name);
println(nSamples);
println(sr);
println(path);

println(string("elec ", nElec, " : ", channelsElec));
println(string("digi ", nDigi, " : ", channelsDigi));
println(string("anlg ", nAnlg, " : ", channelsAnlg));

channels = []
for chan in channelsElec
	push!(channels, [chan, "elec"]);
end

for chan in channelsDigi
	push!(channels, [chan, "digi"]);
end

for chan in channelsAnlg
	push!(channels, [chan, "anlg"]);
end


@sync @distributed for chan in channels # We use @sync to make the main thread wait until all the sons are finished
	@time processchanMG("..", chan[1], chan[2], path, string(path, "/", name, "_", chan[2], "_", chan[1],".dat"), nSamples, sr)
end