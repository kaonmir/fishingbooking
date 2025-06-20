import { Client } from "@stomp/stompjs";
import SockJS from "sockjs-client";
import { Message } from "../components/ChatRoom";

export interface WebSocketMessage {
  id?: string;
  username: string;
  message: string;
  timestamp?: Date;
  type: "MESSAGE" | "SYSTEM" | "JOIN" | "LEAVE";
}

class WebSocketService {
  private client: Client | null = null;
  private connected: boolean = false;
  private messageCallback: ((message: Message) => void) | null = null;
  private connectionCallback: ((connected: boolean) => void) | null = null;
  private userJoined: boolean = false;

  constructor() {
    this.client = new Client({
      webSocketFactory: () =>
        new SockJS(
          `${process.env.REACT_APP_API_URL || "http://localhost:8080"}/ws`
        ),
      debug: (str) => {
        console.log("STOMP Debug:", str);
      },
      reconnectDelay: 5000,
      heartbeatIncoming: 4000,
      heartbeatOutgoing: 4000,
    });

    this.client.onConnect = (frame) => {
      console.log("WebSocket 연결됨:", frame);
      this.connected = true;
      this.connectionCallback?.(true);
      this.subscribeToMessages();
    };

    this.client.onDisconnect = (frame) => {
      console.log("WebSocket 연결 해제됨:", frame);
      this.connected = false;
      this.connectionCallback?.(false);
    };

    this.client.onStompError = (frame) => {
      console.error("STOMP 오류:", frame);
      this.connected = false;
      this.connectionCallback?.(false);
    };
  }

  connect(username: string): void {
    if (!this.client || this.connected) return;

    this.client.activate();

    // 연결 후 사용자 입장 메시지 전송 (중복 방지)
    setTimeout(() => {
      if (this.connected && !this.userJoined) {
        this.addUser(username);
        this.userJoined = true;
      }
    }, 1000);
  }

  disconnect(): void {
    if (this.client && this.connected) {
      this.client.deactivate();
      this.connected = false;
      this.userJoined = false;
    }
  }

  private subscribeToMessages(): void {
    if (!this.client || !this.connected) return;

    this.client.subscribe("/topic/messages", (message) => {
      try {
        const parsedMessage: WebSocketMessage = JSON.parse(message.body);
        console.log("메시지 수신:", parsedMessage);

        // WebSocket 메시지를 React 컴포넌트 형식으로 변환
        const reactMessage: Message = {
          id: parsedMessage.id?.toString() || Date.now().toString(),
          username: parsedMessage.username,
          message: parsedMessage.message,
          timestamp: parsedMessage.timestamp
            ? new Date(parsedMessage.timestamp)
            : new Date(),
          type: parsedMessage.type === "MESSAGE" ? "message" : "system",
        };

        this.messageCallback?.(reactMessage);
      } catch (error) {
        console.error("메시지 파싱 오류:", error);
      }
    });
  }

  sendMessage(username: string, message: string): void {
    if (!this.client || !this.connected) {
      console.warn("WebSocket이 연결되지 않음");
      return;
    }

    const chatMessage: WebSocketMessage = {
      username,
      message,
      type: "MESSAGE",
      timestamp: new Date(),
    };

    this.client.publish({
      destination: "/app/chat.sendMessage",
      body: JSON.stringify(chatMessage),
    });
  }

  addUser(username: string): void {
    if (!this.client || !this.connected) return;

    const joinMessage: WebSocketMessage = {
      username,
      message: "",
      type: "JOIN",
    };

    this.client.publish({
      destination: "/app/chat.addUser",
      body: JSON.stringify(joinMessage),
    });
  }

  setMessageCallback(callback: (message: Message) => void): void {
    this.messageCallback = callback;
  }

  setConnectionCallback(callback: (connected: boolean) => void): void {
    this.connectionCallback = callback;
  }

  isConnected(): boolean {
    return this.connected;
  }
}

export default new WebSocketService();
