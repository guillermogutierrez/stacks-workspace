#!/bin/bash
# ./parse_pipelines.sh -d stacks-java-module-parent    -b feat/groupId-rename
# ./parse_pipelines.sh -d stacks-java-core-commons     -b feat/groupId-rename
# ./parse_pipelines.sh -d stacks-java-core-messaging   -b feat/groupId-rename
# ./parse_pipelines.sh -d stacks-java-core-cqrs        -b feat/groupId-rename
# ./parse_pipelines.sh -d stacks-java-core-api         -b feat/groupId-rename
# ./parse_pipelines.sh -d stacks-java-core-cqrs        -b feat/groupId-rename
# ./parse_pipelines.sh -d stacks-java-azure-cosmos     -b feat/groupId-rename
# ./parse_pipelines.sh -d stacks-java-azure-servicebus -b feat/groupId-rename


./update_stacks_dependencies.sh -d stacks-java-module-parent    -b feat/groupId-rename
./update_stacks_dependencies.sh -d stacks-java-core-commons     -b feat/groupId-rename
./update_stacks_dependencies.sh -d stacks-java-core-messaging   -b feat/groupId-rename
./update_stacks_dependencies.sh -d stacks-java-core-cqrs        -b feat/groupId-rename
./update_stacks_dependencies.sh -d stacks-java-core-api         -b feat/groupId-rename
./update_stacks_dependencies.sh -d stacks-java-core-cqrs        -b feat/groupId-rename
./update_stacks_dependencies.sh -d stacks-java-azure-cosmos     -b feat/groupId-rename
./update_stacks_dependencies.sh -d stacks-java-azure-servicebus -b feat/groupId-rename