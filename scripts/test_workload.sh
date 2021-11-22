#!/bin/bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
WORKSPACE_DIR=${SCRIPT_DIR}/..

OPTIONS=":w:"

usage()
{
	set +x
	USAGE=$(cat <<- USAGE_STRING
		Usage: $(basename "${0}") [OPTION]...

		Required Arguments:
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
		w  ) WORKLOAD="${OPTARG}";;

		\? ) echo "Unknown option: -${OPTARG}" >&2; exit 1;;
		:  ) echo "Missing option argument for -${OPTARG}" >&2; exit 1;;
		*  ) echo "Unimplemented option: -${option}. This is probably unintended." >&2; exit 1;;
	esac
done

. ./set_env.sh

figlet -w 150 ${WORKLOAD}

WORKLOAD_DIR=${SCRIPT_DIR}/../workloads/${WORKLOAD}

export BASE_URL=http://localhost:9000

timestamp=$(date +"%Y%m%d-%H%M%S")

cd ${WORKLOAD_DIR}/java/

printf "${BLUE}Docker image"
printf '\n------------------------------------------------------------------------------------------------------------------------------------\n'
printf "${BLUE}Building image...${NORMAL}"
    docker build -t amido/${WORKLOAD}:${timestamp}  .
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

printf "${BLUE}\n\nFunctional API tests"
printf "\n------------------------------------------------------------------------------------------------------------------------------------\n${NORMAL}"

     mvn -f ../api-tests-karate/pom.xml clean test --quiet
     open ../api-tests-karate/target/surefire-reports/karate-summary.html

printf "${GREEN}API Functional Karate tests completed \n ${NORMAL}"

printf "${BLUE}\n\nTidy up environment"
printf "\n------------------------------------------------------------------------------------------------------------------------------------\n"
printf "${NORMAL}Stopping the container ${GREEN}"
    docker container stop workload-${WORKLOAD}
printf "${NORMAL}Removing the container ${GREEN}"
    docker container rm workload-${WORKLOAD}
printf "${GREEN}Container stopped and removed \n ${NORMAL}"