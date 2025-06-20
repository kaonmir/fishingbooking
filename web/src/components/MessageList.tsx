import React from "react";
import styled from "styled-components";
import { Message } from "./ChatRoom";

const MessageContainer = styled.div<{ isOwn: boolean; isSystem: boolean }>`
  display: flex;
  justify-content: ${(props) =>
    props.isSystem ? "center" : props.isOwn ? "flex-end" : "flex-start"};
  margin-bottom: 15px;
`;

const MessageBubble = styled.div<{ isOwn: boolean; isSystem: boolean }>`
  max-width: 70%;
  padding: 12px 16px;
  border-radius: 18px;
  word-wrap: break-word;

  ${(props) => {
    if (props.isSystem) {
      return `
        background: #e9ecef;
        color: #6c757d;
        font-style: italic;
        text-align: center;
        font-size: 0.9rem;
        padding: 8px 12px;
        border-radius: 12px;
      `;
    } else if (props.isOwn) {
      return `
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border-bottom-right-radius: 6px;
      `;
    } else {
      return `
        background: white;
        color: #333;
        border: 1px solid #e1e5e9;
        border-bottom-left-radius: 6px;
      `;
    }
  }}
`;

const MessageInfo = styled.div<{ isOwn: boolean }>`
  display: flex;
  flex-direction: column;
  ${(props) =>
    props.isOwn ? "align-items: flex-end;" : "align-items: flex-start;"}
`;

const Username = styled.span<{ isOwn: boolean }>`
  font-size: 0.8rem;
  font-weight: 600;
  margin-bottom: 4px;
  color: ${(props) => (props.isOwn ? "#667eea" : "#764ba2")};
`;

const MessageText = styled.div`
  line-height: 1.4;
`;

const Timestamp = styled.span`
  font-size: 0.7rem;
  opacity: 0.6;
  margin-top: 4px;
`;

interface MessageListProps {
  messages: Message[];
  currentUser: string;
}

const MessageList: React.FC<MessageListProps> = ({ messages, currentUser }) => {
  const formatTime = (date: Date) => {
    return new Intl.DateTimeFormat("ko-KR", {
      hour: "2-digit",
      minute: "2-digit",
    }).format(date);
  };

  return (
    <>
      {messages.map((message) => {
        const isOwn = message.username === currentUser;
        const isSystem = message.type === "system";

        return (
          <MessageContainer key={message.id} isOwn={isOwn} isSystem={isSystem}>
            <MessageInfo isOwn={isOwn}>
              {!isSystem && (
                <Username isOwn={isOwn}>{message.username}</Username>
              )}
              <MessageBubble isOwn={isOwn} isSystem={isSystem}>
                <MessageText>{message.message}</MessageText>
              </MessageBubble>
              <Timestamp>{formatTime(message.timestamp)}</Timestamp>
            </MessageInfo>
          </MessageContainer>
        );
      })}
    </>
  );
};

export default MessageList;
