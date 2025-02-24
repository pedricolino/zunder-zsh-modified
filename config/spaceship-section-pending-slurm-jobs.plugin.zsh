#
# Pending Slurm Jobs section
#
# Show number of pending slurm jobs

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_PENDING_SLURM_JOBS_SHOW="${SPACESHIP_PENDING_SLURM_JOBS_SHOW=true}"
SPACESHIP_PENDING_SLURM_JOBS_ASYNC="${SPACESHIP_PENDING_SLURM_JOBS_ASYNC=true}"
SPACESHIP_PENDING_SLURM_JOBS_PREFIX="${SPACESHIP_PENDING_SLURM_JOBS_PREFIX="with "}"
SPACESHIP_PENDING_SLURM_JOBS_SUFFIX="${SPACESHIP_PENDING_SLURM_JOBS_SUFFIX=" "}"
SPACESHIP_PENDING_SLURM_JOBS_SYMBOL="${SPACESHIP_PENDING_SLURM_JOBS_SYMBOL=""}"
SPACESHIP_PENDING_SLURM_JOBS_COLOR="${SPACESHIP_PENDING_SLURM_JOBS_COLOR=red}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show pending_slurm_jobs status
# spaceship_ prefix before section's name is required!
# Otherwise this section won't be loaded.
spaceship_pending_slurm_jobs() {
  # If SPACESHIP_PENDING_SLURM_JOBS_SHOW is false, don't show pending_slurm_jobs section
  [[ $SPACESHIP_PENDING_SLURM_JOBS_SHOW == false ]] && return

  # Count the number of running Slurm jobs for the current user
  local pending_job_count=$(squeue -u "$USER" --state=PD | wc -l)
  
  # Adjust count because `squeue` output includes a header line
  (( pending_job_count > 1 )) && pending_job_count=$((pending_job_count - 1)) || pending_job_count=0

  # If no jobs are running, don't show the section
  [[ $pending_job_count -eq 0 ]] && return



  # Display pending_slurm_jobs section
  # spaceship::section utility composes sections. Flags are optional
  spaceship::section::v4 \
    --color "$SPACESHIP_PENDING_SLURM_JOBS_COLOR" \
    --prefix "$SPACESHIP_PENDING_SLURM_JOBS_PREFIX" \
    --suffix "$SPACESHIP_PENDING_SLURM_JOBS_SUFFIX" \
    --symbol "$SPACESHIP_PENDING_SLURM_JOBS_SYMBOL" \
    "$pending_job_count"
}
