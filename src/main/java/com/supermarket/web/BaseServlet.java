package com.supermarket.web;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.IOException;
public abstract class BaseServlet extends HttpServlet {
  protected Long userId(HttpServletRequest req){HttpSession s=req.getSession(false);return s==null?null:(Long)s.getAttribute("userId");}
  protected String role(HttpServletRequest req){HttpSession s=req.getSession(false);return s==null?null:(String)s.getAttribute("role");}
  protected boolean requireRole(HttpServletRequest req,HttpServletResponse resp,String expected)throws IOException {
    if(userId(req)==null){resp.sendRedirect(req.getContextPath()+"/login");return false;}
    if(!expected.equals(role(req))){resp.sendError(403,"Khong co quyen");return false;}
    return true;
  }
  protected void view(HttpServletRequest req,HttpServletResponse resp,String page)throws ServletException,IOException{req.getRequestDispatcher("/WEB-INF/views/"+page+".jsp").forward(req,resp);}
}
