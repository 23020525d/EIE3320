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

@WebServlet("/AddBookServlet")
public class AddBookServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String DATABASE_URL = "jdbc:mysql://localhost:3306/books";
    private static final String DB_USER = "guest";
    private static final String DB_PASSWORD = "guest";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check admin access
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("currentUser");
        if (user == null || !user.isAdmin()) {
            response.sendRedirect("Login.html");
            return;
        }
        
        // Get form parameters
        String isbn = request.getParameter("isbn");
        String title = request.getParameter("title");
        String author = request.getParameter("author");
        int edition = Integer.parseInt(request.getParameter("edition"));
        String publisher = request. getParameter("publisher");
        String copyright = request.getParameter("copyright");
        double price = Double.parseDouble(request.getParameter("price"));
        
        Connection connection = null;
        PreparedStatement statement = null;
        
        try {
        	Class. forName("com. mysql.cj. jdbc.Driver");
            connection = DriverManager.getConnection(DATABASE_URL, DB_USER, DB_PASSWORD);
            
            String query = "INSERT INTO BookInfo (ISBN, Title, Author, EditionNumber, Publisher, Copyright, Price) VALUES (?, ?, ?, ?, ?, ?, ?)";
            statement = connection.prepareStatement(query);
            statement.setString(1, isbn);
            statement.setString(2, title);
            statement.setString(3, author);
            statement.setInt(4, edition);
            statement. setString(5, publisher);
            statement.setString(6, copyright);
            statement.setDouble(7, price);
            
            int result = statement.executeUpdate();
            
            if (result > 0) {
                request.setAttribute("message", "Book added successfully!");
                request.setAttribute("messageType", "success");
            } else {
                request.setAttribute("message", "Failed to add book.");
                request.setAttribute("messageType", "error");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Error: " + e.getMessage());
            request. setAttribute("messageType", "error");
        } finally {
            try {
                if (statement != null) statement.close();
                if (connection != null) connection.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/AddBook.jsp");
        dispatcher. forward(request, response);
    }
}