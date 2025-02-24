#
# Pending Slurm Jobs section
#
# Show number of running pending jobs

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_SLURM_JOBS_SHOW="${SPACESHIP_SLURM_JOBS_SHOW=true}"
SPACESHIP_SLURM_JOBS_ASYNC="${SPACESHIP_SLURM_JOBS_ASYNC=true}"
SPACESHIP_SLURM_JOBS_PREFIX="${SPACESHIP_SLURM_JOBS_PREFIX="with "}"
SPACESHIP_SLURM_JOBS_SUFFIX="${SPACESHIP_SLURM_JOBS_SUFFIX=" "}"
SPACESHIP_SLURM_JOBS_SYMBOL="${SPACESHIP_SLURM_JOBS_SYMBOL=""}"
SPACESHIP_SLURM_JOBS_COLOR="${SPACESHIP_SLURM_JOBS_COLOR=green}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show slurm_jobs status
# spaceship_ prefix before section's name is required!
# Otherwise this section won't be loaded.
spaceship_slurm_jobs() {
  # If SPACESHIP_SLURM_JOBS_SHOW is false, don't show slurm_jobs section
  [[ $SPACESHIP_SLURM_JOBS_SHOW == false ]] && return

  # Count the number of running Slurm jobs for the current user
  local job_count=$(squeue -u "$USER" --state=R | wc -l)
  
  # Adjust count because `squeue` output includes a header line
  (( job_count > 1 )) && job_count=$((job_count - 1)) || job_count=0

  # If no jobs are running, don't show the section
  [[ $job_count -eq 0 ]] && return



  # Display slurm_jobs section
  # spaceship::section utility composes sections. Flags are optional
  spaceship::section::v4 \
    --color "$SPACESHIP_SLURM_JOBS_COLOR" \
    --prefix "$SPACESHIP_SLURM_JOBS_PREFIX" \
    --suffix "$SPACESHIP_SLURM_JOBS_SUFFIX" \
    --symbol "$SPACESHIP_SLURM_JOBS_SYMBOL" \
    "$job_count"
}
