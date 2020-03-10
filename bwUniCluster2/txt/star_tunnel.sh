#!/bin/bash
# Allocate one node
#SBATCH --nodes=1
# Number of program instances to be executed
#SBATCH --tasks-per-node=8
# Queue class
#SBATCH --partition=normal
# Maximum run time of job
#SBATCH --time=2:00:00
# Give job a reasonable name
#SBATCH --job-name=starccm-first-run
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
CASE_NAME=test_case.sim
INPUT=${SLURM_SUBMIT_DIR}/${CASE_NAME}
HE_USER_ID=<HE_USER_ID>

# create hostslist
export jms_nodes=`srun hostname -s`
export hostslist=`echo $jms_nodes | sed "s/ /,/g"`

# load the available STAR-CCM+ module
module load cae/starccm+/$VERSION

# start a SSH tunnel, creating a control socket.
DEAMON_PORT=49296
SOCKET_NAME='starccm-socket'
[[ -f ${SOCKET_NAME} ]] && rm -f ${SOCKET_NAME}
ssh -MS ${SOCKET_NAME} -fnNT -L 1999:lizenz-cd-adapco.hs-esslingen.de:1999 \
-L ${DEAMON_PORT}:lizenz-cd-adapco.hs-esslingen.de:${DEAMON_PORT} \
${HE_USER_ID}@comserver.hs-esslingen.de

# set license variables: server address and POD key string
export CDLMD_LICENSE_FILE=1999@flex.cd-adapco.com;1999@localhost
export LM_PROJECT=<POD_KEY>

# calculate number of nodes
np=${SLURM_JOB_NUM_NODES}
echo "number of nodes: $np"

# start parallel star-ccm+ job
starccm+ -power -np $np -on ${hostslist} -batch $INPUT

# close the SSH control socket
ssh -S ${SOCKET_NAME} -O exit ${HE_USER_ID}@comserver.hs-esslingen.de

echo "Run completed at "
date
