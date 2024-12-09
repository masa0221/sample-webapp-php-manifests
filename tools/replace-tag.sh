#!/usr/bin/env bash

# yqがインストールされているか確認
if ! command -v yq &> /dev/null
then
  echo "Error: yq is not installed. Please install yq to proceed."
  exit 1
fi

# 引数のチェック
if [ -z "${1}" ]; then
  echo "Usage: ${0} <tag>"
  exit 1
fi

TAG=${1}

# リポジトリのルートディレクトリ
REPO_ROOT="${GITHUB_WORKSPACE:-$(git rev-parse --show-toplevel)}"

# ベースパスを設定
BASE_PATH="${REPO_ROOT}/manifests/overlays"

# dev
# webapp-php のタグを書き換え
yq -i '(.spec.template.spec.containers[] | select(.name == "webapp-php").image) |= sub("([^:]+):.*", "$1:'"${TAG}"'")' \
  "${BASE_PATH}/dev/webapp/deployment.yaml"
# webapp-nginx のタグを書き換え
yq -i '(.spec.template.spec.containers[] | select(.name == "webapp-nginx").image) |= sub("([^:]+):.*", "$1:'"${TAG}"'")' \
  "${BASE_PATH}/dev/webapp/deployment.yaml"

# prod
# webapp-php のタグを書き換え
yq -i '(.spec.template.spec.containers[] | select(.name == "webapp-php").image) |= sub("([^:]+):.*", "$1:'"${TAG}"'")' \
  "${BASE_PATH}/prod/webapp/deployment.yaml"
# webapp-nginx のタグを書き換え
yq -i '(.spec.template.spec.containers[] | select(.name == "webapp-nginx").image) |= sub("([^:]+):.*", "$1:'"${TAG}"'")' \
  "${BASE_PATH}/prod/webapp/deployment.yaml"

