#!/bin/bash

set -exo pipefail

OPTIONS="c:d:b:B:P"

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
			-P location Required trigger pipeline
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
		B  ) NEW_BRANCH="true";;
		P  ) RUN_PIPELINE='true';;

		\? ) echo "Unknown option: -${OPTARG}" >&2; exit 1;;
		:  ) echo "Missing option argument for -${OPTARG}" >&2; exit 1;;
		*  ) echo "Unimplemented option: -${option}. This is probably unintended." >&2; exit 1;;
	esac
done

figlet ${MODULE}

cd ${MODULE}

if [ "${NEW_BRANCH}" ]; then
	git branch ${BRANCH}
fi

git checkout ${BRANCH}

sed -i '' "s/0.0.10-groupId-rename/0.0.13-main/g" ./java/pom.xml
# sed -i '' "s/templates\/java-modules/azDevOps\/azure\/templates\/steps\/java/g" ./build/azDevOps/azure/azure-pipelines-javaspring-deploy.yml

mvn compile -f ./java/pom.xml

git add .

git commit -m ${COMMIT_MESSAGE}

if [ "${NEW_BRANCH}" ]; then
	git push --set-upstream origin ${BRANCH}
else
	git push
fi

if [ ${RUN_PIPELINE} ]; then
	az pipelines run --branch ${BRANCH} --name amido.${MODULE}
fi