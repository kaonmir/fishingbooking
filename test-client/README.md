# 🎣 낚시 채팅 시스템 테스트 클라이언트

이 스크립트는 낚시 채팅 시스템을 자동으로 테스트하는 클라이언트입니다. WebSocket을 통해 연결하여 0.2초마다 자동으로 메시지를 전송합니다.

## 📋 사전 요구사항

1. **Node.js** (v16 이상 권장)
2. **낚시 채팅 서버**가 실행 중이어야 함
   - Docker Compose: `docker-compose up`
   - 또는 개별 서비스 실행

## 🚀 설치 및 실행

### 1. test-client 폴더로 이동

```bash
cd test-client
```

### 2. 의존성 설치

```bash
npm install
```

### 3. 기본 테스트 실행

```bash
# 기본 사용자명으로 테스트 (랜덤 생성)
npm run test

# 또는 직접 실행
node test-chat.js
```

### 4. 사용자명 지정하여 실행

```bash
# 특정 사용자명으로 테스트
node test-chat.js MyTestUser

# 사용자명과 API URL 둘 다 지정
node test-chat.js MyTestUser http://localhost:8080
```

### 5. 미리 정의된 사용자로 테스트

```bash
# User1으로 테스트
npm run test-user1

# User2로 테스트
npm run test-user2
```

### 6. 여러 사용자 동시 테스트

```bash
# User1과 User2를 동시에 실행
npm run test-multiple
```

## 🎮 사용법

### 기본 명령어

```bash
node test-chat.js [사용자명] [API_URL]
```

- `사용자명`: 선택사항, 기본값은 `TestUser_랜덤숫자`
- `API_URL`: 선택사항, 기본값은 `http://localhost:8080`

### 예시

```bash
# 기본 설정으로 실행
node test-chat.js

# 사용자명만 지정
node test-chat.js FisherJohn

# 사용자명과 서버 URL 모두 지정
node test-chat.js FisherJohn http://localhost:8080

# 원격 서버 테스트
node test-chat.js TestUser http://your-server.com:8080
```

## 🔧 동작 방식

1. **연결**: WebSocket을 통해 채팅 서버에 연결
2. **입장**: 채팅방에 사용자 입장 메시지 전송
3. **자동 메시징**: 0.2초마다 자동으로 메시지 전송
4. **수신**: 다른 사용자들의 메시지 실시간 수신 및 출력
5. **종료**: `Ctrl+C`로 안전하게 종료

## 📊 출력 예시

```
🎣 낚시 채팅 테스트 클라이언트 시작!
==========================================
사용자명: TestUser_123
API URL: http://localhost:8080
==========================================

🔄 TestUser_123 - WebSocket 연결 시도 중... (http://localhost:8080)
✅ TestUser_123 - WebSocket 연결 성공!
👋 TestUser_123 - 채팅방 입장
🚀 TestUser_123 - 자동 메시징 시작! (0.2초마다 메시지 전송)
종료하려면 Ctrl+C를 누르세요.

📤 TestUser_123 - 메시지 전송 #1: "안녕하세요! 테스트 메시지입니다. (메시지 #1)"
📨 TestUser_123 수신: [TestUser_123] 안녕하세요! 테스트 메시지입니다. (메시지 #1) (MESSAGE)
📤 TestUser_123 - 메시지 전송 #2: "낚시 좋아하시나요? (메시지 #2)"
📨 TestUser_123 수신: [TestUser_123] 낚시 좋아하시나요? (메시지 #2) (MESSAGE)
...
```

## 🛠️ 커스터마이징

### 메시지 주기 변경

`test-chat.js` 파일의 146번째 줄에서 변경:

```javascript
}, 200); // 200ms = 0.2초, 원하는 값으로 변경
```

### 메시지 내용 변경

`test-chat.js` 파일의 112-121번째 줄에서 메시지 배열 수정:

```javascript
const messages = [
  "안녕하세요! 테스트 메시지입니다.",
  "낚시 좋아하시나요?",
  // 원하는 메시지 추가
];
```

## 🚨 문제 해결

### 연결 실패 시

1. 서버가 실행 중인지 확인: `docker-compose ps` (프로젝트 루트에서)
2. 포트가 올바른지 확인: 기본값 8080
3. 방화벽 설정 확인

### 의존성 오류 시

```bash
rm -rf node_modules package-lock.json
npm install
```

## 🔍 로그 분석

- `🔄`: 연결 시도 중
- `✅`: 연결 성공
- `❌`: 연결 실패 또는 해제
- `👋`: 사용자 입장
- `📤`: 메시지 전송
- `📨`: 메시지 수신
- `🚨`: 오류 발생
- `🛑`: 프로그램 종료

## 📁 폴더 구조

```
fishingBooking/
├── test-client/          # 📁 테스트 클라이언트 폴더
│   ├── test-chat.js      # 메인 테스트 스크립트
│   ├── package.json      # Node.js 의존성
│   └── README.md         # 이 파일
├── docker-compose.yml    # 서버 실행용
├── chat-api/            # 백엔드 API
└── web/                 # 프론트엔드
```

## 📝 참고사항

- 프로그램은 `Ctrl+C`로 안전하게 종료됩니다
- 연결이 끊어지면 자동으로 메시징이 중단됩니다
- 동시에 여러 클라이언트를 실행하여 부하 테스트가 가능합니다
- 실제 WebSocket 연결을 사용하므로 서버가 실행 중이어야 합니다
- **중요**: 이 폴더(`test-client`)에서 명령어를 실행해야 합니다
