package com.supermarket.web;
import com.supermarket.dao.*;
import com.supermarket.model.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.*;
import java.time.LocalDate;
import java.sql.SQLException;
import java.util.*;
@WebServlet({"/statistics/types","/statistics/period","/statistics/customers","/statistics/customer","/statistics/transactions"})
public class StatsServlet extends BaseServlet {
  private final CustomerStatisticsDAO4 statisticsDAO=new CustomerStatisticsDAO4();
  private final CustomerDAO4 customerDAO=new CustomerDAO4();
  private final TransactionDAO4 transactionDAO=new TransactionDAO4();
  private LocalDate parse(String s){if(s==null)return null;try{return LocalDate.parse(s);}catch(Exception e){return null;}}
  @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws IOException,ServletException{
    if(!requireRole(req,resp,"MANAGEMENT"))return;
    String p=req.getServletPath();
    if(p.endsWith("/types")){view(req,resp,"types");return;}
    if(p.endsWith("/period")){view(req,resp,"period");return;}
    LocalDate start=parse(req.getParameter("startDate")),end=parse(req.getParameter("endDate"));
    if(start==null||end==null||start.isAfter(end)||end.isAfter(LocalDate.now().plusDays(1))||start.isBefore(LocalDate.of(2000,1,1))){req.setAttribute("error","Khoảng thời gian không hợp lệ.");view(req,resp,"period");return;}
    req.setAttribute("startDate",start.toString());req.setAttribute("endDate",end.toString());
    try{
      if(p.endsWith("/customers")){
        req.setAttribute("statistics",statisticsDAO.getCustomerStatistics(start,end));view(req,resp,"statistics");return;
      }
      long customerId;try{customerId=Long.parseLong(req.getParameter("customerId"));}catch(Exception e){resp.sendError(400);return;}
      Customer4 c=customerDAO.getCustomerDetail(customerId);if(c==null){resp.sendError(404);return;}
      req.setAttribute("customer",c);
      // Calculate interval revenue using exactly the same semantics as the statistics page.
      Optional<CustomerStatistics4> stat=statisticsDAO.getCustomerStatistics(start,end).stream().filter(x->x.customer().id()==customerId).findFirst();
      if(stat.isEmpty()){resp.sendError(404,"Khach hang khong thuoc danh sach thong ke cua ky nay");return;}
      req.setAttribute("selectedStatistics",stat.get());
      if(p.endsWith("/customer")){view(req,resp,"detail");return;}
      if(p.endsWith("/transactions")){
        req.setAttribute("transactions",transactionDAO.getTransactionsByCustomer(customerId,start,end));view(req,resp,"transactions");return;
      }
      resp.sendError(404);
    }catch(SQLException e){getServletContext().log("DB statistics error",e);resp.sendError(500,"Loi co so du lieu");}
  }
}
