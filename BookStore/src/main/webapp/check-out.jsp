<html>

<head>
	<title>Check Out</title>
	<script type="text/JavaScript">
		function validateForm() {
    		if(isBlank(document.checkout.customerName.value) || isBlank(document.checkout.cardNumber.value)){
    			alert("Missing Name or Credit Card Number");
    			return false;
    		}
    		else if(isNaN(document.checkout.cardNumber.value)){
    			alert("Invalid Credit Card Number");
    			return false;
    		}
    		else{
    			return true;
			}
		}

		function isBlank(s) {
			for (var i = 0; i < s.length; i++) {
				if (s.charAt(i) != " "){
					return false;
				}
			}
			return true;
		}
	</script>
</head>

<body>
	<%@page import="bookstore.*" %>
	<%@page import="java.util.ArrayList" %>

	<%
		// Get the ShoppingCart object through the session object.
		ShoppingCart cart = (ShoppingCart) session.getAttribute("bookstore.cart");
		// Compute the total price of all books in the shopping cart
		double total = cart.getTotalPrice();
	%>
	
	Your total purchase is: <%=total %> <p></p>
	To purchase the item in your shopping cart, please provide us the following information:
	
	<form name="checkout" onsubmit="return validateForm()" method="post" action="ReceiptServlet">
		<b>Name: </b> <input type="text" name="customerName" size=55 value="Tse Wing Ping & Tsui Lap Chi Keith (23020525D & 23036158D)"><br>
		<b>Credit Card Number</b><input type="text" name="cardNumber" size=16 value="1111222233334444"> <br>
		<input type="submit" value="Submit Information"> &nbsp; &nbsp; 
		<input type="button" value="Cancel" onClick="JavaScript:window.location='show-order.jsp';">
	</form>	
</body>

</html>