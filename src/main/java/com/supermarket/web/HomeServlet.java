package com.supermarket.web;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.*;
@WebServlet({"/home","/logout"})
public class HomeServlet extends BaseServlet {
  @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws IOException,ServletException {
    if(req.getServletPath().equals("/logout")){HttpSession s=req.getSession(false);if(s!=null)s.invalidate();resp.sendRedirect(req.getContextPath()+"/login");return;}
    if(userId(req)==null){resp.sendRedirect(req.getContextPath()+"/login");return;}view(req,resp,"home");
  }
}
