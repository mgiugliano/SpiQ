struct MissingInfoException <: Exception
	var::String
end

Base.showerror(io::IO, e::MissingInfoException) = print(io, e.var, " not found");


"""
	info_file(preprocessedPath::String, expName::String, info::INFO)

Load the information of the stream stored in the file `preprocessedPath`/`expName`/`expName`_info.txt and save it in `info`.

### Arguments
- `preprocessedPath::String` : general path that contains the preprocessed data.
- `expName::String` : stream name.
- `info::INFO` : structure that stores the general information of the analysis.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com
"""

function info_file(preprocessedPath::String, expName::String, info::INFO)
	fname = string(preprocessedPath, expName, "_info.txt");

	if isfile(fname)
	    fp = open(fname, "r");
	    lines = readlines(fp);
	    info.T = parse(Float64, lines[1]);
	    info.Ns = parse(Int, lines[2]);
	    info.sr = parse(Int, lines[3]);
	    close(fp);
	else
	    throw(MissingInfoException(fname));
	end
end
