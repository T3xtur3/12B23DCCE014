package com.supermarket.dao;
import com.supermarket.config.DB;
import com.supermarket.model.Customer4;
import java.sql.*;
import java.time.LocalDate;
public class CustomerDAO4 {
  public Customer4 getCustomerById(long customerId) throws SQLException {
    String sql="SELECT c.tblMember4id,c.customerCode,c.memberStatus,c.registrationDate,m.fullName,m.dateOfBirth,m.address,m.email,m.phoneNumber FROM tblCustomer4 c JOIN tblMember4 m ON m.id=c.tblMember4id WHERE c.tblMember4id=?";
    try(Connection con=DB.open();PreparedStatement ps=con.prepareStatement(sql)){
      ps.setLong(1,customerId);try(ResultSet rs=ps.executeQuery()){return rs.next()?map(rs):null;}
    }
  }
  static Customer4 map(ResultSet rs) throws SQLException {
    Date reg=rs.getDate("registrationDate"), dob=rs.getDate("dateOfBirth");
    return new Customer4(rs.getLong("tblMember4id"),rs.getString("customerCode"),rs.getBoolean("memberStatus"),reg==null?null:reg.toLocalDate(),rs.getString("fullName"),dob==null?null:dob.toLocalDate(),rs.getString("address"),rs.getString("email"),rs.getString("phoneNumber"));
  }
  public boolean validateCustomerInformation(String fullName,LocalDate dateOfBirth,String address,String email,String phoneNumber){
    return fullName!=null&&fullName.trim().length()>=2&&fullName.trim().length()<=150&&dateOfBirth!=null&&dateOfBirth.isBefore(LocalDate.now())&&dateOfBirth.isAfter(LocalDate.of(1900,1,1))&&address!=null&&!address.isBlank()&&address.length()<=255&&email!=null&&email.length()<=255&&email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")&&phoneNumber!=null&&phoneNumber.matches("^0[0-9]{9}$");
  }
  // true means current customer is registered OR email/phone belongs to another member account
  public boolean isRegisteredMember(long customerId,String email,String phoneNumber) throws SQLException {
    String sql="SELECT (SELECT memberStatus FROM tblCustomer4 WHERE tblMember4id=?) AS registered,(SELECT COUNT(*) FROM tblMember4 WHERE id<>? AND (LOWER(email)=LOWER(?) OR phoneNumber=?)) AS duplicates";
    try(Connection con=DB.open();PreparedStatement ps=con.prepareStatement(sql)){
      ps.setLong(1,customerId);ps.setLong(2,customerId);ps.setString(3,email);ps.setString(4,phoneNumber);
      try(ResultSet rs=ps.executeQuery()){return !rs.next()||rs.getBoolean("registered")||rs.getLong("duplicates")>0;}
    }
  }
  public boolean registerMember(long customerId,String fullName,LocalDate dateOfBirth,String address,String email,String phoneNumber) throws SQLException {
    if(!validateCustomerInformation(fullName,dateOfBirth,address,email,phoneNumber))return false;
    try(Connection con=DB.open()) {
      con.setAutoCommit(false);
      try {
        try(PreparedStatement lock=con.prepareStatement("SELECT memberStatus FROM tblCustomer4 WHERE tblMember4id=? FOR UPDATE")){
          lock.setLong(1,customerId);try(ResultSet rs=lock.executeQuery()){if(!rs.next()||rs.getBoolean(1)){con.rollback();return false;}}
        }
        try(PreparedStatement dup=con.prepareStatement("SELECT id FROM tblMember4 WHERE id<>? AND (LOWER(email)=LOWER(?) OR phoneNumber=?) LIMIT 1")){
          dup.setLong(1,customerId);dup.setString(2,email);dup.setString(3,phoneNumber);
          try(ResultSet rs=dup.executeQuery()){if(rs.next()){con.rollback();return false;}}
        }
        try(PreparedStatement upd=con.prepareStatement("UPDATE tblMember4 SET fullName=?,dateOfBirth=?,address=?,email=?,phoneNumber=? WHERE id=?")){
          upd.setString(1,fullName.trim());upd.setDate(2,Date.valueOf(dateOfBirth));upd.setString(3,address.trim());upd.setString(4,email.trim());upd.setString(5,phoneNumber.trim());upd.setLong(6,customerId);
          if(upd.executeUpdate()!=1){con.rollback();return false;}
        }
        try(PreparedStatement upd=con.prepareStatement("UPDATE tblCustomer4 SET memberStatus=TRUE, registrationDate=CURRENT_DATE() WHERE tblMember4id=? AND memberStatus=FALSE")){
          upd.setLong(1,customerId);if(upd.executeUpdate()!=1){con.rollback();return false;}
        }
        con.commit();return true;
      } catch(SQLException|RuntimeException e){con.rollback();throw e;} finally{con.setAutoCommit(true);}
    }
  }
  public Customer4 getCustomerDetail(long customerId) throws SQLException {return getCustomerById(customerId);}
}
