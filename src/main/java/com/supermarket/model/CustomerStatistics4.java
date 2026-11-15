package com.supermarket.model;
public final class CustomerStatistics4 {
  private final Customer4 customer;
  private final java.math.BigDecimal totalRevenue;
  private final int transactionCount;
  private final java.time.LocalDate startDate;
  private final java.time.LocalDate endDate;
  public CustomerStatistics4(Customer4 customer, java.math.BigDecimal totalRevenue, int transactionCount, java.time.LocalDate startDate, java.time.LocalDate endDate){
    this.customer=customer;
    this.totalRevenue=totalRevenue;
    this.transactionCount=transactionCount;
    this.startDate=startDate;
    this.endDate=endDate;
  }
  public Customer4 customer(){return customer;}
  public Customer4 getCustomer(){return customer;}
  public java.math.BigDecimal totalRevenue(){return totalRevenue;}
  public java.math.BigDecimal getTotalRevenue(){return totalRevenue;}
  public int transactionCount(){return transactionCount;}
  public int getTransactionCount(){return transactionCount;}
  public java.time.LocalDate startDate(){return startDate;}
  public java.time.LocalDate getStartDate(){return startDate;}
  public java.time.LocalDate endDate(){return endDate;}
  public java.time.LocalDate getEndDate(){return endDate;}
}
