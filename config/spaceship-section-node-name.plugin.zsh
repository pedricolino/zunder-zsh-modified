#
# HPC node name section
#
# Display the current node's name

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_NODE_SHOW="${SPACESHIP_NODE_SHOW=true}"
SPACESHIP_NODE_ASYNC="${SPACESHIP_NODE_ASYNC=true}"
SPACESHIP_NODE_PREFIX="${SPACESHIP_NODE_PREFIX="on "}"
SPACESHIP_NODE_SUFFIX="${SPACESHIP_NODE_SUFFIX=" "}"
SPACESHIP_NODE_SYMBOL="${SPACESHIP_NODE_SYMBOL=""}"
SPACESHIP_NODE_COLOR="${SPACESHIP_NODE_COLOR=cyan}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show node status
# spaceship_ prefix before section's name is required!
# Otherwise this section won't be loaded.
spaceship_node_name() {
  # If SPACESHIP_NODE_SHOW is false, don't show node section
  [[ $SPACESHIP_NODE_SHOW == false ]] && return

  # get node name
  if command -v hostname 2>&1
  then
        local nodename=$(hostname | sed 's/.*hpc-//')
  fi

  # If empty, don't show the section
  [[ -z $nodename ]] && return



  # Display node section
  # spaceship::section utility composes sections. Flags are optional
  spaceship::section::v4 \
    --color "$SPACESHIP_NODE_COLOR" \
    --prefix "$SPACESHIP_NODE_PREFIX" \
    --suffix "$SPACESHIP_NODE_SUFFIX" \
    --symbol "$SPACESHIP_NODE_SYMBOL" \
    "$nodename"
}
