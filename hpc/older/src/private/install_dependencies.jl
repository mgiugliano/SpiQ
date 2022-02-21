"""
Script that activates a Julia environment for QSpikeTools and installs the dependencies found in Manifest.toml.

Due to problems with the package HDF5 for Julia when reading strings from H5Compounds, h5py is 
used instead in some scripts. Conda.jl will install h5py for this Julia environment specifically.

# Examples
```jldoctest
julia --project=Project.toml src/private/install_dependencies.jl
```

# Authors:
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com
"""

# Install all Julia dependencies from the Manifest.toml
using Pkg;
Pkg.activate();
Pkg.instantiate();

# Install all Python dependencies and force Julia to use this version
using Conda;
Conda.add("h5py");
Conda.add("matplotlib");
ENV["PYTHON"]="";
Pkg.build("PyCall");

# Precompile all the packages
Pkg.precompile();

