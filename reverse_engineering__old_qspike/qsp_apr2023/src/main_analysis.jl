"""
Script that launches the analysis of the preprocessed data. Several figures and a .tex file will be generated with the results.

### Arguments
- `preprocessedTag::String` : general path that contains the preprocessed data.
- `processedTag::String` : general path were the results of the analysis will be saved.
- `expName::String` : stream name.

### Examples
```jldoctest
julia --project=../Project.toml main_analysis.jl "data/OUTPUT_PREPROCESSED_FILES" "data/OUTPUT_PROCESSED_FILES" "trace1"
```

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com
"""

include("analysis/launch_analyses.jl")

preprocessedTag = ARGS[1];
processedTag = ARGS[2];
expName = ARGS[3];

@time launch_analyses(preprocessedTag, processedTag, expName);