import React from "react";
import styled from "styled-components";
import { User } from "./ChatRoom";

const UserListContainer = styled.div`
  width: 250px;
  background: #f8f9fa;
  border-left: 1px solid #e1e5e9;
  display: flex;
  flex-direction: column;
`;

const UserListHeader = styled.div`
  padding: 20px;
  background: white;
  border-bottom: 1px solid #e1e5e9;
`;

const UserListTitle = styled.h3`
  margin: 0;
  font-size: 1.1rem;
  font-weight: 600;
  color: #333;
  display: flex;
  align-items: center;
  gap: 8px;
`;

const OnlineIndicator = styled.span`
  width: 8px;
  height: 8px;
  background: #28a745;
  border-radius: 50%;
  display: inline-block;
`;

const UserCount = styled.span`
  font-size: 0.9rem;
  color: #666;
  font-weight: normal;
`;

const UserListContent = styled.div`
  flex: 1;
  overflow-y: auto;
  padding: 10px;
`;

const UserItem = styled.div`
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  margin-bottom: 5px;
  background: white;
  border-radius: 10px;
  border: 1px solid #e1e5e9;
  transition: all 0.2s ease;

  &:hover {
    transform: translateY(-1px);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }
`;

const UserAvatar = styled.div`
  width: 36px;
  height: 36px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 600;
  font-size: 0.9rem;
`;

const UserInfo = styled.div`
  flex: 1;
`;

const UserName = styled.div`
  font-weight: 600;
  color: #333;
  font-size: 0.9rem;
`;

const UserStatus = styled.div`
  font-size: 0.8rem;
  color: #28a745;
  display: flex;
  align-items: center;
  gap: 4px;
  margin-top: 2px;
`;

const StatusDot = styled.span`
  width: 6px;
  height: 6px;
  background: #28a745;
  border-radius: 50%;
`;

interface UserListProps {
  users: User[];
}

const UserList: React.FC<UserListProps> = ({ users }) => {
  const getInitials = (username: string) => {
    return username.charAt(0).toUpperCase();
  };

  return (
    <UserListContainer>
      <UserListHeader>
        <UserListTitle>
          <OnlineIndicator />
          온라인 사용자
          <UserCount>({users.length})</UserCount>
        </UserListTitle>
      </UserListHeader>
      <UserListContent>
        {users.map((user) => (
          <UserItem key={user.id}>
            <UserAvatar>{getInitials(user.username)}</UserAvatar>
            <UserInfo>
              <UserName>{user.username}</UserName>
              <UserStatus>
                <StatusDot />
                온라인
              </UserStatus>
            </UserInfo>
          </UserItem>
        ))}
      </UserListContent>
    </UserListContainer>
  );
};

export default UserList;
