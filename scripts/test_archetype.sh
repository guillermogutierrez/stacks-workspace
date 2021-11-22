#!/bin/bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
WORKSPACE_DIR=${SCRIPT_DIR}/..

OPTIONS=":w:a:"

usage()
{
	set +x
	USAGE=$(cat <<- USAGE_STRING
		Usage: $(basename "${0}") [OPTION]...

		Required Arguments:
            -a location Required artifact to reference the archetype
            -w location Required workload to test
		Optional Arguments:
		USAGE_STRING
	)

	echo "${USAGE}"

	set -x
}

# Detect `--help`, show usage and exit
for var in "$@"; do
	if [ "${var}" == '--help' ]; then
		usage
		exit 0
	fi
done

while getopts "${OPTIONS}" option
do
	case "${option}" in
		# Required
        a  ) ARTIFACT_ID="${OPTARG}";;
		w  ) WORKLOAD="${OPTARG}";;

		\? ) echo "Unknown option: -${OPTARG}" >&2; exit 1;;
		:  ) echo "Missing option argument for -${OPTARG}" >&2; exit 1;;
		*  ) echo "Unimplemented option: -${option}. This is probably unintended." >&2; exit 1;;
	esac
done

. ./set_env.sh

ARCHETYPE_NAME=my-${WORKLOAD}-archetype
WORKLOAD_DIR=${SCRIPT_DIR}/../workloads/${WORKLOAD}
ARCHETYPE_ROOT_DIR=${SCRIPT_DIR}/../tests/
ARCHETYPE_DIR=${ARCHETYPE_ROOT_DIR}/${ARCHETYPE_NAME}
timestamp=$(date +"%Y%m%d-%H%M%S")

figlet -w 150 ${WORKLOAD}

printf "${BLUE}Create archetype"
printf '\n------------------------------------------------------------------------------------------------------------------------------------\n'
printf "${NORMAL}Generate archetype from project using the pom file \n ${GREEN} ${WORKLOAD_DIR}/java/pom.xml ${NORMAL}\n"

mvn -f ${WORKLOAD_DIR}/java/pom.xml \
    clean archetype:create-from-project \
    -DpropertyFile=${WORKLOAD_DIR}/java/archetype.properties \
    --quiet

printf "${NORMAL}Install archetype into local m2 repository using pom file \n ${GREEN} ${WORKLOAD_DIR}/java/target/generated-sources/archetype/pom.xml${NORMAL}\n"

mvn -f ${WORKLOAD_DIR}/java/target/generated-sources/archetype/pom.xml install --quiet

printf "${NORMAL}Create new project based on the archetype\n"

mvn archetype:generate \
    -DoutputDirectory=${ARCHETYPE_ROOT_DIR} \
    -DarchetypeGroupId='com.amido.stacks.workloads' \
    -DarchetypeArtifactId="${ARTIFACT_ID}-archetype" \
    -DarchetypeVersion='1.0.0-SNAPSHOT' \
    -DgroupId='org.test.stacks' \
    -DartifactId="${ARCHETYPE_NAME}" \
    -Dpackage='org.test.stacks.archetype' --quiet -B

printf "${NORMAL}New project ${GREEN} ${ARCHETYPE_NAME} has been created in \n ${GREEN} ${ARCHETYPE_ROOT_DIR}${ARCHETYPE_NAME} ${NORMAL}\n"

printf "${BLUE}Docker image"
printf '\n------------------------------------------------------------------------------------------------------------------------------------\n'
printf "${BLUE}Building image...${NORMAL}"

    chmod 755 ${ARCHETYPE_ROOT_DIR}${ARCHETYPE_NAME}/mvnw
    docker build -f ${ARCHETYPE_ROOT_DIR}/${ARCHETYPE_NAME}/Dockerfile \
        -t amido/${WORKLOAD}:${timestamp} \
        ${ARCHETYPE_ROOT_DIR}${ARCHETYPE_NAME}/

printf "Image ${GREEN}amido/${WORKLOAD}:${timestamp} ${NORMAL}build completed \n"

printf "\nStaring docker container with id: ${GREEN}"

    docker run -d -p 9000:9000 \
        -e AZURE_APPLICATION_INSIGHTS_INSTRUMENTATION_KEY \
        -e COSMOSDB_KEY \
        -v  ${WORKSPACE_DIR}/configs/application.yml:/application.yml \
        --name workload-${WORKLOAD} \
        amido/${WORKLOAD}:${timestamp}

printf "${NORMAL}\nWaiting for the container to be ready"

    while ! curl -s 'http://localhost:9000/health' > /dev/null
    do
        { printf "..." 
          sleep 1
        } 1>&2
    done

printf "${GREEN} Container ready for use \n"

printf "${BLUE}\n\nFunctional API tests"
printf "\n------------------------------------------------------------------------------------------------------------------------------------\n${NORMAL}"
    
    mvn -f ${WORKLOAD_DIR}/api-tests/pom.xml clean verify --quiet
    open ${WORKLOAD_DIR}/api-tests/target/site/serenity/index.html

printf "${GREEN}API Functional tests completed\n ${NORMAL}"

printf "${BLUE}\n\nFunctional Karate API tests"
printf "\n------------------------------------------------------------------------------------------------------------------------------------\n${NORMAL}"
    
    cd ${WORKLOAD_DIR}
    mvn -f api-tests-karate/pom.xml test
    open ${WORKLOAD_DIR}/api-tests-karate/target/surefire-reports/karate-summary.html

printf "${GREEN}API Functional Karate tests completed \n ${NORMAL}"

printf "${BLUE}\n\nTidy up environment"
printf "\n------------------------------------------------------------------------------------------------------------------------------------\n"

printf "${NORMAL}Stopping the container ${GREEN}"
    docker container stop workload-${WORKLOAD}

printf "${NORMAL}Removing the container ${GREEN}"
    docker container rm workload-${WORKLOAD}

printf "${GREEN}Container stopped and removed \n ${NORMAL}"
    rm -rf ${ARCHETYPE_DIR}

printf "${GREEN}Archetype folder removed \n ${ARCHETYPE_DIR}"