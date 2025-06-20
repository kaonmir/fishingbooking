# 배포 가이드

이 프로젝트는 AWS ECR을 사용하여 Docker 컨테이너로 배포됩니다.

## 사전 요구사항

### 1. AWS 설정

- AWS CLI 설치 및 구성
- ECR 리포지토리 생성
- 적절한 IAM 권한 설정

### 2. GitHub Secrets 설정

다음 secrets를 GitHub 리포지토리에 추가해야 합니다:

```
AWS_ACCESS_KEY_ID: AWS 액세스 키 ID
AWS_SECRET_ACCESS_KEY: AWS 시크릿 액세스 키
AWS_ACCOUNT_ID: AWS 계정 ID (12자리 숫자)
```

## 서비스 구조

### Chat API (Spring Boot)

- **위치**: `chat-api/`
- **포트**: 8080
- **기술스택**: Java 17, Spring Boot 3.2, Gradle

### Web (React)

- **위치**: `web/`
- **포트**: 80
- **기술스택**: React 19, TypeScript, Nginx

## 로컬 개발

### Chat API 실행

```bash
cd chat-api
./gradlew bootRun
```

### Web 실행

```bash
cd web
npm install
npm start
```

### Docker Compose로 전체 실행

```bash
docker-compose up --build
```

## ECR 리포지토리 생성

### Terraform 사용 (권장)

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### AWS CLI 사용

```bash
# Chat API 리포지토리 생성
aws ecr create-repository --repository-name fishing-booking-chat-api --region ap-northeast-2

# Web 리포지토리 생성
aws ecr create-repository --repository-name fishing-booking-web --region ap-northeast-2
```

## 배포 프로세스

### 자동 배포 (GitHub Actions)

1. `main` 브랜치에 푸시하면 자동으로 배포됩니다
2. 변경된 서비스만 선택적으로 배포됩니다
3. ECR에 `latest` 태그와 커밋 SHA 태그로 이미지가 푸시됩니다

### 수동 배포

#### Chat API

```bash
cd chat-api

# 이미지 빌드
docker build -t fishing-booking-chat-api .

# ECR 로그인
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin {AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-2.amazonaws.com

# 태그 및 푸시
docker tag fishing-booking-chat-api:latest {AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-2.amazonaws.com/fishing-booking-chat-api:latest
docker push {AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-2.amazonaws.com/fishing-booking-chat-api:latest
```

#### Web

```bash
cd web

# 이미지 빌드
docker build -t fishing-booking-web .

# ECR 로그인
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin {AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-2.amazonaws.com

# 태그 및 푸시
docker tag fishing-booking-web:latest {AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-2.amazonaws.com/fishing-booking-web:latest
docker push {AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-2.amazonaws.com/fishing-booking-web:latest
```

## 이미지 실행

### Chat API

```bash
docker run -p 8080:8080 {AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-2.amazonaws.com/fishing-booking-chat-api:latest
```

### Web

```bash
docker run -p 80:80 {AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-2.amazonaws.com/fishing-booking-web:latest
```

## 환경 변수

### Chat API

실제 배포 시 다음 환경 변수들을 설정해야 합니다:

- `SPRING_DATASOURCE_URL`: PostgreSQL 데이터베이스 URL
- `SPRING_DATASOURCE_USERNAME`: 데이터베이스 사용자명
- `SPRING_DATASOURCE_PASSWORD`: 데이터베이스 비밀번호
- `SPRING_RABBITMQ_HOST`: RabbitMQ 호스트
- `SPRING_RABBITMQ_USERNAME`: RabbitMQ 사용자명
- `SPRING_RABBITMQ_PASSWORD`: RabbitMQ 비밀번호

### Web

- `REACT_APP_API_URL`: Chat API 서버 URL

## 모니터링

ECR 리포지토리에는 다음 기능이 활성화되어 있습니다:

- 이미지 스캔 (보안 취약점 검사)
- 생명주기 정책 (오래된 이미지 자동 삭제)
- 태그된 이미지 최대 30개 유지
- 태그되지 않은 이미지는 1일 후 삭제

## 문제 해결

### 빌드 실패

1. Dockerfile의 경로 확인
2. 의존성 설치 확인
3. 포트 충돌 확인

### ECR 권한 오류

1. IAM 사용자 권한 확인
2. ECR 리포지토리 존재 여부 확인
3. AWS 계정 ID 정확성 확인
