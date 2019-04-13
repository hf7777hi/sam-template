#!/bin/bash
export AWS_DEFAULT_PROFILE=pro # aws configure --profile name
S3_BUCKET=
STACK_NAME=

usage(){
	if [ "${2}" != "local" -a "${2}" != "prod" ]; then
		echo "usage: ./"`basename ${1}` "[dirname] [env(local,prod)] [true ->pip install]"
		exit;
	fi
}
isExist(){
	if [ ! -e ${1} ]; then
		echo "${1} is NOT found."
		exit;
	fi
	aws configure list > /dev/null
	if [ $? -ne 0 ]; then
		echo "exec command > 'aws configure'"
		exit;
	fi
}
isExec(){
	echo "Start sam deploy. Are you ready? [Y/n]"
	read answer
	case ${answer} in
		yes | Y | y | Yes)
			;;
		*)
			echo "NOT sam deploy. exit."
			exit; ;;
	esac
}
samDeploy(){
	echo "sam deploy start!!"
	sam package \
		--template-file template.yaml \
		--output-template-file packaged.yaml \
		--s3-bucket ${S3_BUCKET} || error
    sed -i.bak -e 's%Env: LOCAL%Env: PROD%g' packaged.yaml || error
    rm -f packaged.yaml.bak || error
	sam deploy \
		--template-file packaged.yaml \
		--stack-name slacknotice \
		--capabilities CAPABILITY_IAM || error
	echo "sam deploy done."
}
error(){
	echo "Error!!"
	exit;
}
pycacheClean(){
    if [ -e ${1}__pycache__ ]; then
        ls -la ${1}__pycache__
        rm -r ${1}__pycache__
    fi
}

main(){
	TERGET=${1}
	isExist ${TERGET}

	cd ${TERGET}
	isExist requirements.txt

    if [ "${3}" = "true" ]; then
    	pip install -r requirements.txt -t build/ || error
    fi
    pycacheClean ./
    pycacheClean ../common/
	cp *.py build/ || error
    cp -r ../common build/ || error
    sed -i.bak -e 's%from .build.%from %g' build/*.py || error
	sed -i.bak -e "s%from ${TERGET}.%from %g" build/*.py || error
    rm -f build/*.py.bak || error

	if [ "${2}" != "prod" ]; then
		exit;
	fi
	isExec ${2}
    cd ..
	samDeploy
}

usage ${0} ${2}
main ${1} ${2} ${3}