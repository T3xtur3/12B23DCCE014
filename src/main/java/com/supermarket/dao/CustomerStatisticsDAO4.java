package com.supermarket.dao;
import com.supermarket.config.DB;
import com.supermarket.model.*;
import java.sql.*;
import java.time.LocalDate;
import java.util.*;
public class CustomerStatisticsDAO4 {
  public List<CustomerStatistics4> getCustomerStatistics(LocalDate startDate,LocalDate endDate) throws SQLException {
    String sql="""
      SELECT c.tblMember4id,c.customerCode,c.memberStatus,c.registrationDate,m.fullName,m.dateOfBirth,m.address,m.email,m.phoneNumber,
        COUNT(t.id) AS transactionCount, SUM(t.transactionValue) AS totalRevenue
      FROM tblTransaction4 t JOIN tblCustomer4 c ON c.tblMember4id=t.customerId JOIN tblMember4 m ON m.id=c.tblMember4id
      WHERE t.status='SUCCESS' AND t.transactionTime>=? AND t.transactionTime<?
      GROUP BY c.tblMember4id,c.customerCode,c.memberStatus,c.registrationDate,m.fullName,m.dateOfBirth,m.address,m.email,m.phoneNumber
      ORDER BY totalRevenue DESC,c.customerCode ASC
      """;
    List<CustomerStatistics4> out=new ArrayList<>();
    try(Connection con=DB.open();PreparedStatement ps=con.prepareStatement(sql)){
      ps.setTimestamp(1,Timestamp.valueOf(startDate.atStartOfDay()));ps.setTimestamp(2,Timestamp.valueOf(endDate.plusDays(1).atStartOfDay()));
      try(ResultSet rs=ps.executeQuery()){
        while(rs.next())out.add(new CustomerStatistics4(CustomerDAO4.map(rs),rs.getBigDecimal("totalRevenue"),rs.getInt("transactionCount"),startDate,endDate));
      }
    }
    return out;
  }
}
