## TRIVIAL COMMANDS ===========================================================
alias e="exit"
alias b="cd .."
alias ta="tmux attach"
alias less="less -SN" # do not wrap lines by default. Type -S in less to activate. Show line numbers.
alias zless="zless -S"

# if lsd is installed, use it, otherwise use ls
if command -v lsd &> /dev/null
then
    alias ll="lsd -l --date relative"
else
    alias ll="ls -lh"
fi


## SLURM COMMANDS =============================================================
alias show_partition_limits='sacctmgr list QOS format="Name,MaxWall,MaxTRESPU%20"'
# Cancel all Snappy jobs (they are called snakejob in the queue)
alias cancel_snakejobs="squeue -u $USER | grep "snakejob" | awk '{print $1}' | xargs scancel"

### START SRUN SESSIONS -------------------------------------------------------
# Low resources, does not matter if it stays alive for long
alias s="srun --time 7-00 --mem=8G --ntasks=4 --immediate=30 --pty zsh -i"
# Long, low resources
alias sl="srun --time 14-00 --mem=8G --ntasks=4 --immediate=30 --pty zsh -i"
# Long, powerful
alias sp="srun --time 7-00 --mem=64G --ntasks=16 --immediate=30 --pty zsh -i"
# Very powerful but short-lived. Just below transition to high-mem partition.
alias spp="srun --time 1-00 --mem=199G --ntasks=32 --immediate=30 --pty zsh -i"
# Start a srun session for and with VSCode tunnel
alias vsc="srun --time 1-00 --mem=200G --ntasks=32 --immediate=30 --pty zsh -i -c 'code tunnel --disable-telemetry'"

### OBSERVE THE JOBS QUEUE ----------------------------------------------------
# Keep monitoring the queue
alias w1="watch --differences -n 10 squeue --me"
alias w6="watch --differences -n 60 squeue --me"
# where am I? Login node?
alias hn="hostname"
alias wai="hostname" # Stands for "Where am I?"
# Use the sq function from MShTools with the user set to the current user
alias sq="sq.sh -u $USER -p 0"

## CONDA AND MAMBA RELATED COMMANDS ===========================================
alias ca="conda activate $1"
alias cas="conda activate snakemake-vanilla"
alias cda="conda deactivate"
alias ma="mamba activate $1"
alias mas="mamba activate snakemake-vanilla"
alias mda="mamba deactivate"

## SNAKEMAKE RELATED COMMANDS =================================================
# submit job and watch queue
alias sbw="snakemake --unlock; sbatch pipeline_job.sh; watch -n 10 squeue --me"
# submit looping job and watch queue
alias sbwl="snakemake --unlock; sbatch pipeline_job_loop.sh; watch -n 10 squeue --me"
alias snakeunlock="snakemake --unlock"
alias snaketest="snakemake --use-conda --conda-frontend conda -c 4 -n --rerun-incomplete --rerun-triggers mtime 2>&1 | tee snaketest.log"
alias snaketest_nologfile="snakemake --use-conda --conda-frontend conda -c 4 -n --rerun-incomplete --rerun-triggers mtime"

## GIT RELATED COMMANDS =======================================================
alias gitc="git commit -v"
alias gits="git status"
alias gitd="git diff"

## SWITCH TO SPECIFIC FOLDERS =================================================
alias gotomh="pushd ~/work/project_symlinks/cnv-panel/"
alias gotosignoc="pushd ~/work/project_symlinks/sign-oc_raw_data/"
alias gototest="pushd ~/work/test_cnakepit_conda_env_option/cnakepit"
alias gotocrc="pushd ~/work/project_symlinks/crc"
alias gotopediatric="pushd ~/work/project_symlinks/pediatric-oncology-tumor-lines"

## MISCELLANEOUS ===============================================================
# github copilot in the terminal
alias ai="gh copilot suggest -t shell "
# reinstall zunder-zsh, for debugging or updating
alias reinstall_zunderzsh="rm -rf ~/.config/zunder-zsh && ~/zunder-zsh-modified/install.sh -y && exec zsh"
