<html>

<head>
	<title>Book Info.</title>
</head>

<body>
	<%@page import="java.util.ArrayList" %>
	<%@page import="java.util.Date" %>
	<%@page import="bookstore.*" %>

	<%
		ArrayList<Book> books = (ArrayList<Book>)session.getAttribute("foundBooks");
		int numBooks = books.size();
	%>

	<p>Student Name: Tse Wing Ping & Tsui Lap Chi Keith<br>
    Student ID: 23020525D & 23036158D</p>

	<center>The time now is: <%= new Date() %></center>

	<table align="center" border=1  >
		<tr>
			<th>ISBN</th>
			<th>Title</th>
			<th>Author</th>
			<th>Edition Number</th>
			<th>Publisher</th>
			<th>Copyright</th>
			<th></th>
		</tr>
		<!-- For each i, retrieve the information of the i-th book from the ArrayList. -->
		<!-- Display the information in one row per book. -->
		<!-- The last element of each row should contain a link to OrderServlet.class --> 
		<!-- with input parameter "selectedBook" and value equal to i -->
		<%
			if(numBooks != 0){
			for (int i=0; i<numBooks; i++){%>
		<tr>
			<td><%= books.get(i).getIsbn() %> </td>
			<td><%= books.get(i).getTitle() %></td>
			<td><%= books.get(i).getAuthor() %></td>
			<td><%= books.get(i).getEdition() %></td>
			<td><%= books.get(i).getPublisher() %></td>
			<td><%= books.get(i).getCopyright() %></td>
			<td><a href="OrderServlet?selectedBook=<%=i%>">Add to Cart</a></td>
		</tr>
		<%}}else{%>
		<tr>
			<td colspan="7" align="center">No Result</td>
		</tr>
		<%}%>
	</table>
	
	<center><A href="SearchBook.html">Home</A></center>
</body>

</html>