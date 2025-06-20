package com.fishingbook.chat.controller;

import com.fishingbook.chat.dto.ChatMessageDto;
import com.fishingbook.chat.service.ChatService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "${cors.allowed-origins}")
public class ChatRestController {
    
    private final ChatService chatService;
    
    /**
     * 최근 메시지 조회
     */
    @GetMapping("/messages")
    public ResponseEntity<List<ChatMessageDto>> getRecentMessages(
            @RequestParam(defaultValue = "50") int limit) {
        try {
            List<ChatMessageDto> messages = chatService.getRecentMessages(limit);
            return ResponseEntity.ok(messages);
        } catch (Exception e) {
            log.error("최근 메시지 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 특정 시간 이후 메시지 조회
     */
    @GetMapping("/messages/since")
    public ResponseEntity<List<ChatMessageDto>> getMessagesSince(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime since) {
        try {
            List<ChatMessageDto> messages = chatService.getMessagesSince(since);
            return ResponseEntity.ok(messages);
        } catch (Exception e) {
            log.error("특정 시간 이후 메시지 조회 중 오류 발생", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 헬스 체크
     */
    @GetMapping("/health")
    public ResponseEntity<String> healthCheck() {
        return ResponseEntity.ok("Chat API is running!");
    }
} 