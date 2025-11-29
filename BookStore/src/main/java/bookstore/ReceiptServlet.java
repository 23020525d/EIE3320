package bookstore;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql. Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta. servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta. servlet.http.HttpSession;

@WebServlet("/ReceiptServlet")
public class ReceiptServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String DATABASE_URL = "jdbc:mysql://localhost:3306/books";
    private static final String DB_USER = "guest";
    private static final String DB_PASSWORD = "guest";

    public ReceiptServlet() {
        super();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String customerName = request.getParameter("customerName");
        response.setContentType("text/html");
        PrintWriter out = response. getWriter();
        
        HttpSession session = request.getSession(false);
        ShoppingCart cart = (ShoppingCart) session.getAttribute("bookstore.cart");
        User user = (User) session.getAttribute("currentUser");
        
        // Save purchase history if user is logged in
        if (user != null && cart != null && cart.size() > 0) {
            savePurchaseHistory(user. getUserID(), cart);
        }
        
        // Clear the cart
        if (cart != null) {
            cart. removeAll(cart);
            session.setAttribute("bookstore.cart", cart);
        }
        
        // Print transaction info
        String outStr = "<! DOCTYPE html><html><head>";
        outStr += "<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>";
        outStr += "<meta http-equiv='Refresh' content='5; url=StudentDashboard.jsp'>";
        outStr += "<style>";
        outStr += "body { font-family: Arial; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background-color: #f4f4f4; }";
        outStr += ".receipt { background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); text-align: center; }";
        outStr += ".success-icon { font-size: 48px; margin-bottom: 20px; }";
        outStr += "h2 { color: #4CAF50; }";
        outStr += "</style></head><body>";
        outStr += "<div class='receipt'>";
        outStr += "<div class='success-icon'>✅</div>";
        outStr += "<h2>Thank You for Your Purchase!</h2>";
        outStr += "<p>Dear " + customerName + ", your order has been confirmed.</p>";
        outStr += "<p>You will be redirected to your dashboard in 5 seconds... </p>";
        outStr += "<a href='StudentDashboard.jsp'>Go to Dashboard Now</a>";
        outStr += "</div></body></html>";
        
        out. print(outStr);
        out.close();
    }
    
    private void savePurchaseHistory(int userId, ShoppingCart cart) {
        Connection connection = null;
        PreparedStatement statement = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(DATABASE_URL, DB_USER, DB_PASSWORD);
            
            String query = "INSERT INTO PurchaseHistory (UserID, ISBN, Price, Quantity) VALUES (?, ?, ?, 1)";
            statement = connection.prepareStatement(query);
            
            for (Book book : cart) {
                statement. setInt(1, userId);
                statement.setString(2, book.getIsbn());
                statement.setDouble(3, book.getPrice());
                statement. executeUpdate();
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (statement != null) statement.close();
                if (connection != null) connection.close();
            } catch (Exception e) {}
        }
    }
}
