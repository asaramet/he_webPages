#!/bin/bash
# Allocate one node
#SBATCH --nodes=1
# Number of program instances to be executed
#SBATCH --ntasks-per-node=40
# Queue class https://wiki.bwhpc.de/e/BwUniCluster_2.0_Batch_Queues
#SBATCH --partition=single
# Maximum run time of job
#SBATCH --time=8:00:00
# Give job a reasonable name
#SBATCH --job-name=cfx5-job
# File name for standard output (%j will be replaced by job id)
#SBATCH --output=cfx-test-%j.out
# File name for error output
#SBATCH --error=cfx-test-%j.err
# send an e-mail when a job begins, aborts or ends
#SBATCH --mail-type=ALL
# e-mail address specification
#SBATCH --mail-user=[HE_USER_ID]@hs-esslingen.de

echo "Starting at "
date

# load the software package
module load cae/ansys/19.2

HE_USER_ID=[HE_USER_ID]
HE_COM_SERVER='comserver.hs-esslingen.de'
HE_LIZENZ_SERVER='lizenz-ansys.hs-esslingen.de'
INPUT='cfx_example.def'

# start a SSH tunnel, creating a control socket.
DEAMON_PORT=49296
SOCKET_NAME="cfx-socket"
[[ -f ${SOCKET_NAME} ]] && rm -f ${SOCKET_NAME}
ssh -M -S ${SOCKET_NAME} -fnNT -L 2325:${HE_LIZENZ_SERVER}:2325 \
-L 1055:${HE_LIZENZ_SERVER}:1055 \
-L ${DEAMON_PORT}:${HE_LIZENZ_SERVER}:${DEAMON_PORT} \
${HE_USER_ID}@${HE_COM_SERVER}

# export license environment variables
export ANSYSLMD_LICENSE_FILE=1055@localhost
export ANSYSLI_SERVERS=2325@localhost

cfx5solve -batch -def $INPUT -part=${SLURM_NTASKS} -start-method "Intel MPI Local Parallel"

# close the SSH control socket
ssh -S ${SOCKET_NAME} -O exit ${HE_USER_ID}@${HE_COM_SERVER}

echo "Run completed at "
date
