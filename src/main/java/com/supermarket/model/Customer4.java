package com.supermarket.model;
public final class Customer4 {
  private final long id;
  private final String customerCode;
  private final boolean memberStatus;
  private final java.time.LocalDate registrationDate;
  private final String fullName;
  private final java.time.LocalDate dateOfBirth;
  private final String address;
  private final String email;
  private final String phoneNumber;
  public Customer4(long id, String customerCode, boolean memberStatus, java.time.LocalDate registrationDate, String fullName, java.time.LocalDate dateOfBirth, String address, String email, String phoneNumber){
    this.id=id;
    this.customerCode=customerCode;
    this.memberStatus=memberStatus;
    this.registrationDate=registrationDate;
    this.fullName=fullName;
    this.dateOfBirth=dateOfBirth;
    this.address=address;
    this.email=email;
    this.phoneNumber=phoneNumber;
  }
  public long id(){return id;}
  public long getId(){return id;}
  public String customerCode(){return customerCode;}
  public String getCustomerCode(){return customerCode;}
  public boolean memberStatus(){return memberStatus;}
  public boolean getMemberStatus(){return memberStatus;}
  public java.time.LocalDate registrationDate(){return registrationDate;}
  public java.time.LocalDate getRegistrationDate(){return registrationDate;}
  public String fullName(){return fullName;}
  public String getFullName(){return fullName;}
  public java.time.LocalDate dateOfBirth(){return dateOfBirth;}
  public java.time.LocalDate getDateOfBirth(){return dateOfBirth;}
  public String address(){return address;}
  public String getAddress(){return address;}
  public String email(){return email;}
  public String getEmail(){return email;}
  public String phoneNumber(){return phoneNumber;}
  public String getPhoneNumber(){return phoneNumber;}
  public boolean isMemberStatus(){return memberStatus;}
}
