package bookstore;

import java.io.IOException;
import java.util.ArrayList;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Servlet implementation class QueryServlet
 */
@WebServlet("/QueryServlet")
public class QueryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public QueryServlet() {
        super();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        java.sql.Connection connection = null; // manages connection
        java.sql.Statement statement = null; // query statement
        java.sql.ResultSet resultSet = null; // manages results
        String DATABASE_URL = "jdbc:mysql://localhost:3306/Books";

        // create a new ArrayList of Book objects
        ArrayList<Book> foundBooks = new ArrayList<>();

        // get the session object; if there is no existing session, create a new one
        HttpSession session = request.getSession(true);

        // get the ISBN value from the form
        String isbn = safeTrim(request.getParameter("isbn"));

        // get the Author name from the form
        String author = safeTrim(request.getParameter("author"));

        // load JDBC driver
        try {
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
        } catch (InstantiationException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }

        // connect to database Books and query database
        try {
            connection = java.sql.DriverManager.getConnection(DATABASE_URL, "guest", "guest");
            statement = connection.createStatement();

            // build query based on provided inputs (ISBN or Author)
            StringBuilder queryBuilder = new StringBuilder("SELECT * FROM bookinfo");
            boolean hasIsbn = !isBlank(isbn);
            boolean hasAuthor = !isBlank(author);

            if (hasIsbn || hasAuthor) {
                queryBuilder.append(" WHERE ");
                if (hasIsbn) {
                    queryBuilder.append("ISBN LIKE '%").append(escapeLike(isbn)).append("%'");
                }
                if (hasAuthor) {
                    if (hasIsbn) {
                        queryBuilder.append(" OR ");
                    }
                    queryBuilder.append("Author LIKE '%").append(escapeLike(author)).append("%'");
                }
            }

            String query = queryBuilder.toString();
            System.out.println(query);

            resultSet = statement.executeQuery(query);

            while (resultSet.next()) {
                isbn = (String) resultSet.getObject(1);
                String title = (String) resultSet.getObject(2);
                author = (String) resultSet.getObject(3);
                int edition = (Integer) resultSet.getObject(4);
                String publisher = (String) resultSet.getObject(5);
                String copyright = (String) resultSet.getObject(6);
                double price = (Double) resultSet.getObject(7);

                // Create a new Book object and add it to foundBooks
                foundBooks.add(new Book(isbn, author, title, price, edition, publisher, copyright));

                System.out.println(title + "; " + edition + "; " + publisher + "; " + copyright);
            }

            session.setAttribute("foundBooks", foundBooks);

            // Forward the control to BookInfo.jsp
            ServletContext context = getServletContext();
            RequestDispatcher dispatcher = context.getRequestDispatcher("/BookInfo.jsp");
            dispatcher.forward(request, response);

        } catch (java.sql.SQLException sqlException) {
            sqlException.printStackTrace();
            throw new ServletException("Database error occurred", sqlException);
        } finally {
            try {
                if (resultSet != null) resultSet.close();
                if (statement != null) statement.close();
                if (connection != null) connection.close();
            } catch (Exception exception) {
                exception.printStackTrace();
            }
        }
    }

    private String safeTrim(String s) {
        return s == null ? "" : s.trim();
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    // Basic escaping for % and _ in LIKE clauses
    private String escapeLike(String s) {
        return s.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_");
    }
}