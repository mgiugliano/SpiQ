"""
Script that extracts an saves in separated files each of the channels found in an HDF5 file.

The HDF5 must have the .h5qspike format generated by demultiplexH5Py.jl from a MCS (Multi Channel Systems) HDF5 file.
Each channel will be extracted in parallel using all the availables CPU cores.

### Arguments
- `preProcessedPath::String` : general path that contains the preprocessed data.
- `filename::String` : full path of the input HDF5 (.h5qspike) file.
- `recName::String` : recording name.

### Examples
```jldoctest
julia src/private/channel_extract_hdf5.jl "data/OUTPUT_PREPROCESSED_FILES" "data/INPUT_FILES/trace1_stream0.h5qspike" "trace1"
```

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com
- Manuel Reyes-Sanchez - mnrs94@gmail.com
"""

using HDF5
using Distributed
nCores = Sys.CPU_THREADS;
addprocs(nCores, exeflags="--project");

"""
	write_info_file_header(outputPath::String, streamName::String, numberSamples::Int, duration::Int, samplingRate::Int)

Save the recording general information into a file located in `outputPath`/`recName`_info.txt.

### Arguments
- `outputPath::String`: full output path for the info file.
- `recName::String`: recording name.
- `numberSamples::Int`: number of samples of the stream.
- `duration::Int`: duration of the stream (msec).
- `samplingRate::Int`: sampling rate of the stream (Hz).

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com
"""

@everywhere function write_info_file_header(outputPath::String, recName::String, numberSamples::Int, duration::Int, samplingRate::Int)
	filename = outputPath * "/" * recName * "_info.txt";
	fid = open(filename, "w");
	
	write(fid, "$duration\n");
	write(fid, "$numberSamples\n");
	write(fid, "$samplingRate\n");
	
	close(fid);
end


"""
	write_info_file_stream(outputPath::String, recName::String, streamType::String, channelsIds::Array{String, 1})

Add the stream information into a file located in `outputPath`/`recName`_info.txt.

### Arguments
- `outputPath::String`: full output path for the info file.
- `recName::String`: recording name.
- `streamType::String`: type of the stream ("elec", "digi" or "anlg").
- `channelsIds::Array{String, 1}`: IDs of each channel of the stream.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com
"""

@everywhere function write_info_file_stream(outputPath::String, recName::String, streamType::String, channelsIds::Array{String, 1})
	filename = outputPath * "/" * recName * "_info.txt";
	fid = open(filename, "a");

	write(fid, "$streamType\n");
	
	for id in channelsIds
		write(fid, "$id\n");
	end
	
	close(fid);
end


"""
	write_data_file(outputPath::String, streamName::String, channelId::Int, streamType::String, data::Array{Float64, 1})

Save the data recorded by an specific channel of the stream into a binary file located in `outputPath`/`streamName`_`streamType`_`channelId`.dat.

### Arguments
- `outputPath::String`: full output path for the data file.
- `recName::String`: recording name.
- `channelId::String`: ID of the channel.
- `streamType::String`: type of the stream ("elec", "digi" or "anlg").
- `data::Array{Float64, 1}`: data recorded by that channel.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Manuel Reyes-Sanchez - mnrs94@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com
"""

@everywhere function write_data_file(outputPath::String, recName::String, channelId::String, streamType::String, data::Array{Float64, 1})
    filename = string(outputPath, "/", recName, "_", streamType, "_", channelId, ".dat");
    file =  open(filename, "w");

    println(string("Extracting data from ", streamType, " channel ", channelId, "."))
    
    for elem in data
        write(file, elem);
    end
    
    close(file);
end


preProcessedPath = ARGS[1];
filename = ARGS[2];
recName = ARGS[3];

# Creates the OUTPUT_PREPROCESSED_FILES/recName directory if it doesn't exists
try
	mkdir(preProcessedPath);
	println(preProcessedPath * " dir created." );
catch err
	println(preProcessedPath * " dir already exists. Nothing done.");
end

fid = h5open(filename, "r");

# Get the streams names and sort them reversely
# so ElectrodeStream is the first
streamsNames = sort(names(fid), rev=true); 

for name in streamsNames
	if occursin("ElectrodeStream", name)
		elecStream = read(fid[name]);

		if !isempty(elecStream)
			numberChannels = elecStream["NumberChannels"];
			numberSamples = elecStream["NumberSamples"];
			samplingRate = elecStream["SamplingRate"];
			duration = elecStream["Duration"];
			expnt = elecStream["Exponent"];
			ADZero = elecStream["ADZero"];
			conversionFactor = elecStream["ConversionFactor"];
			channelsIds = elecStream["ChannelsIDs"];
			data = elecStream["ChannelData"];
			
			write_info_file_header(preProcessedPath, recName, numberSamples, duration, samplingRate);
			write_info_file_stream(preProcessedPath, recName, string("Nelec", numberChannels), channelsIds);
			
			@sync @distributed for i in 1:numberChannels
				channelId = channelsIds[i];
				channelData = (data[:, i] .- ADZero) .* (conversionFactor * 10.0^expnt);
				write_data_file(preProcessedPath, recName, channelId, "elec", channelData);
			end
		end

	elseif occursin("DigitalStream", name)
		digiStream = read(fid[name]);

		if !isempty(digiStream)
			numberChannels = digiStream["NumberChannels"];
			numberSamples = digiStream["NumberSamples"];
			samplingRate = digiStream["SamplingRate"];
			duration = digiStream["Duration"];
			expnt = digiStream["Exponent"];
			ADZero = digiStream["ADZero"];
			conversionFactor = digiStream["ConversionFactor"];
			channelsIds = digiStream["ChannelsIDs"];
			data = digiStream["ChannelData"];
			
			write_info_file_stream(preProcessedPath, recName, string("Ndigi", numberChannels), channelsIds);
			
			@sync @distributed for i in 1:numberChannels
				channelId = channelsIds[i];
				channelData = (data[:, i] .- ADZero) .* (conversionFactor * 10.0^expnt);
				write_data_file(preProcessedPath, recName, channelId, "digi", channelData);
			end
		end

	elseif occursin("AuxiliaryStream", name)
		auxStream = read(fid[name]);

		if !isempty(auxStream)
			numberChannels = auxStream["NumberChannels"];
			numberSamples = auxStream["NumberSamples"];
			samplingRate = auxStream["SamplingRate"];
			duration = auxStream["Duration"];
			expnt = auxStream["Exponent"];
			ADZero = auxStream["ADZero"];
			conversionFactor = auxStream["ConversionFactor"];
			channelsIds = auxStream["ChannelsIDs"];
			data = auxStream["ChannelData"];
			
			write_info_file_stream(preProcessedPath, recName, string("Nanlg", numberChannels), channelsIds);
			
			@sync @distributed for i in 1:numberChannels
				channelId = channelsIds[i];
				channelData = (data[:, i] .- ADZero) .* (conversionFactor * 10.0^expnt);
				write_data_file(preProcessedPath, recName, channelId, "anlg", channelData);
			end
		end
	end
end

close(fid);