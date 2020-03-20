#!/bin/bash
# Allocate one node
#SBATCH --nodes=1
# Number of program instances to be executed
#SBATCH --ntasks-per-node=28
# Queue class https://wiki.bwhpc.de/e/BwUniCluster_2.0_Batch_Queues
#SBATCH --partition=single
# Maximum run time of job
#SBATCH --time=2:00:00
# Give job a reasonable name
#SBATCH --job-name=fluent-test
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

# start a SSH tunnel, creating a control socket.
DEAMON_PORT=49296
ssh -M -S ansys-socket -fnNT -L 2325:lizenz-ansys.hs-esslingen.de:2325 \
-L 1055:lizenz-ansys.hs-esslingen.de:1055 \
-L ${DEAMON_PORT}:lizenz-ansys.hs-esslingen.de:${DEAMON_PORT} \
${HE_USER_ID}@comserver.hs-esslingen.de

# export license environment variables
export ANSYSLMD_LICENSE_FILE=1055@localhost
export ANSYSLI_SERVERS=2325@localhost

# Create the hosts file 'fluent.hosts'
HOSTS="fluent.hosts"
scontrol show hostname ${SLURM_JOB_NODELIST} > ${HOSTS}

# set number of nodes variable
nrNodes=${SLURM_NTASKS}

echo "number of nodes: $nrNodes"

# run fluent in parallel, where fluentJournal.jou is a fluent Journal File
# more about creating Journal Files:
# https://www.sharcnet.ca/Software/Ansys/16.2.3/en-us/help/flu_ug/flu_ug_JournalFile.html

echo "Starting fluent..."
fluent 3d -t$nrNodes -g -env -pib -mpi=intel -cnf=fluent.hosts -i fluentJournal.jou &&

# close the SSH control socket
ssh -S ansys-socket -O exit ${HE_USER_ID}@comserver.hs-esslingen.de

[[ -f ${HOSTS} ]] && rm -rf ${HOSTS}

echo "Run completed at "
date
