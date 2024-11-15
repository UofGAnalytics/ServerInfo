#!/bin/bash
#SBATCH --job-name = slurm_demo                     # Job name
#SBATCH --partition =  maths                        # Name of the partition (queue)
#SBATCH --nodes = 1                                 # Number of nodes
#SBATCH --ntasks = 1                                # Number of tasks (processes)
#SBATCH --cpus-per-task = 1                         # Number of CPU cores per task
#SBATCH --output=slurm-%j.out                       # Output file (stdout and stderr combined)
#SBATCH --time = 1:30:00                            # Wall time (hh:mm:ss)
#SBATCH --mail-user = a.coats.1@research.gla.ac.uk  # Email address for notifications
#SBATCH --mail-type = ALL                           # Send email on job abort, begin, and end

# Change to the directory from which the job was submitted
cd $SLURM_SUBMIT_DIR

# Run the R script
R CMD BATCH /home/staff2/acoats/slurm_demo.R