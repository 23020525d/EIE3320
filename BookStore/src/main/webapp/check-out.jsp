<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bookstore.*" %>
<%@ page import="java.util.ArrayList" %>
<%
    ShoppingCart cart = (ShoppingCart) session.getAttribute("bookstore.cart");
    double total = cart != null ? cart.getTotalPrice() : 0;
    User user = (User) session. getAttribute("currentUser");
    String defaultName = user != null ? user.getUsername() : "";
%>
<! DOCTYPE html>
<html>
<head>
    <title>Checkout</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }
        .navbar {
            background-color: #1976D2;
            color: white;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .navbar h1 { font-size: 24px; margin: 0; }
        .navbar-links a {
            color: white;
            text-decoration: none;
            padding: 8px 16px;
            border-radius: 4px;
            margin-left: 10px;
        }
        . navbar-links a:hover { background-color: rgba(255,255,255,0.1); }
        .container {
            max-width: 500px;
            margin: 50px auto;
            padding: 0 20px;
        }
        .checkout-container {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .checkout-container h2 {
            margin-bottom: 20px;
            color: #333;
            text-align: center;
        }
        .order-summary {
            background-color: #f9f9f9;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
            text-align: center;
        }
        .order-summary . total {
            font-size: 24px;
            color: #d32f2f;
            font-weight: bold;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
        }
        .form-group input {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            box-sizing: border-box;
        }
        .form-group input:focus {
            border-color: #1976D2;
            outline: none;
        }
        . btn {
            padding: 12px 24px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            margin-right: 10px;
        }
        .btn-primary { background-color: #4CAF50; color: white; }
        .btn-primary:hover { background-color: #45a049; }
        .btn-secondary { background-color: #757575; color: white; }
        . btn-secondary:hover { background-color: #616161; }
        .action-buttons { text-align: center; margin-top: 20px; }
    </style>
    <script type="text/JavaScript">
        function validateForm() {
            var name = document.checkout.customerName.value. trim();
            var cardNumber = document.checkout.cardNumber.value.trim();
            
            if (name === "" || cardNumber === "") {
                alert("Missing Name or Credit Card Number");
                return false;
            }
            if (isNaN(cardNumber)) {
                alert("Invalid Credit Card Number");
                return false;
            }
            return true;
        }
    </script>
</head>
<body>
    <div class="navbar">
        <h1>Checkout</h1>
        <div class="navbar-links">
            <a href="show-order.jsp">Back to Cart</a>
            <a href="StudentDashboard.jsp">Dashboard</a>
        </div>
    </div>
    
    <div class="container">
        <div class="checkout-container">
            <h2>Complete Your Purchase</h2>
            
            <div class="order-summary">
                <p>Order Total:</p>
                <p class="total">$<%= String.format("%.2f", total) %></p>
            </div>
            
            <form name="checkout" onsubmit="return validateForm()" method="post" action="ReceiptServlet">
                <div class="form-group">
                    <label for="customerName">Full Name:</label>
                    <input type="text" id="customerName" name="customerName" value="<%= defaultName %>" placeholder="Enter your full name" required>
                </div>
                
                <div class="form-group">
                    <label for="cardNumber">Credit Card Number:</label>
                    <input type="text" id="cardNumber" name="cardNumber" placeholder="Enter 16-digit card number" maxlength="16" required>
                </div>
                
                <div class="action-buttons">
                    <button type="submit" class="btn btn-primary">Complete Purchase</button>
                    <button type="button" class="btn btn-secondary" onclick="window. location='show-order.jsp';">Cancel</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>