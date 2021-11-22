function importModule {
    REPO=$1
    figlet ${REPO}
    git clone https://github.com/amido/${REPO}.git ${WORKSPACE_DIR}/repos/${REPO}
    ln -s ${WORKSPACE_DIR}/repos/${REPO}/     ${WORKSPACE_DIR}/modules/${REPO}
}

function importWorkload {
    REPO=$1
    figlet ${REPO}
    git clone https://github.com/amido/${REPO}.git ${WORKSPACE_DIR}/repos/${REPO}
    ln -s ${WORKSPACE_DIR}/repos/${REPO}/     ${WORKSPACE_DIR}/workloads/${REPO}
}

. ./set_env.sh

mkdir ${WORKSPACE_DIR}/repos

mkdir ${WORKSPACE_DIR}/modules

mkdir ${WORKSPACE_DIR}/workloads

importModule stacks-java-module-parent

importModule stacks-java-azure-cosmos

importModule stacks-java-azure-servicebus

importModule stacks-java-core-api

importModule stacks-java-core-commons

importModule stacks-java-core-cqrs

importModule stacks-java-core-messaging

importWorkload stacks-java-cqrs-events

importWorkload stacks-java-cqrs

importWorkload stacks-java