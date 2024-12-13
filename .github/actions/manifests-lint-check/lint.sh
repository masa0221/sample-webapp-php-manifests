#!/usr/bin/env bash

# エラー発生時にスクリプトを停止
set -e

# 色設定
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # 色リセット

# 見出し
print_section() {
  echo -e "${YELLOW}===== $1 =====${NC}"
}

# 成功
print_success() {
  echo -e "${GREEN}[PASS] $1${NC}"
}

# 失敗
print_failure() {
  echo -e "${RED}[FAIL] $1${NC}"
  exit 1
}

# コマンド実行と結果判定
run_command() {
  local description=$1
  local command=$2

  print_section "$description"
  if eval "$command"; then
    print_success "$description completed successfully"
  else
    print_failure "$description failed"
  fi
}

# 必要なコマンドがインストールされているか確認
check_cmd() {
  local cmd=$1
  if ! command -v ${cmd} &> /dev/null
  then
    print_failure "Error: ${cmd} is not installed. Please install ${cmd} to proceed."
  fi
}

# 必須コマンドのチェック
check_cmd kubectl
check_cmd kubeconform

# dev のチェック
run_command \
  "Checking dev manifest" \
  "kubectl kustomize ./manifests/overlays/dev | kubeconform --summary"

# prod のチェック
run_command \
  "Checking prod manifest" \
  "kubectl kustomize ./manifests/overlays/prod | kubeconform --summary -skip SecretProviderClass"

# prod の CRD チェック
# https://github.com/yannh/kubeconform#customresourcedefinition-crd-support
# https://github.com/datreeio/CRDs-catalog/tree/main/secrets-store.csi.x-k8s.io
run_command \
  "Checking CRD for prod manifest" \
  "kubeconform \
    --summary \
    --schema-location https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/secrets-store.csi.x-k8s.io/secretproviderclass_v1.json \
    ./manifests/overlays/prod/secret-provider-class.yaml"

# 終了メッセージ
print_section "All checks completed successfully"
