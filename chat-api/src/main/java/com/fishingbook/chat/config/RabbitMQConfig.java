package com.fishingbook.chat.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.amqp.core.*;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMQConfig {
    
    @Value("${chat.rabbitmq.exchange}")
    private String exchangeName;
    
    @Value("${chat.rabbitmq.queue}")
    private String queueName;
    
    @Value("${chat.rabbitmq.routing-key}")
    private String routingKey;
    
    // Exchange 생성
    @Bean
    public TopicExchange chatExchange() {
        return new TopicExchange(exchangeName);
    }
    
    // Queue 생성
    @Bean
    public Queue chatQueue() {
        return QueueBuilder.durable(queueName).build();
    }
    
    // Exchange와 Queue 바인딩
    @Bean
    public Binding chatBinding() {
        return BindingBuilder
                .bind(chatQueue())
                .to(chatExchange())
                .with(routingKey);
    }
    
    // JSON 메시지 변환기
    @Bean
    public Jackson2JsonMessageConverter messageConverter() {
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        objectMapper.disable(com.fasterxml.jackson.databind.SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
        
        Jackson2JsonMessageConverter converter = new Jackson2JsonMessageConverter(objectMapper);
        return converter;
    }
    
    // RabbitTemplate 설정
    @Bean
    public RabbitTemplate rabbitTemplate(ConnectionFactory connectionFactory) {
        RabbitTemplate template = new RabbitTemplate(connectionFactory);
        template.setMessageConverter(messageConverter());
        return template;
    }
} 