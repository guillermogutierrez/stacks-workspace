export BASE_URL=http://localhost:9000

export RED=$(tput setaf 1)
export GREEN=$(tput setaf 2)
export YELLOW=$(tput setaf 3)
export BLUE=$(tput setaf 4)
export NORMAL=$(tput sgr0)

export SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export WORKSPACE_DIR=${SCRIPT_DIR}/..

export STACKS_MODULES_PROPERTIES=('stacks.core.api.version' 'stacks.core.cqrs.version' 'stacks.core.messaging.version' 'stacks.azure-servicebus.version' 'stacks.core.commons.version' 'stacks.azure.cosmos.version')