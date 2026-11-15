package com.supermarket.web;
import com.supermarket.config.DB;
import com.supermarket.security.Passwords;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.sql.*;
import java.io.*;
@WebServlet("/login")
public class AuthServlet extends BaseServlet {
  @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws IOException,ServletException{view(req,resp,"login");}
  @Override protected void doPost(HttpServletRequest req,HttpServletResponse resp)throws IOException,ServletException{
    req.setCharacterEncoding("UTF-8");String name=req.getParameter("username"),pass=req.getParameter("password");
    if(name==null||pass==null||name.length()>100||pass.length()>1000){req.setAttribute("error","Thông tin đăng nhập không hợp lệ.");view(req,resp,"login");return;}
    try(Connection con=DB.open();PreparedStatement ps=con.prepareStatement("SELECT id,passwordHash,role FROM tblMember4 WHERE userName=?")){
      ps.setString(1,name);try(ResultSet rs=ps.executeQuery()){
        if(rs.next()&&Passwords.verify(pass,rs.getString("passwordHash"))){
          HttpSession old=req.getSession(false);if(old!=null)old.invalidate();
          HttpSession session=req.getSession(true);session.setAttribute("userId",rs.getLong("id"));session.setAttribute("role",rs.getString("role"));session.setMaxInactiveInterval(1800);
          resp.sendRedirect(req.getContextPath()+"/home");return;
        }
      }
      req.setAttribute("error","Tên đăng nhập hoặc mật khẩu không đúng.");view(req,resp,"login");
    }catch(SQLException e){getServletContext().log("DB error login",e);req.setAttribute("error","Không kết nối được cơ sở dữ liệu.");view(req,resp,"login");}
  }
}
