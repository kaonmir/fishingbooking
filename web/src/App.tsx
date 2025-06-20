import React, { useState } from "react";
import styled from "styled-components";
import ChatRoom from "./components/ChatRoom";
import NicknameForm from "./components/NicknameForm";
import "./App.css";

const AppContainer = styled.div`
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
`;

const App: React.FC = () => {
  const [nickname, setNickname] = useState<string>("");
  const [isJoined, setIsJoined] = useState<boolean>(false);

  const handleJoinChat = (userNickname: string) => {
    setNickname(userNickname);
    setIsJoined(true);
  };

  return (
    <AppContainer>
      {!isJoined ? (
        <NicknameForm onJoin={handleJoinChat} />
      ) : (
        <ChatRoom nickname={nickname} />
      )}
    </AppContainer>
  );
};

export default App;
