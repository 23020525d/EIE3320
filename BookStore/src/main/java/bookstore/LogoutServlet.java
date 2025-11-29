package bookstore;

import jakarta. servlet.ServletException;
import jakarta.servlet.annotation. WebServlet;
import jakarta.servlet. http.HttpServlet;
import jakarta. servlet.http.HttpServletRequest;
import jakarta.servlet. http.HttpServletResponse;
import jakarta.servlet. http.HttpSession;

import java.io.IOException;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public LogoutServlet() {
        super();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Get current session
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            // Invalidate the session
            session. invalidate();
        }
        
        // Redirect to login page
        response. sendRedirect("Login.html");
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}