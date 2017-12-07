GITHUB_ACCESS_USER_NAME = opst-ezaki
GITHUB_ACCESS_TOKEN = USER_TOKEN
GITHUB_USER_NAME = opst-ezaki
GITHUB_CFN_REPO_NAME = php-cfn
GITHUB_COMMON_REPO_NAME = php-a
GITHUB_MEMBER_REPO_NAME = php-b

S3_BUCKET = cloudformation-php-conf-bucket-name

INIT_STACK_NAME = init
GENERATE_ROOT_TEMPLATE_FILE = package.yml

TEST_STACK_NAME = test

#---------------------------------------------#

init:
	@aws cloudformation deploy \
				--template-file ci.yml \
				--stack-name $(INIT_STACK_NAME) \
				--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
				--parameter-overrides \
				InitStackName=$(INIT_STACK_NAME) \
				TestStackName=$(TEST_STACK_NAME) \
				SettingsS3BucketName=$(S3_BUCKET) \
				GithubUserName=$(GITHUB_USER_NAME) \
				GithubCFnRepoName=$(GITHUB_CFN_REPO_NAME) \
				GithubCommonRepoName=$(GITHUB_COMMON_REPO_NAME) \
				GithubMemberRepoName=$(GITHUB_MEMBER_REPO_NAME) \
				GithubAccessUserName=$(GITHUB_ACCESS_USER_NAME) \
				GithubAccessToken=$(GITHUB_ACCESS_TOKEN)


package:
	@aws cloudformation package \
				--template-file cfn.yml \
				--s3-bucket $(S3_BUCKET) \
				--output-template-file $(GENERATE_ROOT_TEMPLATE_FILE)

deploy:
	@aws cloudformation deploy \
				--template-file $(GENERATE_ROOT_TEMPLATE_FILE) \
				--stack-name $(TEST_STACK_NAME) \
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
	@aws cloudformation describe-stacks --output json --stack-name $(TEST_STACK_NAME) > .tmp
	@node ./init.js \
		`cat .tmp | jq -r '.Stacks[].Outputs[]|select(.OutputKey=="GithubSnsKey").OutputValue'` \
		`cat .tmp | jq -r '.Stacks[].Outputs[]|select(.OutputKey=="GithubSnsSecret").OutputValue'` \
		`cat .tmp | jq -r '.Stacks[].Outputs[]|select(.OutputKey=="GithubSnsTopic").OutputValue'` \
		`cat .tmp | jq -r '.Stacks[].Outputs[]|select(.OutputKey=="GithubSnsRegion").OutputValue'` \
		$(GITHUB_USER_NAME) $(GITHUB_ACCESS_TOKEN) $(GITHUB_COMMON_REPO_NAME) $(GITHUB_MEMBER_REPO_NAME)
	@rm .tmp

.PHONY: init package deploy github_setting