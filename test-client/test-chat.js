const StompJs = require("@stomp/stompjs");
const SockJS = require("sockjs-client");

// WebSocket 서비스 클래스
class ChatTestClient {
  constructor(username, apiUrl = "http://localhost:8080") {
    this.username = username;
    this.apiUrl = apiUrl;
    this.client = null;
    this.connected = false;
    this.messageCount = 0;
    this.userJoined = false;
  }

  connect() {
    console.log(
      `🔄 ${this.username} - WebSocket 연결 시도 중... (${this.apiUrl})`
    );

    this.client = new StompJs.Client({
      webSocketFactory: () => {
        return new SockJS(`${this.apiUrl}/ws`);
      },
      debug: (str) => {
        // debug 메시지는 너무 많아서 주석 처리
        // console.log(`[DEBUG] ${this.username}:`, str);
      },
      reconnectDelay: 5000,
      heartbeatIncoming: 4000,
      heartbeatOutgoing: 4000,
    });

    this.client.onConnect = (frame) => {
      console.log(`✅ ${this.username} - WebSocket 연결 성공!`);
      this.connected = true;
      this.subscribeToMessages();

      // 연결 후 사용자 입장 메시지 전송
      setTimeout(() => {
        if (this.connected && !this.userJoined) {
          this.addUser();
        }
      }, 1000);
    };

    this.client.onDisconnect = (frame) => {
      console.log(`❌ ${this.username} - WebSocket 연결 해제됨`);
      this.connected = false;
      this.userJoined = false;
    };

    this.client.onStompError = (frame) => {
      console.error(`🚨 ${this.username} - STOMP 오류:`, frame.headers.message);
      this.connected = false;
    };

    this.client.activate();
  }

  subscribeToMessages() {
    if (!this.client || !this.connected) return;

    this.client.subscribe("/topic/messages", (message) => {
      try {
        const parsedMessage = JSON.parse(message.body);
        console.log(
          `📨 ${this.username} 수신:`,
          `[${parsedMessage.username}] ${parsedMessage.message} (${parsedMessage.type})`
        );
      } catch (error) {
        console.error(`❌ ${this.username} - 메시지 파싱 오류:`, error);
      }
    });
  }

  addUser() {
    if (!this.client || !this.connected || this.userJoined) return;

    const joinMessage = {
      username: this.username,
      message: "",
      type: "JOIN",
    };

    this.client.publish({
      destination: "/app/chat.addUser",
      body: JSON.stringify(joinMessage),
    });

    this.userJoined = true;
    console.log(`👋 ${this.username} - 채팅방 입장`);
  }

  sendMessage(message) {
    if (!this.client || !this.connected) {
      console.warn(`⚠️ ${this.username} - WebSocket이 연결되지 않음`);
      return;
    }

    const chatMessage = {
      username: this.username,
      message: message,
      type: "MESSAGE",
      timestamp: new Date().toISOString(),
    };

    this.client.publish({
      destination: "/app/chat.sendMessage",
      body: JSON.stringify(chatMessage),
    });

    this.messageCount++;
    console.log(
      `📤 ${this.username} - 메시지 전송 #${this.messageCount}: "${message}"`
    );
  }

  disconnect() {
    if (this.client && this.connected) {
      this.client.deactivate();
      console.log(`🔌 ${this.username} - 연결 해제`);
    }
  }

  // 자동 메시지 전송 시작
  startAutoMessaging() {
    if (!this.connected) {
      console.warn(
        `⚠️ ${this.username} - 연결되지 않아 자동 메시징을 시작할 수 없습니다.`
      );
      return;
    }

    const messages = [
      "안녕하세요! 테스트 메시지입니다.",
      "낚시 좋아하시나요?",
      "오늘 날씨가 참 좋네요!",
      "채팅 시스템이 잘 작동하는군요.",
      "실시간 메시징 테스트 중입니다.",
      "WebSocket 연결이 안정적이네요.",
      "계속해서 메시지를 보내겠습니다.",
      "이것은 자동 테스트 메시지입니다.",
      "시스템 성능 확인 중...",
      "모든 것이 정상 작동합니다!",
    ];

    let messageIndex = 0;

    const sendInterval = setInterval(() => {
      if (!this.connected) {
        console.log(
          `🛑 ${this.username} - 연결이 끊어져서 자동 메시징을 중단합니다.`
        );
        clearInterval(sendInterval);
        return;
      }

      const baseMessage = messages[messageIndex % messages.length];
      const message = `${baseMessage} (메시지 #${this.messageCount + 1})`;

      this.sendMessage(message);
      messageIndex++;
    }, 500); // 0.5초마다 메시지 전송

    // 프로그램 종료 시 정리
    process.on("SIGINT", () => {
      console.log(
        `\n🛑 ${this.username} - 프로그램 종료 신호 받음. 정리 중...`
      );
      clearInterval(sendInterval);
      this.disconnect();
      process.exit(0);
    });

    process.on("SIGTERM", () => {
      console.log(
        `\n🛑 ${this.username} - 프로그램 종료 신호 받음. 정리 중...`
      );
      clearInterval(sendInterval);
      this.disconnect();
      process.exit(0);
    });

    console.log(
      `🚀 ${this.username} - 자동 메시징 시작! (0.2초마다 메시지 전송)`
    );
    console.log("종료하려면 Ctrl+C를 누르세요.");
  }
}

// 메인 실행 함수
async function main() {
  // 명령행 인수에서 사용자명과 API URL 가져오기
  const args = process.argv.slice(2);
  const username = args[0] || `TestUser_${Math.floor(Math.random() * 1000)}`;
  const apiUrl = args[1] || "http://localhost:8080";

  console.log("🎣 낚시 채팅 테스트 클라이언트 시작!");
  console.log("==========================================");
  console.log(`사용자명: ${username}`);
  console.log(`API URL: ${apiUrl}`);
  console.log("==========================================\n");

  const chatClient = new ChatTestClient(username, apiUrl);

  // WebSocket 연결
  chatClient.connect();

  // 연결이 완료될 때까지 대기
  const waitForConnection = () => {
    return new Promise((resolve) => {
      const checkConnection = () => {
        if (chatClient.connected && chatClient.userJoined) {
          resolve();
        } else {
          setTimeout(checkConnection, 100);
        }
      };
      checkConnection();
    });
  };

  try {
    // 최대 10초 대기
    await Promise.race([
      waitForConnection(),
      new Promise((_, reject) =>
        setTimeout(() => reject(new Error("연결 타임아웃")), 10000)
      ),
    ]);

    // 연결 성공 후 자동 메시징 시작
    setTimeout(() => {
      chatClient.startAutoMessaging();
    }, 2000); // 2초 후 시작
  } catch (error) {
    console.error("❌ 연결 실패:", error.message);
    console.log("서버가 실행 중인지 확인해주세요.");
    process.exit(1);
  }
}

// 스크립트 실행
if (require.main === module) {
  main().catch(console.error);
}

module.exports = ChatTestClient;
