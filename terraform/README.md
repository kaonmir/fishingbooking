# PostgreSQL ECS Deployment

이 Terraform 구성은 기존 VPC에 ECS를 사용하여 PostgreSQL 인스턴스 3대를 배포합니다.

## 아키텍처

- **ECS 클러스터**: Fargate를 사용하여 PostgreSQL 컨테이너 실행
- **Network Load Balancer**: 각 PostgreSQL 인스턴스에 대한 내부 로드 밸런싱
- **EFS**: PostgreSQL 데이터 영속성을 위한 공유 파일 시스템
- **SSM Parameter Store**: 데이터베이스 자격 증명 보안 저장
- **Security Groups**: 네트워크 보안 제어

## 전제 조건

1. AWS CLI 설정
2. Terraform 설치 (>= 1.0)
3. 기존 VPC

## 배포 방법

1. **변수 파일 복사 및 수정**:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **terraform.tfvars 파일에서 다음 값들을 수정**:

   - `vpc_id`: 기존 VPC ID
   - `postgresql_password`: 안전한 패스워드 설정

3. **Terraform 초기화**:

   ```bash
   terraform init
   ```

4. **계획 확인**:

   ```bash
   terraform plan
   ```

5. **배포 실행**:
   ```bash
   terraform apply
   ```

## 연결 정보

배포 완료 후 다음 출력값들을 확인할 수 있습니다:

- `postgresql_endpoints`: 각 PostgreSQL 인스턴스의 연결 정보
- `postgresql_load_balancer_dns`: 로드 밸런서 DNS 이름

## PostgreSQL 접속

각 PostgreSQL 인스턴스는 다음 포트로 접속 가능합니다:

- Instance 1: 5432
- Instance 2: 5433
- Instance 3: 5434

예시 연결 명령어:

```bash
psql -h <load_balancer_dns> -p 5432 -U postgres -d fishing_booking
```

## 보안 고려사항

- PostgreSQL 인스턴스들은 VPC 내부에서만 접근 가능합니다
- 패스워드는 SSM Parameter Store에 암호화되어 저장됩니다
- EFS는 암호화가 활성화되어 있습니다

## 리소스 정리

```bash
terraform destroy
```

## 주의사항

- EFS에 저장된 데이터는 terraform destroy 시 삭제됩니다
- 프로덕션 환경에서는 백업 전략을 수립하세요
- 리소스 크기는 워크로드에 맞게 조정하세요
