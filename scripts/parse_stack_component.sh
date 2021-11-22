#!/bin/bash

# set -exo pipefail

OPTIONS="c:d:b:BPUW"

usage()
{
	set +x
	USAGE=$(cat <<- USAGE_STRING
		Usage: $(basename "${0}") [OPTION]...

		Required Arguments:
            -d location Required oproject to process
            -b location Required branch 
			-c location Required commit message
		Optional Arguments:
			-B location Create branch 
			-P location Optional trigger pipeline
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
		c  ) COMMIT_MESSAGE="${OPTARG}";;
        d  ) MODULE="${OPTARG}";;
		b  ) BRANCH="${OPTARG}";;
		
		# Optional
		B  ) NEW_BRANCH="true";;
		P  ) RUN_PIPELINE='true';;
		U  ) UPDATE_PARENT='true';;
		W  ) UPDATE_WORKLOAD='true';;

		\? ) echo "Unknown option: -${OPTARG}" >&2; exit 1;;
		:  ) echo "Missing option argument for -${OPTARG}" >&2; exit 1;;
		*  ) echo "Unimplemented option: -${option}. This is probably unintended." >&2; exit 1;;
	esac
done

. ./set_env.sh

figlet -w 150 ${MODULE}

if [ "${UPDATE_WORKLOAD}" ]; then
	export WORKLOAD_DIR=${WORKSPACE_DIR}/workloads/${MODULE}
else
	export WORKLOAD_DIR=${WORKSPACE_DIR}/${MODULE}
fi

if [ "${UPDATE_WORKLOAD}" ]; then
	UPDATE_OPTIONS+=" -W "
fi

if [ "${UPDATE_PARENT}" ]; then
	UPDATE_OPTIONS+=" -U "
fi

UPDATE_OPTIONS+="-d ${MODULE} "

${SCRIPT_DIR}/update_stacks_dependencies.sh ${UPDATE_OPTIONS}

if [ -e "${WORKLOAD_DIR}/java/pom.xml.versionsBackup" ]; then

	printf "\nCompile the module before committing any changes"
	printf "\n------------------------------------------------------------------------\n"
	mvn compile -f ${WORKLOAD_DIR}/java/pom.xml --quiet

	if [ "${NEW_BRANCH}" ]; then
		printf "New branch ${GREEN}${BRANCH}${NORMAL} created for the version update ${NORMAL}\n"
		git -C ${WORKLOAD_DIR} branch ${BRANCH}
	fi

	printf "\nCheckout branch ${GREEN}${BRANCH}${NORMAL} for the version update ${NORMAL}"
	printf "\n------------------------------------------------------------------------\n"
	git -C ${WORKLOAD_DIR} checkout ${BRANCH}

	rm ${WORKLOAD_DIR}/java/pom.xml.versionsBackup

	# printf "Checkout branch ${GREEN}${BRANCH} for the version update ${NORMAL}\n"
	git -C ${WORKLOAD_DIR} add .
	git -C ${WORKLOAD_DIR} status

	printf "\nCommit changes to the branch ${GREEN}${BRANCH}${NORMAL} with the comment ${GREEN}${COMMIT_MESSAGE}${NORMAL}"
	printf "\n------------------------------------------------------------------------\n"
	git -C ${WORKLOAD_DIR} commit -m "${COMMIT_MESSAGE}"

	# if [ "${NEW_BRANCH}" ]; then
	# 	git -C ${WORKLOAD_DIR} push --set-upstream origin ${BRANCH}
	# else
	# 	git -C ${WORKLOAD_DIR} push
	# fi

	# if [ ${RUN_PIPELINE} ]; then
	# 	az pipelines run --branch ${BRANCH} --name amido.${MODULE}
	# fi
else
	printf "${YELLOW}No updates found for the component ${MODULE}"
fi