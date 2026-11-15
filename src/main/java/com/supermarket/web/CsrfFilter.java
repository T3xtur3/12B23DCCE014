package com.supermarket.web;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.*;
import java.security.SecureRandom;
import java.util.Base64;
@WebFilter("/*")
public class CsrfFilter implements Filter {
  private final SecureRandom rand=new SecureRandom();
  @Override public void doFilter(ServletRequest request,ServletResponse response,FilterChain chain)throws IOException,ServletException{
    HttpServletRequest req=(HttpServletRequest)request;HttpServletResponse resp=(HttpServletResponse)response;
    req.setCharacterEncoding("UTF-8");
    HttpSession session=req.getSession(true);String token=(String)session.getAttribute("csrfToken");
    if(token==null){byte[] b=new byte[32];rand.nextBytes(b);token=Base64.getUrlEncoder().withoutPadding().encodeToString(b);session.setAttribute("csrfToken",token);}
    req.setAttribute("csrfToken",token);
    if("POST".equalsIgnoreCase(req.getMethod())&&!token.equals(req.getParameter("csrfToken"))){resp.sendError(403,"CSRF token invalid");return;}
    resp.setHeader("X-Content-Type-Options","nosniff");resp.setHeader("X-Frame-Options","DENY");
    chain.doFilter(request,response);
  }
}
