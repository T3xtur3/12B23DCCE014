package com.supermarket.web;
import com.supermarket.dao.CustomerDAO4;
import com.supermarket.model.Customer4;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.time.LocalDate;
import java.sql.SQLException;
import java.io.*;
@WebServlet({"/member/register","/member/confirm"})
public class RegisterMemberServlet extends BaseServlet {
  private final CustomerDAO4 dao=new CustomerDAO4();
  @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws IOException,ServletException {
    if(!requireRole(req,resp,"CUSTOMER"))return;
    if(req.getServletPath().endsWith("/confirm")){resp.sendRedirect(req.getContextPath()+"/member/register");return;}
    try{
      Customer4 c=dao.getCustomerById(userId(req));if(c==null){resp.sendError(404);return;}
      req.setAttribute("customer",c);view(req,resp,"register");
    }catch(SQLException e){getServletContext().log("DB error register page",e);resp.sendError(500,"Loi co so du lieu");}
  }
  private String field(HttpServletRequest req,String key){String v=req.getParameter(key);return v==null?"":v.trim();}
  @Override protected void doPost(HttpServletRequest req,HttpServletResponse resp)throws IOException,ServletException {
    if(!requireRole(req,resp,"CUSTOMER"))return;req.setCharacterEncoding("UTF-8");
    try {
      Customer4 c=dao.getCustomerById(userId(req));if(c==null){resp.sendError(404);return;}
      if(req.getServletPath().endsWith("/confirm")){
        Pending pending=(Pending)req.getSession().getAttribute("pendingRegistration");
        if(pending==null){resp.sendRedirect(req.getContextPath()+"/member/register");return;}
        boolean ok=dao.registerMember(userId(req),pending.name(),pending.dob(),pending.address(),pending.email(),pending.phone());
        req.getSession().removeAttribute("pendingRegistration");req.setAttribute("success",ok);view(req,resp,"result");return;
      }
      String name=field(req,"fullName"),dobS=field(req,"dateOfBirth"),address=field(req,"address"),email=field(req,"email"),phone=field(req,"phoneNumber");
      LocalDate dob;try{dob=LocalDate.parse(dobS);}catch(Exception e){dob=null;}
      req.setAttribute("fullName",name);req.setAttribute("dateOfBirth",dobS);req.setAttribute("address",address);req.setAttribute("email",email);req.setAttribute("phoneNumber",phone);req.setAttribute("customer",c);
      if(!dao.validateCustomerInformation(name,dob,address,email,phone)){
        req.setAttribute("error","Thông tin không hợp lệ. Vui lòng kiểm tra các trường và định dạng số điện thoại 10 chữ số.");view(req,resp,"register");return;
      }
      if(dao.isRegisteredMember(userId(req),email,phone)){
        req.setAttribute("error","Khách hàng đã là thành viên hoặc email/số điện thoại trùng với hồ sơ khác.");view(req,resp,"register");return;
      }
      if(req.getServletPath().endsWith("/register")){
        // Store entered fields server side. Never trust the second POST body for payment/registration identity.
        HttpSession s=req.getSession();s.setAttribute("pendingRegistration",new Pending(name,dob,address,email,phone));
        view(req,resp,"confirm");return;
      }
    }catch(SQLException e){getServletContext().log("DB error register submit",e);req.setAttribute("success",false);view(req,resp,"result");}
  }
  public record Pending(String name,LocalDate dob,String address,String email,String phone) implements java.io.Serializable {
    public String getName(){return name;}
    public LocalDate getDob(){return dob;}
    public String getAddress(){return address;}
    public String getEmail(){return email;}
    public String getPhone(){return phone;}
  }
}
