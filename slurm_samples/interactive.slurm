#!/usr/bin/env bash

# Modify it according to your needs. It means:
#
# "asks for 1 CPU on a node, either in regular1 or in regular2, for 30 minutes, with 2GB of RAM,
# and launch bash interactivelu
#

# Remember:
# - make it executable ($ chmod +x interactive.slurm)
# - launch it directly ($ ./interactive.slurm)
#

srun --partition=regular1,regular2 --time=00:30:00 --ntasks=1 --cpus-per-task=1 --nodes=1 --mem=2GB --pty bash -i


