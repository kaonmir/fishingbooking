import React, { useState } from "react";
import styled from "styled-components";

const InputContainer = styled.form`
  display: flex;
  gap: 10px;
  align-items: flex-end;
`;

const TextArea = styled.textarea`
  flex: 1;
  padding: 12px 16px;
  border: 2px solid #e1e5e9;
  border-radius: 20px;
  font-size: 1rem;
  font-family: inherit;
  resize: none;
  min-height: 44px;
  max-height: 120px;
  line-height: 1.4;
  transition: border-color 0.3s ease;

  &:focus {
    outline: none;
    border-color: #667eea;
  }

  &::placeholder {
    color: #999;
  }
`;

const SendButton = styled.button`
  padding: 12px 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 20px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  white-space: nowrap;

  &:hover:not(:disabled) {
    transform: translateY(-1px);
    box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
  }

  &:disabled {
    opacity: 0.6;
    cursor: not-allowed;
    transform: none;
    box-shadow: none;
  }
`;

const EmojiButton = styled.button`
  padding: 12px;
  background: #f8f9fa;
  border: 2px solid #e1e5e9;
  border-radius: 50%;
  font-size: 1.2rem;
  cursor: pointer;
  transition: all 0.2s ease;

  &:hover {
    background: #e9ecef;
    transform: scale(1.1);
  }
`;

const QuickEmojis = styled.div`
  display: flex;
  gap: 5px;
  margin-bottom: 10px;
`;

const QuickEmojiButton = styled.button`
  padding: 6px 10px;
  background: #f8f9fa;
  border: 1px solid #e1e5e9;
  border-radius: 15px;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.2s ease;

  &:hover {
    background: #e9ecef;
    transform: translateY(-1px);
  }
`;

interface MessageInputProps {
  onSendMessage: (message: string) => void;
}

const MessageInput: React.FC<MessageInputProps> = ({ onSendMessage }) => {
  const [message, setMessage] = useState<string>("");
  const [showEmojis, setShowEmojis] = useState<boolean>(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (message.trim()) {
      onSendMessage(message.trim());
      setMessage("");
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      handleSubmit(e);
    }
  };

  const insertEmoji = (emoji: string) => {
    setMessage((prev) => prev + emoji);
    setShowEmojis(false);
  };

  const quickEmojis = ["🎣", "🐟", "🌊", "⛵", "🏖️", "👍", "😊", "❤️"];

  return (
    <div>
      {showEmojis && (
        <QuickEmojis>
          {quickEmojis.map((emoji, index) => (
            <QuickEmojiButton
              key={index}
              type="button"
              onClick={() => insertEmoji(emoji)}
            >
              {emoji}
            </QuickEmojiButton>
          ))}
        </QuickEmojis>
      )}
      <InputContainer onSubmit={handleSubmit}>
        <EmojiButton
          type="button"
          onClick={() => setShowEmojis(!showEmojis)}
          title="이모지"
        >
          😊
        </EmojiButton>
        <TextArea
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          onKeyPress={handleKeyPress}
          placeholder="메시지를 입력하세요... (Shift + Enter로 줄바꿈)"
          rows={1}
        />
        <SendButton type="submit" disabled={!message.trim()}>
          전송
        </SendButton>
      </InputContainer>
    </div>
  );
};

export default MessageInput;
