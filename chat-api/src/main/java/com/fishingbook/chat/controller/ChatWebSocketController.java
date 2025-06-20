package com.fishingbook.chat.controller;

import com.fishingbook.chat.dto.ChatMessageDto;
import com.fishingbook.chat.entity.ChatMessage;
import com.fishingbook.chat.service.ChatService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.stereotype.Controller;

import java.time.LocalDateTime;

@Controller
@RequiredArgsConstructor
@Slf4j
public class ChatWebSocketController {
    
    private final ChatService chatService;
    
    /**
     * 클라이언트에서 메시지 전송시 처리
     */
    @MessageMapping("/chat.sendMessage")
    public void sendMessage(@Payload ChatMessageDto chatMessage) {
        try {
            // 메시지 타입과 시간 설정
            chatMessage.setType(ChatMessage.MessageType.MESSAGE);
            chatMessage.setTimestamp(LocalDateTime.now());
            
            log.info("WebSocket으로 메시지 수신: {} - {}", 
                    chatMessage.getUsername(), chatMessage.getMessage());
            
            // 메시지 저장 및 RabbitMQ로 발행
            chatService.sendMessage(chatMessage);
            
        } catch (Exception e) {
            log.error("메시지 전송 처리 중 오류 발생", e);
        }
    }
    
    /**
     * 사용자 입장시 처리
     */
    @MessageMapping("/chat.addUser")
    public void addUser(@Payload ChatMessageDto chatMessage, 
                       SimpMessageHeaderAccessor headerAccessor) {
        try {
            // WebSocket 세션에 사용자명 저장
            headerAccessor.getSessionAttributes().put("username", chatMessage.getUsername());
            
            log.info("사용자 입장 요청: {}", chatMessage.getUsername());
            
            // 입장 메시지 처리 (중복 입장시 null 반환)
            ChatMessageDto result = chatService.handleUserJoin(chatMessage.getUsername());
            if (result != null) {
                log.info("사용자 입장 메시지 생성됨: {}", chatMessage.getUsername());
            }
            
        } catch (Exception e) {
            log.error("사용자 입장 처리 중 오류 발생", e);
        }
    }
} 