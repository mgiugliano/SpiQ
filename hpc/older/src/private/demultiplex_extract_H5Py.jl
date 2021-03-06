"""
Script that extracts and saves in separated files (.h5qpsike) each recording found in a MCS HDF5 file (.h5) 
using the H5Py Python library.

MCS (Multi Channel Systems) HDF5 files are generated by the Multi Channel DataManager from .mcd or .msrd files. The
specification of these files can be found in their [their website](https://www.multichannelsystems.com/sites/multichannelsystems.com/files/documents/manuals/HDF5%20MCS%20Raw%20Data%20Definition.pdf).
The new files contain one group per each stream found in the recording, tagging them as ElectrodeStream or DigitalStream
as it corresponds. Each group have the following fields:

- `NumberChannels` : number of channels.
- `NumberSamples` : number of samples.
- `SamplingRate` : sampling rate (Hz).
- `Duration` : duration (ms).
- `Exponent` : exponent n (i.e. 10^n) in which channels values magnitude is measured (e.g. k, m, u, ...).
- `ADZero` : ADC-Step that represent the 0-point of the measuring range of the ADC.
- `ConversionFactor` : conversion factor for the mapping ADC-Step -> measured value.
- `ChannelsIDs` : vector with the IDs of each channel.
- `ChannelData` : matrix with the data recorded from each channel (numberChannels x numberSamples).


### Arguments
- `filename::String` : full path of the input MCS HDF5 (.h5) file.

### Examples
```jldoctest
julia src/private/src/private/demultiplexH5Py.jl "data/INPUT_FILES/trace1.h5"
```

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com
"""

using PyCall

h5py = pyimport("h5py")

preProcessedPath = ARGS[1];
filename = ARGS[2];
sessionName = replace(filename, ".h5" => "");

py"""
import h5py
import os
import multiprocessing as mp
import threading
import concurrent.futures

#InfoChannel indexes
CHANNELID = 0;
ROWINDEX = 1;
GROUPID = 2;
ELECTRODEGROUP = 3;
LABEL = 4;
RAWDATATYPE = 5;
UNIT = 6;
EXPONENT = 7;
ADZERO = 8;
TICK = 9;
CONVERSIONFACTOR = 10;



def write_info_file_header(outputPath, recName, numberSamples, duration, samplingRate):
	filename = outputPath + "/" + recName + "_info.txt"
	fid = open(filename, "w")
	
	fid.write("%d\n"%(duration))
	fid.write("%d\n"%(numberSamples))
	fid.write("%d\n"%(samplingRate))
	
	fid.close()

	return



def write_info_file_stream(outputPath, recName, streamType, channelsIds):
	filename = outputPath + "/" + recName + "_info.txt"
	fid = open(filename, "a")

	fid.write("%s\n"%(streamType))
	
	for id in channelsIds:
		fid.write("%s\n"%(id.decode("utf-8")))
	
	fid.close()

	return



def write_data_file(outputPath, recName, channelId, streamType, data):
	filename = outputPath + "/" + recName + "_" + streamType + "_" + channelId + ".dat"
	fid =  open(filename, "wb");

	print("Extracting data from " + streamType + " channel " + channelId + " in process " + str(os.getpid()) +  ".")
	
	for elem in data:
		fid.write(bytes(elem))
	
	fid.close()

	return



def multiplex(preProcessedPath, filename, sessionName):
	sessionName = sessionName.split("/")[-1]


	with h5py.File(filename, "r") as fid:
		print("Loaded file ", filename)

		data = fid["Data"]
		numberRecordings = len(data)
		print("Number of recordings: ", numberRecordings)

		for i in range(numberRecordings):
			rName = "Recording_" + str(i)
			recording = data[rName]

			analogStreams = recording["AnalogStream"]
			numberAnalogStreams = len(analogStreams)
			
			print("\nAnalyzing " + rName + " with " + str(numberAnalogStreams) + " stream(s):")


			recName = sessionName# + "_rec" + str(i)
			sessionPath = preProcessedPath + "/" + recName

			if not os.path.exists(preProcessedPath + "/" + recName):
				os.makedirs(sessionPath)
				print("done")


			for j in range(numberAnalogStreams):
				sName = "Stream_" + str(j)
				stream = analogStreams[sName]
				type = stream.attrs.get("DataSubType")
			
				channelData = stream["ChannelData"]
				infoChannel = stream["InfoChannel"]


				dataShape = channelData.shape
				numberChannels = dataShape[0]
				numberSamples = dataShape[1]
				samplingRate = int(1000000 / infoChannel[0][TICK])
				duration = int((numberSamples / samplingRate) * 1000)
				exponent = infoChannel[0][EXPONENT]
				ADZero = infoChannel[0][ADZERO]
				conversionFactor = infoChannel[0][CONVERSIONFACTOR]


				streamType = "UnknownStream"
				if type == b'Digital':
					streamType = "digi"
				elif type == b'Electrode':
					streamType = "elec"
				elif type == b'Auxiliary':
					streamType = "anlg"
				else:
					print("Unknown stream type")
					break



				print("\t" + sName + " has " + str(numberChannels) + " channel(s)")

				channelsIds = [];
				for k in range(numberChannels):
					channelsIds.append(infoChannel[k][LABEL])


				if (j == 0): # It is the first stream
					write_info_file_header(sessionPath, recName, numberSamples, duration, samplingRate)

				write_info_file_stream(sessionPath, recName, "N" + streamType + str(numberChannels), channelsIds)

				
				pool = mp.Pool(mp.cpu_count())

				results = [pool.apply_async(write_data_file, args=(sessionPath, recName, channelsIds[k].decode("utf-8"), streamType, (channelData[k, :] - ADZero) * (conversionFactor * 10.0**exponent))) for k in range(numberChannels)]

				pool.close()
				pool.join()
				

				'''
				threads = []
				for k in range(numberChannels):
					channelId = channelsIds[k].decode("utf-8")
					auxData = (channelData[k, :] - ADZero) * (conversionFactor * 10.0**exponent)
					t = threading.Thread(target=write_data_file, args=(sessionPath, recName, channelId, streamType, auxData))
					t.start()
					print("Thread %d started"%(k))
					threads.append(t)


				for t in threads:
					t.join()
				'''
				

				#with concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
				#	executor.map(write_data_file, [(sessionPath, recName, channelsIds[k].decode("utf-8"), streamType, (channelData[k, :] - ADZero) * (conversionFactor * 10.0**exponent))) for k in range(numberChannels)])

				'''
				for k in range(numberChannels):
					channelId = channelsIds[k].decode("utf-8")
					auxData = (channelData[k, :] - ADZero) * (conversionFactor * 10.0**exponent)
					write_data_file(sessionPath, recName, channelId, streamType, auxData)
				'''

"""

py"multiplex"(preProcessedPath, filename, sessionName)