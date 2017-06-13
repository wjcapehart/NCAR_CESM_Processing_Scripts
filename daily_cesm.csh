#!/bin/csh
#
# LSF batch script to run the test MPI code
#
#BSUB -P USDM0004          # Project number 99999999
#BSUB -a poe               # select poe
#BSUB -n 1                 # number of total (MPI) tasks
#BSUB -R "span[ptile=1]"   # run a max of 32 tasks per node
#BSUB -J daily_cesm        # job name
#BSUB -o daily_cesm_%J.out # output filename
#BSUB -e daily_cesm_%J.err # error filename
#BSUB -W 24:00             # wallclock time
#BSUB -q geyser            # queue
#BSUB -B
#BSUB -N



#
#source /usr/local/lsf/conf/cshrc.lsf
#
echo "Show Show Here we go!"
#
cd /glade/u/home/capehart/code/NCAR_CESM_Processing_Scripts/
#
#
source /glade/u/apps/opt/lmod/4.2.1/init/tcsh
#
module load ncl
module load nco

ncl /glade/u/home/capehart/code/NCAR_CESM_Processing_Scripts/CONUS_Local_CESM_85_45_Daily.ncl >& /glade/u/home/capehart/code/NCAR_CESM_Processing_Scripts/CONUS_Local_CESM_85_45_Daily.txt



echo
echo ===========================================
echo


echo
echo ===========================================
echo

echo "We are Out of Here Like Vladimir"
exit
