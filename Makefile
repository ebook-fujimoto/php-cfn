GITHUB_ACCESS_USER_NAME = USER_NAME
GITHUB_ACCESS_TOKEN = USER_TOKEN
GITHUB_USER_NAME = USER_NAME
GITHUB_COMMON_REPO_NAME = php-a
GITHUB_MEMBER_REPO_NAME = php-b

S3_BUCKET = cloudformation-php-conf-bucket-name

STACK_NAME = init
GENERATE_ROOT_TEMPLATE_FILE = package.yml

#---------------------------------------------#

all: package deploy github_setting

package:
	@-aws s3 rb s3://$(S3_BUCKET) --force
	@aws s3 mb s3://$(S3_BUCKET)
	@aws cloudformation package \
				--template-file cfn.yml \
				--s3-bucket $(S3_BUCKET) \
				--output-template-file $(GENERATE_ROOT_TEMPLATE_FILE)

deploy:
	@aws cloudformation deploy \
				--template-file $(GENERATE_ROOT_TEMPLATE_FILE) \
				--stack-name $(STACK_NAME) \
				--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
				--parameter-overrides \
				SettingsS3BucketName=$(S3_BUCKET) \
				GithubAccessUserName=$(GITHUB_ACCESS_USER_NAME) \
				GithubAccessToken=$(GITHUB_ACCESS_TOKEN) \
				GithubUserName=$(GITHUB_USER_NAME) \
				GithubCommonRepoName=$(GITHUB_COMMON_REPO_NAME) \
				GithubMemberRepoName=$(GITHUB_MEMBER_REPO_NAME)
	@aws s3 cp teststack.yml s3://$(S3_BUCKET)/

github_setting:
	@aws cloudformation describe-stacks --output json --stack-name $(STACK_NAME) > .tmp
	@node ./init.js \
		`cat .tmp | jq -r '.Stacks[].Outputs[]|select(.OutputKey=="GithubSnsKey").OutputValue'` \
		`cat .tmp | jq -r '.Stacks[].Outputs[]|select(.OutputKey=="GithubSnsSecret").OutputValue'` \
		`cat .tmp | jq -r '.Stacks[].Outputs[]|select(.OutputKey=="GithubSnsTopic").OutputValue'` \
		`cat .tmp | jq -r '.Stacks[].Outputs[]|select(.OutputKey=="GithubSnsRegion").OutputValue'` \
		$(GITHUB_USER_NAME) $(GITHUB_ACCESS_TOKEN) $(GITHUB_COMMON_REPO_NAME) $(GITHUB_MEMBER_REPO_NAME)
	@rm .tmp

delete:
	@aws cloudformation delete-stack \
				--stack-name $(STACK_NAME)

.PHONY: package deploy github_setting delete all