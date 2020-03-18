#!/bin/bash
# Allocate one node
#SBATCH --nodes=4
# Number of program instances to be executed
#SBATCH --tasks-per-node=80
# Queue class https://wiki.bwhpc.de/e/BwUniCluster_2.0_Batch_Queues
#SBATCH --partition=multiple
# Maximum run time of job
#SBATCH --time=8:00:00
# Give job a reasonable name
#SBATCH --job-name=cfx5-job
# File name for standard output (%j will be replaced by job id)
#SBATCH --output=fluent-test-%j.out
# File name for error output
#SBATCH --error=fluent-test-%j.err
# send an e-mail when a job begins, aborts or ends
#SBATCH --mail-type=ALL
# e-mail address specification
#SBATCH --mail-user=<HE_USER_ID>@hs-esslingen.de

echo "Starting at "
date

# load the software package
module load cae/ansys/19.2

HE_USER_ID=<HE_USER_ID>
CASE_NAME="cfx_example.def"
INPUT="${SLURM_SUBMIT_DIR}/${CASE_NAME}"

# start a SSH tunnel, creating a control socket.
DEAMON_PORT=49296
SOCKET_NAME="cfx-socket"
[[ -f ${SOCKET_NAME} ]] && rm -f ${SOCKET_NAME}
ssh -M -S ${SOCKET_NAME} -fnNT -L 2325:lizenz-ansys.hs-esslingen.de:2325 \
-L 1055:lizenz-ansys.hs-esslingen.de:1055 \
-L ${DEAMON_PORT}:lizenz-ansys.hs-esslingen.de:${DEAMON_PORT} \
${HE_USER_ID}@comserver.hs-esslingen.de

# export license environment variables
export ANSYSLMD_LICENSE_FILE=1055@localhost
export ANSYSLI_SERVERS=2325@localhost

# create hostslist
export jms_nodes=`srun hostname -s`
export hostslist=`echo $jms_nodes | sed "s/ /,/g"`

# set number of nodes variable
nrNodes=${SLURM_JOB_NUM_NODES}
echo "number of nodes: $nrNodes"

cfx5solve -batch -def $INPUT -par-host-list ${hostslist} -part ${nr_nodes} \
-start-method "Intel MPI Distributed Parallel"

# close the SSH control socket
ssh -S ${SOCKET_NAME} -O exit ${HE_USER_ID}@comserver.hs-esslingen.de

echo "Run completed at "
date
