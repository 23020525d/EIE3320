package bookstore;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;

/**
 * Servlet implementation class OrderServlet
 */
@WebServlet("/OrderServlet")
public class OrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public OrderServlet() {
        super();
    }

    @Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String url = "/show-order.jsp";
		ShoppingCart cart;
		ArrayList<Book> books;

		// Get the session object, making sure that the user cannot access this servlet
		// directly
		// If the user attempts to accesses this servlet directly, forward the user to
		// he/she
		// SearchBook.html.
		HttpSession session = request.getSession(false);
		if (session == null) {
			url = "/SearchBook.html";
		}

		try {
			// Get the ShoppingCart object (namely cart) from the session object.
			// If cart is null, create a new ShoppingCart object and create an
			// association between the String "bookstore.cart" and the newly created object.
			if (session.getAttribute("bookstore.cart") == null) {
				session.setAttribute("bookstore.cart", new ShoppingCart());
			}
			cart = (ShoppingCart) session.getAttribute("bookstore.cart");

			// Get the ArrayList object (namely books) from the session object. This
			// ArrayList
			// object, which was created in QueryServlet.class, contains the book objects
			// that
			// match the search criteria specified in SearchBook.html
			books = (ArrayList<Book>) session.getAttribute("foundBooks");

			// Get the index of the selected book from BookInfo.jsp
			int selectedBook = Integer.valueOf(request.getParameter("selectedBook")).intValue();

			// Add the the selected book object to the Shopping cart
			cart.addBook(books.get(selectedBook));

			// Forward the control to either show-order.jsp or SearchBook.html
			session.setAttribute("bookstore.cart", cart);
			ServletContext context = getServletContext();
			RequestDispatcher dispatcher = context.getRequestDispatcher(url);
			dispatcher.forward(request, response);
		} catch (Exception exception) {
			exception.printStackTrace();
		}
	}

   
}