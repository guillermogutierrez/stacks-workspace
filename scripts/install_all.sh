#!/usr/bin/env bash
set -e

. ./set_env.sh

# Build the parent
figlet parent
mvn install -f ${WORKSPACE_DIR}/modules/stacks-java-module-parent/pom.xml

# Build the modules in order

figlet commons
mvn install -f ${WORKSPACE_DIR}/modules/stacks-java-core-commons/java/pom.xml

figlet cqrs
mvn install -f ${WORKSPACE_DIR}/modules/stacks-java-core-cqrs/java/pom.xml

figlet messaging
mvn install -f ${WORKSPACE_DIR}/modules/stacks-java-core-messaging/java/pom.xml

figlet api
mvn install -f ${WORKSPACE_DIR}/modules/stacks-java-core-api/java/pom.xml

figlet azure cosmos
mvn install -f ${WORKSPACE_DIR}/modules/stacks-java-azure-cosmos/java/pom.xml

figlet azure servicebus
mvn install -f ${WORKSPACE_DIR}/modules/stacks-java-azure-servicebus/java/pom.xml