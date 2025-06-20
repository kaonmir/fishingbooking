# ECS/Fargate RabbitMQ 배포 가이드

이 가이드는 기존 Docker Compose 환경에서 AWS ECS/Fargate로 RabbitMQ 클러스터를 마이그레이션하는 방법을 설명합니다.

## 🏗️ 아키텍처 개요

```
┌─────────────────────────────────────────────────────────────┐
│                        Internet                              │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                  ALB (Public)                               │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│              ECS Fargate Cluster                            │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │ RabbitMQ    │  │ RabbitMQ    │  │ RabbitMQ    │         │
│  │ Node 1      │  │ Node 2      │  │ Node 3      │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐                          │
│  │ Chat API    │  │ Chat API    │                          │
│  │ Service     │  │ Service     │                          │
│  └─────────────┘  └─────────────┘                          │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐                          │
│  │ Web         │  │ Web         │                          │
│  │ Service     │  │ Service     │                          │
│  └─────────────┘  └─────────────┘                          │
└─────────────────────────────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                 EFS (Data Storage)                          │
└─────────────────────────────────────────────────────────────┘
```

## 📋 사전 요구사항

### 1. AWS CLI 설정

```bash
aws configure
```

### 2. Terraform 설치

```bash
# macOS
brew install terraform

# 또는 직접 다운로드
# https://www.terraform.io/downloads.html
```

### 3. 필요한 권한

- ECS 관련 권한
- VPC 및 네트워킹 권한
- IAM 권한
- EFS 권한
- CloudWatch 권한
- SSM 권한

## 🚀 배포 단계

### 1단계: 인프라 설정

1. **terraform.tfvars 파일 생성**

```bash
cp terraform.tfvars.example terraform.tfvars
# 실제 값으로 수정
```

2. **Terraform 초기화 및 적용**

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 2단계: 컨테이너 이미지 준비

기존 Docker 이미지들이 ECR에 있는지 확인:

- `859727769026.dkr.ecr.ap-northeast-2.amazonaws.com/fishing-booking-chat-api:latest`
- `859727769026.dkr.ecr.ap-northeast-2.amazonaws.com/fishing-booking-web:latest`

### 3단계: ECS 클러스터 배포

Terraform apply가 완료되면 다음 리소스들이 생성됩니다:

- ECS 클러스터
- RabbitMQ 서비스 (3개 인스턴스)
- Chat API 서비스 (2개 인스턴스)
- Web 서비스 (2개 인스턴스)
- ALB 및 타겟 그룹
- EFS 파일 시스템

### 4단계: RabbitMQ 클러스터 구성

```bash
# 스크립트 실행 권한 부여
chmod +x scripts/configure-rabbitmq-cluster.sh

# RabbitMQ 클러스터 구성
./scripts/configure-rabbitmq-cluster.sh
```

### 5단계: 서비스 상태 확인

```bash
# ECS 서비스 상태 확인
aws ecs describe-services \
  --cluster fishing-chat-cluster \
  --services fishing-chat-rabbitmq fishing-chat-api fishing-chat-web \
  --region ap-northeast-2

# ALB 상태 확인
aws elbv2 describe-load-balancers \
  --names fishing-chat-alb \
  --region ap-northeast-2
```

## 🔧 구성 상세

### RabbitMQ 클러스터 설정

- **고가용성**: 3노드 클러스터로 구성
- **데이터 지속성**: EFS를 통한 영구 스토리지
- **서비스 디스커버리**: `rabbitmq.fishing-chat.local`
- **관리 UI**: 각 노드의 15672 포트

### 네트워킹

- **Service Discovery**: AWS Cloud Map 사용
- **Load Balancing**: ALB를 통한 트래픽 분산
- **Security Groups**: 최소 권한 원칙 적용

### 모니터링

- **CloudWatch Logs**: 모든 서비스 로그 수집
- **Container Insights**: ECS 클러스터 모니터링
- **Health Checks**: 각 서비스별 헬스체크 구성

## 💰 예상 비용 (월)

| 리소스             | 수량          | 예상 비용 |
| ------------------ | ------------- | --------- |
| Fargate (RabbitMQ) | 3 x 1vCPU/2GB | ~$45      |
| Fargate (Chat API) | 2 x 2vCPU/4GB | ~$60      |
| Fargate (Web)      | 2 x 1vCPU/2GB | ~$30      |
| EFS                | 20GB          | ~$6       |
| ALB                | 1개           | ~$23      |
| **총합**           |               | **~$164** |

_비용은 ap-northeast-2 기준이며 실제 사용량에 따라 변동될 수 있습니다._

## 🔄 마이그레이션 전략

### 1. 블루-그린 배포

1. **현재 환경 유지**: Docker Compose 환경 그대로 유지
2. **새 환경 구축**: ECS/Fargate 환경 완전히 구축
3. **트래픽 전환**: DNS 또는 로드밸런서를 통해 점진적 전환
4. **구 환경 정리**: 문제없음 확인 후 Docker Compose 환경 제거

### 2. 데이터 마이그레이션

```bash
# 기존 RabbitMQ에서 정의 내보내기
curl -u admin:password123 \
  http://localhost:15672/api/definitions \
  -o rabbitmq-definitions.json

# 새 환경으로 정의 가져오기
curl -u admin:password123 \
  -H "Content-Type: application/json" \
  -d @rabbitmq-definitions.json \
  -X POST \
  http://[ALB-DNS]/api/definitions
```

## 🚨 주의사항

### 1. 보안

- **민감한 정보**: SSM Parameter Store 사용
- **네트워크**: 프라이빗 서브넷에서 실행
- **암호화**: EFS 전송 중 암호화 활성화

### 2. 가용성

- **Multi-AZ**: 여러 가용 영역에 분산 배치
- **Health Checks**: 적절한 헬스체크 구성
- **Auto Scaling**: 필요시 오토스케일링 설정

### 3. 성능

- **리소스 할당**: 워크로드에 맞는 CPU/메모리 설정
- **네트워크**: Service Discovery를 통한 효율적 통신
- **스토리지**: EFS 성능 모드 고려

## 🔍 모니터링 및 로그

### CloudWatch 대시보드 생성

```bash
# 대시보드 생성 스크립트 실행 (별도 작성 필요)
aws cloudwatch put-dashboard \
  --dashboard-name "FishingChat-ECS" \
  --dashboard-body file://cloudwatch-dashboard.json
```

### 로그 확인

```bash
# RabbitMQ 로그
aws logs describe-log-streams \
  --log-group-name "/ecs/fishing-chat-rabbitmq"

# Chat API 로그
aws logs describe-log-streams \
  --log-group-name "/ecs/fishing-chat-api"
```

## 🆘 트러블슈팅

### 일반적인 문제들

1. **RabbitMQ 클러스터 형성 실패**

   - Erlang 쿠키 일치 확인
   - 네트워크 연결성 확인
   - DNS 해석 확인

2. **서비스 시작 실패**

   - CloudWatch 로그 확인
   - 태스크 정의 검토
   - IAM 권한 확인

3. **로드밸런서 연결 실패**
   - 헬스체크 경로 확인
   - 보안 그룹 설정 확인
   - 타겟 그룹 등록 상태 확인

### 유용한 명령어

```bash
# ECS 태스크 로그 실시간 확인
aws logs tail /ecs/fishing-chat-rabbitmq --follow

# 서비스 이벤트 확인
aws ecs describe-services \
  --cluster fishing-chat-cluster \
  --services fishing-chat-rabbitmq \
  --query 'services[0].events'

# 태스크 실행
aws ecs execute-command \
  --cluster fishing-chat-cluster \
  --task [TASK-ARN] \
  --container rabbitmq \
  --interactive \
  --command "/bin/bash"
```

## 📞 지원

문제가 발생하면 다음을 확인하세요:

1. CloudWatch 로그
2. ECS 서비스 이벤트
3. ALB 타겟 상태
4. 네트워크 연결성

추가 지원이 필요하면 개발팀에 문의하세요.
