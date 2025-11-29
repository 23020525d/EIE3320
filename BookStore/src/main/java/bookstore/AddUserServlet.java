package bookstore;

import jakarta. servlet.RequestDispatcher;
import jakarta. servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http. HttpServlet;
import jakarta.servlet. http.HttpServletRequest;
import jakarta.servlet.http. HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java. io.IOException;
import java. sql.Connection;
import java.sql. DriverManager;
import java.sql. PreparedStatement;
import java.sql. ResultSet;

@WebServlet("/AddUserServlet")
public class AddUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String DATABASE_URL = "jdbc:mysql://localhost:3306/books";
    private static final String DB_USER = "guest";
    private static final String DB_PASSWORD = "guest";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request. getSession(false);
        User user = (User) session. getAttribute("currentUser");
        if (user == null || !user.isAdmin()) {
            response.sendRedirect("Login. html");
            return;
        }
        
        String username = request.getParameter("username");
        String password = request. getParameter("password");
        String role = request.getParameter("role");
        
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql. cj.jdbc. Driver");
            connection = DriverManager. getConnection(DATABASE_URL, DB_USER, DB_PASSWORD);
            
            // Check if username already exists
            String checkQuery = "SELECT COUNT(*) FROM Users WHERE Username = ? ";
            statement = connection.prepareStatement(checkQuery);
            statement.setString(1, username);
            rs = statement.executeQuery();
            rs.next();
            
            if (rs.getInt(1) > 0) {
                request.setAttribute("message", "Username already exists!");
                request. setAttribute("messageType", "error");
            } else {
                statement.close();
                
                // Insert new user
                String insertQuery = "INSERT INTO Users (Username, Password, Role) VALUES (?, ?, ?)";
                statement = connection.prepareStatement(insertQuery);
                statement.setString(1, username);
                statement. setString(2, password);
                statement.setString(3, role);
                
                int result = statement.executeUpdate();
                
                if (result > 0) {
                    request.setAttribute("message", "User '" + username + "' added successfully!");
                    request.setAttribute("messageType", "success");
                } else {
                    request.setAttribute("message", "Failed to add user.");
                    request.setAttribute("messageType", "error");
                }
            }
            
        } catch (Exception e) {
            e. printStackTrace();
            request.setAttribute("message", "Error: " + e.getMessage());
            request.setAttribute("messageType", "error");
        } finally {
            try {
                if (rs != null) rs. close();
                if (statement != null) statement.close();
                if (connection != null) connection.close();
            } catch (Exception e) {}
        }
        
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/AddUser.jsp");
        dispatcher. forward(request, response);
    }
}
