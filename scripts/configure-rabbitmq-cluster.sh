#!/bin/bash

# RabbitMQ 클러스터 구성 스크립트
# ECS 서비스가 시작된 후 실행해야 합니다.

set -e

# 변수 설정
CLUSTER_NAME="fishing-chat-cluster"
SERVICE_NAME="fishing-chat-rabbitmq"
REGION="ap-northeast-2"

echo "RabbitMQ 클러스터 구성을 시작합니다..."

# ECS 태스크 목록 가져오기
TASK_ARNS=$(aws ecs list-tasks \
  --cluster $CLUSTER_NAME \
  --service-name $SERVICE_NAME \
  --region $REGION \
  --query 'taskArns[]' \
  --output text)

if [ -z "$TASK_ARNS" ]; then
  echo "ERROR: RabbitMQ 태스크를 찾을 수 없습니다."
  exit 1
fi

echo "발견된 RabbitMQ 태스크: $TASK_ARNS"

# 첫 번째 태스크를 마스터 노드로 설정
MASTER_TASK=$(echo $TASK_ARNS | awk '{print $1}')
echo "마스터 노드: $MASTER_TASK"

# 다른 노드들을 클러스터에 조인
for TASK_ARN in $TASK_ARNS; do
  if [ "$TASK_ARN" != "$MASTER_TASK" ]; then
    echo "노드 $TASK_ARN를 클러스터에 조인합니다..."
    
    # ECS Exec을 사용하여 클러스터 조인 명령 실행
    aws ecs execute-command \
      --cluster $CLUSTER_NAME \
      --task $TASK_ARN \
      --container rabbitmq \
      --interactive \
      --command "rabbitmqctl stop_app && rabbitmqctl reset && rabbitmqctl join_cluster rabbit@rabbitmq-1.fishing-chat.local && rabbitmqctl start_app" \
      --region $REGION
      
    sleep 5
  fi
done

echo "RabbitMQ 클러스터 상태 확인..."
aws ecs execute-command \
  --cluster $CLUSTER_NAME \
  --task $MASTER_TASK \
  --container rabbitmq \
  --interactive \
  --command "rabbitmqctl cluster_status" \
  --region $REGION

echo "HA 정책 설정..."
aws ecs execute-command \
  --cluster $CLUSTER_NAME \
  --task $MASTER_TASK \
  --container rabbitmq \
  --interactive \
  --command "rabbitmqctl set_policy ha-all '^' '{\"ha-mode\":\"all\",\"ha-sync-mode\":\"automatic\"}'" \
  --region $REGION

echo "RabbitMQ 클러스터 구성이 완료되었습니다!" 