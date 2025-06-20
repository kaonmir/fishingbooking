package com.fishingbook.chat.dto;

import com.fishingbook.chat.entity.ChatMessage;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessageDto {
    private Long id;
    private String username;
    private String message;
    private LocalDateTime timestamp;
    private ChatMessage.MessageType type;
    private String roomId;
    
    // Entity -> DTO 변환
    public static ChatMessageDto fromEntity(ChatMessage entity) {
        return new ChatMessageDto(
            entity.getId(),
            entity.getUsername(),
            entity.getMessage(),
            entity.getTimestamp(),
            entity.getType(),
            entity.getRoomId()
        );
    }
    
    // DTO -> Entity 변환
    public ChatMessage toEntity() {
        ChatMessage entity = new ChatMessage();
        entity.setId(this.id);
        entity.setUsername(this.username);
        entity.setMessage(this.message);
        entity.setTimestamp(this.timestamp);
        entity.setType(this.type);
        entity.setRoomId(this.roomId);
        return entity;
    }
} 