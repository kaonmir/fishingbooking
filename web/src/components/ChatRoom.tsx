import React, { useState, useEffect, useRef } from "react";
import styled from "styled-components";
import MessageList from "./MessageList";
import MessageInput from "./MessageInput";
import UserList from "./UserList";
import WebSocketService from "../services/WebSocketService";

const ChatContainer = styled.div`
  display: flex;
  background: white;
  border-radius: 20px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  width: 100%;
  max-width: 1200px;
  height: 80vh;
`;

const MainChatArea = styled.div`
  flex: 1;
  display: flex;
  flex-direction: column;
`;

const ChatHeader = styled.div`
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 20px;
  text-align: center;
`;

const ChatTitle = styled.h2`
  margin: 0;
  font-size: 1.5rem;
  font-weight: 600;
`;

const ChatSubtitle = styled.p`
  margin: 5px 0 0 0;
  opacity: 0.9;
  font-size: 0.9rem;
`;

const MessagesContainer = styled.div`
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  background: #f8f9fa;
`;

const InputContainer = styled.div`
  padding: 20px;
  background: white;
  border-top: 1px solid #e1e5e9;
`;

export interface Message {
  id: string;
  username: string;
  message: string;
  timestamp: Date;
  type: "message" | "system";
}

export interface User {
  id: string;
  username: string;
}

interface ChatRoomProps {
  nickname: string;
}

const ChatRoom: React.FC<ChatRoomProps> = ({ nickname }) => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [users, setUsers] = useState<User[]>([]);
  const [connected, setConnected] = useState<boolean>(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const hasConnected = useRef<boolean>(false);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    // 이미 연결된 경우 중복 연결 방지
    if (hasConnected.current) {
      return;
    }

    // WebSocket 연결 설정
    WebSocketService.setMessageCallback((message: Message) => {
      setMessages((prev) => [...prev, message]);
    });

    WebSocketService.setConnectionCallback((isConnected: boolean) => {
      setConnected(isConnected);
      if (isConnected) {
        console.log("WebSocket 연결됨");
      } else {
        console.log("WebSocket 연결 해제됨");
      }
    });

    // WebSocket 연결 시작
    WebSocketService.connect(nickname);
    hasConnected.current = true;

    // 초기 사용자 목록 설정
    setUsers([{ id: "1", username: nickname }]);

    return () => {
      WebSocketService.disconnect();
      hasConnected.current = false;
    };
  }, [nickname]);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSendMessage = (message: string) => {
    if (connected) {
      // WebSocket을 통해 메시지 전송
      WebSocketService.sendMessage(nickname, message);
    } else {
      console.warn("WebSocket이 연결되지 않았습니다.");
      // 연결되지 않은 경우 로컬에서만 표시 (임시)
      const newMessage: Message = {
        id: Date.now().toString(),
        username: nickname,
        message,
        timestamp: new Date(),
        type: "message",
      };
      setMessages((prev) => [...prev, newMessage]);
    }
  };

  return (
    <ChatContainer>
      <MainChatArea>
        <ChatHeader>
          <ChatTitle>🎣 FishingBook Chat</ChatTitle>
          <ChatSubtitle>
            {nickname}님으로 참여 중
            {connected ? " • 🟢 연결됨" : " • 🔴 연결 중..."}
          </ChatSubtitle>
        </ChatHeader>
        <MessagesContainer>
          <MessageList messages={messages} currentUser={nickname} />
          <div ref={messagesEndRef} />
        </MessagesContainer>
        <InputContainer>
          <MessageInput onSendMessage={handleSendMessage} />
        </InputContainer>
      </MainChatArea>
      <UserList users={users} />
    </ChatContainer>
  );
};

export default ChatRoom;
