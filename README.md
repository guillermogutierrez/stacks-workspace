# Stacks-workspace

## Scripts
### setup_workspace
Create your stacks workspace
### set_env
Defines env variables used across all the scripts
### test_workload
Run one of the stacks workloads in a container and executes all functional tests
``` ./test_workload.sh -w <Stacks_Workload>```
where Stacks_workload can be:
- stacks-java
- stacks-java-cqrs
- stacks-java-cqrs-events
### test_archetype
Creates an archetype based on one of the stacks workloads, run a new application using the archetype in a container an executes all functional tests
``` ./test_archetype.sh -w <Stacks_Workload> -a <Stacks_Workload_Archetype> ```
where Stacks_workload can be:
- stacks-java
- stacks-java-cqrs
- stacks-java-cqrs-events
and Stacks_Workload_Archetype can be:
- stacks-api
- stacks-java-cqrs
- stacks-api-cqrs-events
