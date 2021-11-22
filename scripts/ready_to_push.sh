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

WORKLOAD_DIR=${WORKSPACE_DIR}/workloads/${WORKLOAD}

printf "${BLUE}Running pre-push tests"
printf '\n------------------------------------------------------------------------------------------------------------------------------------\n'
    mvn -f ${WORKLOAD_DIR}/java/pom.xml fmt:format --quiet
    python3 -m yamllint -sc ${WORKLOAD_DIR}/yamllint.conf . ${WORKLOAD_DIR}/yamllint.conf