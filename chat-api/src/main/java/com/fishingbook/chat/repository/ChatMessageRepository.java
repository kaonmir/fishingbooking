package com.fishingbook.chat.repository;

import com.fishingbook.chat.entity.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {
    
    // 최신 메시지 조회 (페이징)
    List<ChatMessage> findTop50ByOrderByTimestampDesc();
    
    // 특정 시간 이후 메시지 조회
    List<ChatMessage> findByTimestampAfterOrderByTimestampAsc(LocalDateTime timestamp);
    
    // 특정 사용자의 메시지 조회
    List<ChatMessage> findByUsernameOrderByTimestampDesc(String username);
    
    // 룸별 메시지 조회 (나중에 방 기능 확장시 사용)
    List<ChatMessage> findByRoomIdOrderByTimestampAsc(String roomId);
    
    // 최근 메시지 개수 조회
    @Query("SELECT COUNT(m) FROM ChatMessage m WHERE m.timestamp >= :since")
    long countMessagesSince(@Param("since") LocalDateTime since);
} 