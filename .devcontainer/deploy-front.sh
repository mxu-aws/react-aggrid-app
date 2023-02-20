#! /bin/bash

# echo "$1, $2"


if [ "$1" == "help" ]; then

	echo "syntax: deploy-front <profile> <stage>"

	echo "<profile>: viewlinc-sandbox | viewlinc-prod"

	echo "<stage>: sandbox | prod"

	exit 0

fi


echo "removing the build folder ......"

rm -fr build


echo "building the app ..........."

serverless client build --packager npm --verbose --profile $1 --stage $2


echo "deploying WAF ......."

sls deploy -v --profile $1 --stage $2 --config waf.yml


echo "updating WebACLId in serverless.yml file"

eval `aws-auth-helper $1` TARGET_ENV=$2 node scripts/updateWebACLId.js


echo "deploying cloud front ..........."

sls deploy -v --profile $1 --stage $2



echo "updating site bucket policy ..........."

eval `aws-auth-helper $1` TARGET_REGION=us-west-2 TARGET_ENV=$2 node scripts/updateBucketPolicy.js


echo "Deployig the site ........."

serverless client deploy --profile $1 --stage $2 --no-confirm


echo "restore serverless.yml and scripts/bucketPolicy.json ........."

git checkout serverless.yml scripts/bucketPolicy.json