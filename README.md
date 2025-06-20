# 🎣 FishingBook Chat

낚시 애호가들을 위한 실시간 채팅 서비스

## 🏗️ 시스템 아키텍처

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React Web     │    │  Spring Boot    │    │    RabbitMQ     │
│   (Frontend)    │◄──►│   Chat API      │◄──►│   Message       │
│                 │    │   (Backend)     │    │   Broker        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   PostgreSQL    │
                       │   (Database)    │
                       └─────────────────┘
```

## 🚀 기술 스택

### Frontend (React)

- **React 19** + **TypeScript**
- **Styled Components** - CSS-in-JS 스타일링
- **STOMP.js** + **SockJS** - WebSocket 클라이언트
- **Socket.IO Client** - 실시간 통신

### Backend (Spring Boot)

- **Spring Boot 3.2** + **Java 17**
- **Spring WebSocket** - WebSocket 서버
- **Spring AMQP** - RabbitMQ 연동
- **Spring Data JPA** - 데이터베이스 ORM
- **PostgreSQL** - 채팅 기록 저장

### Message Broker

- **RabbitMQ** - 메시지 pub/sub 시스템
- **RabbitMQ Management** - 관리 콘솔

### Database

- **PostgreSQL 15** - 채팅 메시지 영구 저장

## 📦 프로젝트 구조

```
fishingBooking/
├── web/                    # React 프론트엔드
│   ├── src/
│   │   ├── components/     # React 컴포넌트
│   │   │   ├── ChatRoom.tsx
│   │   │   ├── MessageList.tsx
│   │   │   ├── MessageInput.tsx
│   │   │   ├── NicknameForm.tsx
│   │   │   └── UserList.tsx
│   │   └── services/       # WebSocket 서비스
│   │       └── WebSocketService.ts
│   └── package.json
├── chat-api/               # Spring Boot 백엔드
│   ├── src/main/java/com/fishingbook/chat/
│   │   ├── entity/         # JPA 엔티티
│   │   ├── dto/           # 데이터 전송 객체
│   │   ├── repository/    # 데이터 접근 계층
│   │   ├── service/       # 비즈니스 로직
│   │   ├── controller/    # REST & WebSocket 컨트롤러
│   │   └── config/        # 설정 클래스
│   ├── build.gradle
│   └── src/main/resources/application.yml
├── test-client/            # 채팅 테스트 클라이언트
│   ├── test-chat.js       # 자동 테스트 스크립트
│   ├── package.json       # 테스트 의존성
│   └── README.md          # 테스트 사용법
├── docker-compose.yml      # RabbitMQ + PostgreSQL
└── package.json           # 루트 패키지 관리
```

## 🔄 메시지 플로우

1. **사용자가 메시지 입력** → React Frontend
2. **WebSocket으로 전송** → Spring Boot Backend
3. **데이터베이스에 저장** → PostgreSQL
4. **RabbitMQ로 발행** → Message Broker
5. **RabbitMQ에서 수신** → Spring Boot Backend
6. **WebSocket으로 브로드캐스트** → 모든 연결된 클라이언트

## 🛠️ 설치 및 실행

### 1. 저장소 클론

```bash
git clone <repository-url>
cd fishingBooking
```

### 2. Docker 서비스 시작 (RabbitMQ + PostgreSQL)

```bash
docker-compose up -d
```

### 3. 의존성 설치

```bash
npm run install:all
```

### 4. 개발 서버 실행

#### 전체 서비스 실행

```bash
npm run dev
```

#### 개별 서비스 실행

```bash
# React 프론트엔드
npm run dev:web

# Spring Boot 백엔드
npm run dev:chat
```

## 🌐 서비스 접속

- **웹 애플리케이션**: http://localhost:3000
- **Spring Boot API**: http://localhost:8080
- **RabbitMQ 관리 콘솔**: http://localhost:15672
  - Username: `admin`
  - Password: `password123`

## 📊 RabbitMQ 설정

### Exchange

- **Name**: `fishing.chat.exchange`
- **Type**: `topic`

### Queue

- **Name**: `fishing.chat.queue`
- **Routing Key**: `fishing.chat.message`

### 메시지 형식

```json
{
  "id": "123",
  "username": "낚시왕",
  "message": "오늘 좋은 조황이네요!",
  "timestamp": "2024-01-01T12:00:00",
  "type": "MESSAGE"
}
```

## 🔧 주요 기능

### ✅ 구현 완료

- [x] 닉네임 입력 후 채팅 참여
- [x] 실시간 메시지 송수신
- [x] WebSocket 연결 상태 표시
- [x] RabbitMQ를 통한 메시지 pub/sub
- [x] PostgreSQL에 채팅 기록 저장
- [x] 사용자 입장/퇴장 알림
- [x] 이모지 지원
- [x] 반응형 UI

### 🚧 추후 개발 예정

- [ ] 사용자 인증 시스템
- [ ] 채팅방 분리 기능
- [ ] 파일 첨부 기능
- [ ] 메시지 검색
- [ ] 사용자 상태 관리
- [ ] 푸시 알림

## 🧪 채팅 테스트

자동화된 채팅 테스트 클라이언트가 `test-client/` 폴더에 포함되어 있습니다.

### 테스트 실행

```bash
cd test-client
npm install
node test-chat.js [사용자명]
```

### 테스트 기능

- **자동 메시지 전송**: 0.2초마다 자동으로 메시지 전송
- **실시간 연결**: 실제 WebSocket 연결로 서버 테스트
- **다중 사용자**: 여러 클라이언트 동시 실행 가능
- **부하 테스트**: 서버 성능 및 안정성 검증

자세한 사용법은 [test-client/README.md](test-client/README.md)를 참고하세요.

## 🐛 문제 해결

### Docker 서비스 재시작

```bash
docker-compose down
docker-compose up -d
```

### RabbitMQ 관리 콘솔 접속 불가

- 포트 15672가 열려있는지 확인
- 방화벽 설정 확인

### WebSocket 연결 실패

- Spring Boot 서버가 8080 포트에서 실행 중인지 확인
- CORS 설정 확인

## 📝 라이센스

MIT License

## 👥 기여자

FishingBook Team
