package bookstore;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql. DriverManager;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta. servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http. HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet. http.HttpSession;

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
        
        boolean purchaseSaved = false;
        int itemsSaved = 0;
        
        // Save purchase history if user is logged in and cart has items
        if (user != null && cart != null && cart. size() > 0) {
            itemsSaved = savePurchaseHistory(user.getUserID(), cart);
            purchaseSaved = (itemsSaved > 0);
        }
        
        // Get total before clearing cart
        double total = (cart != null) ? cart. getTotalPrice() : 0;
        
        // Clear the cart after saving
        if (cart != null) {
            cart. removeAll(cart);
            session.setAttribute("bookstore.cart", cart);
        }
        
        // Build receipt page
        String outStr = "<!DOCTYPE html><html><head>";
        outStr += "<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>";
        outStr += "<meta http-equiv='Refresh' content='5; url=StudentDashboard. jsp'>";
        outStr += "<style>";
        outStr += "body { font-family: Arial, sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background-color: #f4f4f4; }";
        outStr += ".receipt { background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); text-align: center; max-width: 500px; }";
        outStr += ". success-icon { font-size: 64px; margin-bottom: 20px; }";
        outStr += "h2 { color: #4CAF50; margin-bottom: 20px; }";
        outStr += "p { color: #666; margin: 10px 0; }";
        outStr += ". total { font-size: 24px; color: #d32f2f; font-weight: bold; }";
        outStr += ".btn { display: inline-block; padding: 12px 24px; background-color: #1976D2; color: white; text-decoration: none; border-radius: 4px; margin-top: 20px; }";
        outStr += ".btn:hover { background-color: #1565C0; }";
        outStr += "</style></head><body>";
        outStr += "<div class='receipt'>";
        outStr += "<div class='success-icon'>✅</div>";
        outStr += "<h2>Thank You for Your Purchase!</h2>";
        outStr += "<p>Dear <strong>" + customerName + "</strong>, your order has been confirmed.</p>";
        outStr += "<p class='total'>Total: $" + String.format("%.2f", total) + "</p>";
        
        if (purchaseSaved) {
            outStr += "<p>" + itemsSaved + " item(s) saved to your purchase history.</p>";
        } else if (user == null) {
            outStr += "<p>Note: Login to save your purchase history.</p>";
        }
        
        outStr += "<p>You will be redirected in 5 seconds... </p>";
        outStr += "<a href='StudentDashboard.jsp' class='btn'>Go to Dashboard</a>";
        outStr += "</div></body></html>";
        
        out. print(outStr);
        out.close();
    }
    
    private int savePurchaseHistory(int userId, ShoppingCart cart) {
        Connection connection = null;
        PreparedStatement statement = null;
        int savedCount = 0;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(DATABASE_URL, DB_USER, DB_PASSWORD);
            
            String query = "INSERT INTO PurchaseHistory (UserID, ISBN, Price, Quantity) VALUES (?, ?, ?, ?)";
            statement = connection. prepareStatement(query);
            
            for (Book book : cart) {
                statement. setInt(1, userId);
                statement.setString(2, book.getIsbn());
                statement.setDouble(3, book.getPrice());
                statement. setInt(4, 1);
                
                int result = statement.executeUpdate();
                if (result > 0) {
                    savedCount++;
                }
                
                System.out.println("Saved purchase: UserID=" + userId + ", ISBN=" + book.getIsbn() + ", Price=" + book.getPrice());
            }
            
            System.out.println("Total items saved: " + savedCount);
            
        } catch (Exception e) {
            System.err.println("Error saving purchase history: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (statement != null) statement. close();
                if (connection != null) connection.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        return savedCount;
    }
}