package com.supermarket.model;
public final class Transaction4 {
  private final long id;
  private final String transactionCode;
  private final java.time.LocalDateTime transactionTime;
  private final java.math.BigDecimal transactionValue;
  private final String status;
  private final long customerId;
  public Transaction4(long id, String transactionCode, java.time.LocalDateTime transactionTime, java.math.BigDecimal transactionValue, String status, long customerId){
    this.id=id;
    this.transactionCode=transactionCode;
    this.transactionTime=transactionTime;
    this.transactionValue=transactionValue;
    this.status=status;
    this.customerId=customerId;
  }
  public long id(){return id;}
  public long getId(){return id;}
  public String transactionCode(){return transactionCode;}
  public String getTransactionCode(){return transactionCode;}
  public java.time.LocalDateTime transactionTime(){return transactionTime;}
  public java.time.LocalDateTime getTransactionTime(){return transactionTime;}
  public java.math.BigDecimal transactionValue(){return transactionValue;}
  public java.math.BigDecimal getTransactionValue(){return transactionValue;}
  public String status(){return status;}
  public String getStatus(){return status;}
  public long customerId(){return customerId;}
  public long getCustomerId(){return customerId;}
}
