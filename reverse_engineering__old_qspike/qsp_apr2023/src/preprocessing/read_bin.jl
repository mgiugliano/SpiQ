"""
	read_bin(filename::String, N::Int) -> data::Array{Float64,1}

Read the binary data from an elec channel .dat file and returns it as a Julia vector.

### Arguments
- `filename::String` : full input file name.
- `N::Int` : number of samples of the file.

### Return
- `data::Array{Float64,1}` : vector with the data read from the file.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com
"""

function read_bin(filename::String, N::Int) 
    #data   = zeros(Float64, N, 1)
	data   = Float64[];
	sizehint!(data, N);
	resize!(data, N);
    stream = open(filename, "r");
    read!(stream, data);
    close(stream);
    return data;
end
