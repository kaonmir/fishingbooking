package com.fishingbook.chat.service;

import com.fishingbook.chat.dto.ChatMessageDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class ChatMessageListener {
    
    private final ChatService chatService;
    
    /**
     * RabbitMQ에서 메시지를 수신하고 WebSocket으로 브로드캐스트
     */
    @RabbitListener(queues = "${chat.rabbitmq.queue}")
    public void handleChatMessage(ChatMessageDto message) {
        try {
            log.info("RabbitMQ에서 메시지 수신: {} - {}", message.getUsername(), message.getMessage());
            
            // WebSocket을 통해 모든 연결된 클라이언트에게 메시지 전송
            chatService.broadcastMessage(message);
            
        } catch (Exception e) {
            log.error("메시지 처리 중 오류 발생", e);
        }
    }
} 