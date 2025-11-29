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

@WebServlet("/DeleteBookServlet")
public class DeleteBookServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String DATABASE_URL = "jdbc:mysql://localhost:3306/books";
    private static final String DB_USER = "guest";
    private static final String DB_PASSWORD = "guest";

    public DeleteBookServlet() {
        super();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request. getSession(false);
        User user = (User) session.getAttribute("currentUser");
        if (user == null || !user.isAdmin()) {
            response.sendRedirect("Login.html");
            return;
        }
        
        String isbn = request.getParameter("isbn");
        Connection connection = null;
        PreparedStatement statement = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(DATABASE_URL, DB_USER, DB_PASSWORD);
            
            // First delete from AuthorISBN (due to foreign key constraint)
            String deleteAuthorISBN = "DELETE FROM AuthorISBN WHERE ISBN = ?";
            statement = connection.prepareStatement(deleteAuthorISBN);
            statement.setString(1, isbn);
            statement. executeUpdate();
            statement.close();
            
            // Then delete from BookInfo
            String deleteBook = "DELETE FROM BookInfo WHERE ISBN = ? ";
            statement = connection.prepareStatement(deleteBook);
            statement.setString(1, isbn);
            int result = statement.executeUpdate();
            
            if (result > 0) {
                request.setAttribute("message", "Book deleted successfully!");
                request.setAttribute("messageType", "success");
            } else {
                request.setAttribute("message", "Failed to delete book.");
                request.setAttribute("messageType", "error");
            }
            
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            request.setAttribute("message", "Database driver not found: " + e.getMessage());
            request. setAttribute("messageType", "error");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Error: " + e.getMessage());
            request. setAttribute("messageType", "error");
        } finally {
            try {
                if (statement != null) statement. close();
                if (connection != null) connection.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/ManageBooks.jsp");
        dispatcher.forward(request, response);
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}