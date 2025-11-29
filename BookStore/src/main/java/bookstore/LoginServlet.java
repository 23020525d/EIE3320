package bookstore;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http. HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http. HttpSession;

import java.io. IOException;
import java.sql.Connection;
import java.sql. DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String DATABASE_URL = "jdbc:mysql://localhost:3306/books";
    private static final String DB_USER = "guest";
    private static final String DB_PASSWORD = "guest";

    public LoginServlet() {
        super();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String url = "/Login.html";
        
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;
        
        try {
            // Load JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Connect to database
            connection = DriverManager.getConnection(DATABASE_URL, DB_USER, DB_PASSWORD);
            
            // Use PreparedStatement to prevent SQL injection
            String query = "SELECT * FROM Users WHERE Username = ? AND Password = ?";
            statement = connection.prepareStatement(query);
            statement.setString(1, username);
            statement. setString(2, password);
            
            resultSet = statement.executeQuery();
            
            if (resultSet.next()) {
                // User found - create User object
                User user = new User(
                    resultSet. getInt("UserID"),
                    resultSet.getString("Username"),
                    resultSet.getString("Password"),
                    resultSet.getString("Role")
                );
                
                // Create session and store user
                HttpSession session = request.getSession(true);
                session.setAttribute("currentUser", user);
                session.setAttribute("isLoggedIn", true);
                
                // Redirect based on role
                if (user.isAdmin()) {
                    url = "/AdminDashboard.jsp";
                } else if (user.isStudent()) {
                    url = "/StudentDashboard.jsp";
                }
                
                System.out.println("Login successful: " + username + " (Role: " + user.getRole() + ")");
                
            } else {
                // Invalid credentials
            	
                request.setAttribute("errorMessage", "Invalid username or password");
                System.out.println("Login failed for: " + username);
            }
            
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database driver not found");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database error occurred");
        } finally {
            // Close resources
            try {
                if (resultSet != null) resultSet.close();
                if (statement != null) statement.close();
                if (connection != null) connection.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        // Forward to appropriate page
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher(url);
        dispatcher.forward(request, response);
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to login page
        response.sendRedirect("Login.html");
    }
}
