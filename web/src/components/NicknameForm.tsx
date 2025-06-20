import React, { useState } from "react";
import styled from "styled-components";

const FormContainer = styled.div`
  background: white;
  padding: 40px;
  border-radius: 20px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  text-align: center;
  max-width: 400px;
  width: 100%;
`;

const Title = styled.h1`
  color: #333;
  margin-bottom: 30px;
  font-size: 2rem;
  font-weight: 700;
`;

const Subtitle = styled.p`
  color: #666;
  margin-bottom: 30px;
  font-size: 1.1rem;
`;

const Input = styled.input`
  width: 100%;
  padding: 15px;
  border: 2px solid #e1e5e9;
  border-radius: 10px;
  font-size: 1rem;
  margin-bottom: 20px;
  transition: border-color 0.3s ease;

  &:focus {
    outline: none;
    border-color: #667eea;
  }
`;

const Button = styled.button`
  width: 100%;
  padding: 15px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
  }

  &:disabled {
    opacity: 0.6;
    cursor: not-allowed;
    transform: none;
    box-shadow: none;
  }
`;

interface NicknameFormProps {
  onJoin: (nickname: string) => void;
}

const NicknameForm: React.FC<NicknameFormProps> = ({ onJoin }) => {
  const [nickname, setNickname] = useState<string>("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (nickname.trim()) {
      onJoin(nickname.trim());
    }
  };

  return (
    <FormContainer>
      <Title>🎣 FishingBook Chat</Title>
      <Subtitle>낚시 이야기를 나누어보세요!</Subtitle>
      <form onSubmit={handleSubmit}>
        <Input
          type="text"
          placeholder="닉네임을 입력하세요"
          value={nickname}
          onChange={(e) => setNickname(e.target.value)}
          maxLength={20}
        />
        <Button type="submit" disabled={!nickname.trim()}>
          채팅 시작하기
        </Button>
      </form>
    </FormContainer>
  );
};

export default NicknameForm;
