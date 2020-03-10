#!/bin/bash

# Allocate nodes
#SBATCH --nodes=2
# Number of program instances to be executed
#SBATCH --tasks-per-node=20
# Queue class
#SBATCH --partition=normal
# Maximum run time of job
#SBATCH --time=4:00:00
# Give job a reasonable name
#SBATCH --job-name=openfoam
# File name for standard output (%j will be replaced by job id)
#SBATCH --output=logs-%j.out
# File name for error output
#SBATCH --error=logs-%j.err
# send an e-mail when a job begins, aborts or ends
#SBATCH --mail-type=ALL
# e-mail address specification
#SBATCH --mail-user=<HE_USER_ID>@hs-esslingen.de

# Initialize the job
FOAM_VERSION="7"
MPIRUN_OPTIONS="--bind-to core --map-by core -report-bindings"

module load "cae/openfoam/${FOAM_VERSION}"
source ${FOAM_INIT}

echo "Starting at "
date

cd ${SLURM_SUBMIT_DIR}

# Source tutorial run functions
echo ${WM_PROJECT_DIR}
. ${WM_PROJECT_DIR}/bin/tools/RunFunctions

runApplication blockMesh

runApplication decomposeParHPC -copyZero

mpirun ${MPIRUN_OPTIONS} snappyHexMesh -overwrite -parallel &> log.snappyHexMesh

## Check decomposed mesh
mpirun ${MPIRUN_OPTIONS} checkMesh -allGeometry -allTopology -meshQuality -parallel &> log.checkMesh

mpirun ${MPIRUN_OPTIONS} patchSummary -parallel &> log.patchSummary

mpirun ${MPIRUN_OPTIONS} $(getApplication) -parallel &> log.$(getApplication) &&

runApplication reconstructParHPC &&

rm -rf processor*

echo "Run completed at "
date
