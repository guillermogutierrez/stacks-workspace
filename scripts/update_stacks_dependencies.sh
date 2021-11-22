#!/bin/bash

# set -exo pipefail

# OPTIONS="c:d:b:BU"
OPTIONS=":d:UW"

usage()
{
	set +x
	USAGE=$(cat <<- USAGE_STRING
		Usage: $(basename "${0}") [OPTION]...

		Required Arguments:
            -d location Required oproject to process
		Optional Arguments:
			-U location Optional update parent
			-W location Optional update a workload
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
        d  ) MODULE="${OPTARG}";;
		W  ) UPDATE_WORKLOAD="true";;
		U  ) UPDATE_PARENT='true';;

		\? ) echo "Unknown option: -${OPTARG}" >&2; exit 1;;
		:  ) echo "Missing option argument for -${OPTARG}" >&2; exit 1;;
		*  ) echo "Unimplemented option: -${option}. This is probably unintended." >&2; exit 1;;
	esac
done

. ./set_env.sh

if [ "${UPDATE_PARENT}" ]; then
	PARENT_GROUPID=$(xmllint --xpath '/*[local-name()="project"]/*[local-name()="parent"]/*[local-name()="groupId"]/text()' ${WORKLOAD_DIR}/java/pom.xml)
	PARENT_ARTIFACTID=$(xmllint --xpath '/*[local-name()="project"]/*[local-name()="parent"]/*[local-name()="artifactId"]/text()' ${WORKLOAD_DIR}/java/pom.xml)
	PARENT_VERSION=$(xmllint --xpath '/*[local-name()="project"]/*[local-name()="parent"]/*[local-name()="version"]/text()' ${WORKLOAD_DIR}/java/pom.xml)
	
	printf "Cheking updates for the parent POM"
	printf "\n------------------------------------------------------------------------\n"
	printf "groupId: \t${GREEN}${PARENT_GROUPID}${NORMAL}\nartifactId: \t${GREEN}${PARENT_ARTIFACTID}${NORMAL}\nversion: \t${GREEN}${PARENT_VERSION}${NORMAL}\n"

	mvn -f ${WORKLOAD_DIR}/java/pom.xml versions:update-parent | grep '${PARENT_ARTIFACTID}\|Updating' | cut -c 8-
fi

printf "\nChecking updates for the stacks modules" 
printf "\n------------------------------------------------------------------------\n"
printf "${GREEN}%s\n${NORMAL}"  "${STACKS_MODULES_PROPERTIES[@]}"

mvn -f ${WORKLOAD_DIR}/java/pom.xml versions:update-properties \
	-DincludeProperties="$( IFS=$','; echo "${STACKS_MODULES_PROPERTIES[*]}" )" | grep 'Property\|Updated' | cut -c 8-