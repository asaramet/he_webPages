#!/bin/bash
# Allocate one node
#SBATCH --nodes=1
# Number of program instances to be executed
#SBATCH --ntasks=40
# Queue class https://wiki.bwhpc.de/e/BwUniCluster_2.0_Batch_Queues
#SBATCH --partition=single
# Maximum run time of job
#SBATCH --time=4:00:00
# Give job a reasonable name
#SBATCH --job-name=starccm-single
# File name for standard output (%j will be replaced by job id)
#SBATCH --output=logs-%j.out
# File name for error output
#SBATCH --error=logs-%j.err
# send an e-mail when a job begins, aborts or ends
#SBATCH --mail-type=ALL
# e-mail address specification
#SBATCH --mail-user=<HE_USER_ID>@hs-esslingen.de

echo "Starting at "
date

# specify the STAR-CCM+ version to load (available on the cluster)
VERSION="2019.2"

# specify sim case file name
INPUT=test_case.sim

# load the available STAR-CCM+ module
module load cae/star-ccm+/${VERSION}

# set license variables: server address and POD key string
export CDLMD_LICENSE_FILE=1999@flex.cd-adapco.com
export LM_PROJECT=<POD_KEY>

# calculate number of nodes
np=${SLURM_NTASKS}
echo "number of nodes: $np"

# start parallel star-ccm+ job
starccm+ -power -np $np -batch $INPUT

echo "Run completed at "
date
