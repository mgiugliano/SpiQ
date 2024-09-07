#
# SpiQ library - Julia Version
#
# Prototype of the SpiQ library for reading data from the
# 3BRAIN CMOS-MEA system.
#
# The library is written in Python and uses the h5py library
# to read the data from the HDF5 file format, numpy, and json.
#
# First version: Michele Giugliano, Sep 2024, based on
# the code by Irene Incerti, May 2024.
#

using HDF5, JSON


function get_chan_n(row, col)
    # get the decorated channel name (i.e., the
    # linear "coordinate") from row & col decorated
    # names (i.e. spatial "coordinates")

    M = 64 # CMOS MEAs are 64x64 arrays (default)

    # Note (by hypothesis):
    # row and col are 1-based indexes (1..64)
    # while we return a 1-based index (1..4096)

    return M * (row - 1) + col # 1-based index
end
#-----------------------------------------------------

function get_row_col(chan_n)
    # get the row and column decorated names (i.e., the
    # spatial "coordinates") from the decorated channel name
    # (i.e. the linear "coordinate")

    M = 64 # CMOS MEAs are 64x64 arrays (default)

    # Note (by hypothesis):
    # row and col are 1-based indexes (1..64)
    # while we return a 0-based index (0..4095)

    row = (chan_n ÷ M) + 1
    col = (chan_n % M) + 1

    return row, col
end
#-----------------------------------------------------

function DA_conv(digData, MinAnVal, MaxAnVal, MaxDigVal, Scale)
    # convert the digital data to analog data by:
    # An = (Dig / MaxDig) * (MaxAn - MinAn) + MinAn
    # and then (proportional) scaling it by Scale

    return Scale .* ((digData / MaxDigVal) * (MaxAnVal - MinAnVal) .+ MinAnVal)
end
#-----------------------------------------------------

function read_brw_data(fname, row, col, tstart, tend)
    # read the data from the file and return the time and the data
    # for the specified row and column, in the time range [
    # tstart, tend] (in ms)

    N = 4096 # CMOS MEAs are 64x64 arrays (default)

    # open the hdf5 file as read-only
    f = h5open(fname, "r")

    # get settings data structure
    info = JSON.parse(f["ExperimentSettings"][1])

    # get the sampling interval from file, in ms
    dt = 1000.0 / info["TimeConverter"]["FrameRate"]

    # get digital to analog conversion parameters
    MinAnVal = info["ValueConverter"]["MinAnalogValue"]
    MaxAnVal = info["ValueConverter"]["MaxAnalogValue"]
    MaxDigVal = info["ValueConverter"]["MaxDigitalValue"]
    ScaleFact = info["ValueConverter"]["ScaleFactor"]

    # access (default) data stream Well_A1
    digData = f["Well_A1"]["Raw"];

    # get the channel number
    chan_n = get_chan_n(row, col);

    K = length(digData) # number of samples
    Tmax = K/N * dt # total time in ms

    # convert the time range to indexes
    # tstart and tend are in ms and > 0
    tstart_idx = chan_n + convert(Int64,round(tstart / dt)) * N
    tend_idx = chan_n + convert(Int64, round(tend / dt)) * N

    tstart_idx = maximum([0, minimum([K, tstart_idx])])
    tend_idx = minimum([K, tend_idx])

    chan = digData[tstart_idx:N:tend_idx]

    output = DA_conv(chan, MinAnVal, MaxAnVal, MaxDigVal, ScaleFact);

    # get the time vector (in ms) of same length as output
    time = zeros(length(output));
    for i in 1:length(output)
        time[i] = tstart + i * dt
    end

    # close the file
    close(f)

    return time, output
end
#-----------------------------------------------------
