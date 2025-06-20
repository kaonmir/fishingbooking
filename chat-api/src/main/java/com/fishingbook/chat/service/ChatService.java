package com.fishingbook.chat.service;

import com.fishingbook.chat.dto.ChatMessageDto;
import com.fishingbook.chat.entity.ChatMessage;
import com.fishingbook.chat.repository.ChatMessageRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChatService {
    
    private final ChatMessageRepository chatMessageRepository;
    private final RabbitTemplate rabbitTemplate;
    private final SimpMessagingTemplate messagingTemplate;
    
    // 활성 사용자 추적을 위한 Set (thread-safe)
    private final Set<String> activeUsers = ConcurrentHashMap.newKeySet();
    
    @Value("${chat.rabbitmq.exchange}")
    private String exchangeName;
    
    @Value("${chat.rabbitmq.routing-key}")
    private String routingKey;
    
    /**
     * 메시지 전송 및 저장
     */
    @Transactional
    public ChatMessageDto sendMessage(ChatMessageDto messageDto) {
        try {
            // 1. 데이터베이스에 저장
            ChatMessage savedMessage = chatMessageRepository.save(messageDto.toEntity());
            ChatMessageDto savedDto = ChatMessageDto.fromEntity(savedMessage);
            
            // 2. RabbitMQ로 메시지 발행
            rabbitTemplate.convertAndSend(exchangeName, routingKey, savedDto);
            log.info("메시지가 RabbitMQ로 발행되었습니다: {}", savedDto.getMessage());
            
            return savedDto;
            
        } catch (Exception e) {
            log.error("메시지 전송 중 오류 발생", e);
            throw new RuntimeException("메시지 전송에 실패했습니다.", e);
        }
    }
    
    /**
     * 사용자 입장 메시지 처리
     */
    @Transactional
    public ChatMessageDto handleUserJoin(String username) {
        // 이미 입장한 사용자인지 확인
        if (activeUsers.contains(username)) {
            log.info("사용자 {}는 이미 입장한 상태입니다.", username);
            return null; // 중복 입장 방지
        }
        
        // 활성 사용자 목록에 추가
        activeUsers.add(username);
        log.info("사용자 {}가 활성 사용자 목록에 추가되었습니다. 현재 활성 사용자: {}", username, activeUsers.size());
        
        ChatMessageDto joinMessage = new ChatMessageDto();
        joinMessage.setUsername("System");
        joinMessage.setMessage(username + "님이 채팅방에 입장했습니다.");
        joinMessage.setType(ChatMessage.MessageType.JOIN);
        joinMessage.setTimestamp(LocalDateTime.now());
        
        return sendMessage(joinMessage);
    }
    
    /**
     * 사용자 퇴장 메시지 처리
     */
    @Transactional
    public ChatMessageDto handleUserLeave(String username) {
        // 활성 사용자 목록에서 제거
        if (activeUsers.remove(username)) {
            log.info("사용자 {}가 활성 사용자 목록에서 제거되었습니다. 현재 활성 사용자: {}", username, activeUsers.size());
            
            ChatMessageDto leaveMessage = new ChatMessageDto();
            leaveMessage.setUsername("System");
            leaveMessage.setMessage(username + "님이 채팅방을 나갔습니다.");
            leaveMessage.setType(ChatMessage.MessageType.LEAVE);
            leaveMessage.setTimestamp(LocalDateTime.now());
            
            return sendMessage(leaveMessage);
        } else {
            log.info("사용자 {}는 활성 사용자 목록에 없습니다.", username);
            return null; // 이미 퇴장한 사용자
        }
    }
    
    /**
     * 최근 메시지 조회
     */
    public List<ChatMessageDto> getRecentMessages(int limit) {
        List<ChatMessage> messages = chatMessageRepository.findTop50ByOrderByTimestampDesc();
        return messages.stream()
                .limit(limit)
                .map(ChatMessageDto::fromEntity)
                .collect(Collectors.toList());
    }
    
    /**
     * 특정 시간 이후 메시지 조회
     */
    public List<ChatMessageDto> getMessagesSince(LocalDateTime since) {
        List<ChatMessage> messages = chatMessageRepository.findByTimestampAfterOrderByTimestampAsc(since);
        return messages.stream()
                .map(ChatMessageDto::fromEntity)
                .collect(Collectors.toList());
    }
    
    /**
     * WebSocket을 통해 모든 클라이언트에게 메시지 브로드캐스트
     */
    public void broadcastMessage(ChatMessageDto message) {
        messagingTemplate.convertAndSend("/topic/messages", message);
        log.info("메시지가 모든 클라이언트에게 브로드캐스트되었습니다: {}", message.getMessage());
    }
} 