package com.supermarket.dao;
import com.supermarket.config.DB;
import com.supermarket.model.Transaction4;
import java.time.LocalDate;
import java.sql.*;
import java.util.*;
public class TransactionDAO4 {
  public List<Transaction4> getTransactionsByCustomer(long customerId, LocalDate startDate, LocalDate endDate) throws SQLException {
    List<Transaction4> out=new ArrayList<>();
    String sql="SELECT id,transactionCode,transactionTime,transactionValue,status,customerId FROM tblTransaction4 WHERE customerId=? AND status='SUCCESS' AND transactionTime>=? AND transactionTime<? ORDER BY transactionTime,id";
    try(Connection con=DB.open();PreparedStatement ps=con.prepareStatement(sql)){
      ps.setLong(1,customerId);ps.setTimestamp(2,Timestamp.valueOf(startDate.atStartOfDay()));ps.setTimestamp(3,Timestamp.valueOf(endDate.plusDays(1).atStartOfDay()));
      try(ResultSet rs=ps.executeQuery()){
        while(rs.next())out.add(new Transaction4(rs.getLong("id"),rs.getString("transactionCode"),rs.getTimestamp("transactionTime").toLocalDateTime(),rs.getBigDecimal("transactionValue"),rs.getString("status"),rs.getLong("customerId")));
      }
    }return out;
  }
}
