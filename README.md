# PHP CloudFormation 設定ファイル

本内容は AWS CloudFormation を使用し、 PHP の検証環境を立ち上げるためのものです。

## 使用方法
1. [AWS コマンドラインインタフェース](https://aws.amazon.com/jp/cli/) をインストールします
  [https://aws.amazon.com/jp/cli/](https://aws.amazon.com/jp/cli/) から使用している OS に合わせてインストールを行ってください
1. AWSCLI の認証設定を行います
  [http://docs.aws.amazon.com/ja_jp/cli/latest/userguide/cli-chap-getting-started.html](http://docs.aws.amazon.com/ja_jp/cli/latest/userguide/cli-chap-getting-started.html) に従って認証情報を登録してください
1. [Github Personal access tokens](https://github.com/settings/tokens) ページにて、`Generate new token` を選択し、
  - Token description: AWS_commit_status
  - Select scopes: repo, admin:repo_hook
  の内容で token を生成、 token を控えておいてください

1. Makefile をテキストエディタで開き、以下の値を適切に書き換えます
  - GITHUB_ACCESS_TOKEN: 最初に生成し、控えた token
  - GITHUB_ACCESS_USER_NAME: token を生成したユーザー名
  - GITHUB_CFN_REPO_NAME: cfn 構成ファイルのレポジトリの名前
  - GITHUB_COMMON_REPO_NAME: common 側のレポジトリの名前
  - GITHUB_MEMBER_REPO_NAME: member 側のレポジトリの名前
  - GITHUB_USER_NAME: レポジトリを所有しているユーザーの名前
  - S3_BUCKET: 設定ファイルを保存するためのバケットの名前(S3全体で一意である必要があります)

1. Makefile が存在するディレクトリにて
  ```
  > make
  ```
  を実行してください

1. `make` により、全ての CFn の作成が完了した後、 `make github_setting` を実行します
  (make が作成した codepipeline が自動的にもう一つの CFn を起動しますので、この処理が完了するのを待って実行してください)

## 構成

現在の構成

![diagram](https://user-images.githubusercontent.com/26862113/34028934-2cf12836-e1a9-11e7-88a9-ad7237d53d46.png)
