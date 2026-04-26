package org.example.model;

import java.util.Date;

public class ChatMessage {
    private int id;
    private String requestNo;
    private String senderId;
    private String senderRole;
    private String message;
    private Date sentAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getRequestNo() { return requestNo; }
    public void setRequestNo(String requestNo) { this.requestNo = requestNo; }
    public String getSenderId() { return senderId; }
    public void setSenderId(String senderId) { this.senderId = senderId; }
    public String getSenderRole() { return senderRole; }
    public void setSenderRole(String senderRole) { this.senderRole = senderRole; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public Date getSentAt() { return sentAt; }
    public void setSentAt(Date sentAt) { this.sentAt = sentAt; }
}