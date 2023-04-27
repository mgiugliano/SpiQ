# QSpikeTools 2.0

**QSpikeTools 2.0** is a generic framework for preliminary preprocessing and analysis of neuronal activities recorded by substrate microelectrode arrays. It is mostly programmed in **Julia** and is designed to exploit the advantages of **parallel** computing in multi-core computers and **clusters** of computers.

It is based on the original work by

**Mahmud M, Pulizzi R, Vasilaki E and Giugliano M (2014).** *QSpike tools: a generic framework for parallel batch preprocessing of extracellular neuronal signals recorded by substrate microelectrode arrays.* Front. Neuroinform. 8:26. doi: [10.3389/fninf.2014.00026](https://doi.org/10.3389/fninf.2014.00026)

## Installation
QSpikeTools 2.0 has been developed for **Julia 1.3.0** and Linux systems. You can download Julia from their [official website](https://julialang.org/downloads/). To install it you just need to download the *.zip* corresponding to your operating system (i.e. Linux x86, Linux x64, etc) and extract the folder *julia-1.3.0* in your computer, preferably in your home directory (i.e. /home/my_user_name).

Afterwards, clone QSpikeTools repository in any location of your computer and open a terminal there.

By default, QSpikeTools assumes that Julia is located at your home directory (i.e. /home/my_user_name/julia-1.3.0). If this is not the case, please change line 18 at INSTALL.sh:
> JULIA=*your_julia_directory*

Once Julia is installed, QSpikeTools 2.0 and all its dependencies can be installed by running:
> bash INSTALL.sh

This will create a separated Julia environment for QSpikeTools with all the requirements, as defined in the *Project.toml* and *Manifest.toml* files, including instances of the *h5py* and *matplotlib* Python libraries specific for this environment and independent of any other libraries of your computer.

## Usage
If you are using a **single computer**:
> bash single_launcher.sh *data_path*

If you are using a **qsub (PBS)** managed cluster:
> bash qsub_launcher.sh *data_path*

If you are using a **Slurm** managed cluster:
> bash slurm_launcher.sh *data_path*

Where *data_path* is the folder that contains the input data, and where the output results will be generated (e.g. /home/my_user_name/dataFolder). Inside this directory there **must** exist a folder named **INPUT_FILES** (e.g. /home/my_user_name/dataFolder/INPUT_FILES), where the input *.mcd* and *.h5* files are located. Output results will be saved in folders **OUTPUT_PREPROCESSED_FILES** (e.g. /home/my_user_name/dataFolder/OUTPUT_PREPROCESSED_FILES) and **OUTPUT_PROCESSED_FILES** (e.g. /home/my_user_name/dataFolder/OUTPUT_PROCESSED_FILES), that will be created by QSpikeTools if they do not already exist.

In case of using a cluster, some parameters (i.e. number of cores per job, maximum time, queue/partition) are fixed to specific values in the *launcher* scripts. If a different configuration is needed for your cluster just modify the corresponding *launcher*.

The **preprocessing** stage uses the parameters from the *parameters.txt* file, where each line represents:

- `detect_fmin` : high pass filter for detection (Hz). Default = 400
- `detect_fmax` : low pass filter for detection (Hz). Default = 3000
- `sort_fmin` : high pass filter for sorting (Hz). Default = 400
- `sort_fmax` : low pass filter for sorting (Hz). Default = 3000
- `stdmin` : minimum threshold for detection. Default = 5
- `stdmax` : maximum threshold for detection. Default = 10000
- `detect` : type of threshold ("neg", "pos", "both"). Default = both
- `w_pre` : number of pre-event data points stored. Default = 20
- `w_post` : number of post-event data points stored. Default = 44
- `ref` : detector dead time (ms). Default = 2.5
- `int_factor` : interpolation factor. Default = 2
- `interpolation` : interpolation with cubic splines ("n","y"). Default = y
- `savingxf` : saving xf files? ("n","y"). Default = n
- `filterxf` : filter the data or not at all? ("n","y"). Default = y

## Documentation
More detailed documentation on the scripts and functions of this program can be found in the **doc** folder.

## Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com
- Manuel Reyes-Sanchez - mnrs94@gmail.com

### Original software authors
- Michele Giugliano - mgiugliano@gmail.com
- Mufti Mahmud - https://sites.google.com/site/muftimahmud/
- Rocco Pulizzi - https://sites.google.com/site/roccoplz/
- Eleni Vasilaki - https://www.sheffield.ac.uk/dcs/people/academic/evasilaki/profile
