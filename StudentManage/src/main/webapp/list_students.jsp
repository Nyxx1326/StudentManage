<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Student List</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }

        h1 {
            color: #333;
        }

        /* Success/Error Messages */
        .message {
            padding: 10px;
            margin-bottom: 20px;
            border-radius: 5px;
        }

        .success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        /* Centered search form */
        form {
            text-align: center;
            margin-bottom: 20px;
        }

        form input[type="text"] {
            padding: 8px;
            width: 200px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }

        form button {
            padding: 8px 16px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }

        form a {
            margin-left: 10px;
            color: #007bff;
            text-decoration: none;
        }

        /* Centered Add button */
        .btn {
            display: inline-block;
            padding: 10px 20px;
            margin: 0 auto 20px auto;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }

        /* Table styling */
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
        }

        th {
            background-color: #007bff;
            color: white;
            padding: 12px;
            text-align: left;
        }

        td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }

        tr:hover {
            background-color: #f8f9fa;
        }

        .action-link {
            color: #007bff;
            text-decoration: none;
            margin-right: 10px;
        }

        .delete-link {
            color: #dc3545;
        }

        /* Pagination centered */
        .pagination {
            text-align: center;
            margin-top: 20px;
        }

        .pagination a {
            display: inline-block;
            padding: 5px 10px;
            margin: 0 3px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 3px;
        }

        .pagination a.active {
            background-color: #0056b3;
        }

        /* Responsive Table */
        .table-responsive {
            overflow-x: auto;
        }

        @media (max-width: 768px) {
            table {
                font-size: 12px;
            }

            th, td {
                padding: 5px;
            }

            form input[type="text"] {
                width: 150px;
            }

            form button {
                padding: 6px 12px;
            }

            .btn {
                padding: 8px 16px;
            }
        }
    </style>

    <script>
        // Auto-hide messages after 3s
        setTimeout(function() {
            var messages = document.querySelectorAll('.message');
            messages.forEach(function(msg) { msg.style.display = 'none'; });
        }, 3000);

        // Disable submit button and show processing
        function submitForm(form) {
            var btn = form.querySelector('button[type="submit"]');
            btn.disabled = true;
            btn.textContent = 'Processing...';
            return true;
        }
    </script>
</head>
<body>
<h1>📚 Student Management System</h1>

<%
    String keyword = request.getParameter("keyword");
    String pageParam = request.getParameter("page");
    int currentPage = (pageParam != null) ? Integer.parseInt(pageParam) : 1;

    int recordPerPage = 10;
    int offset = (currentPage - 1) * recordPerPage;
%>

<% if (request.getParameter("message") != null) { %>
<div class="message success">
    <%= request.getParameter("message") %>
</div>
<% } %>

<% if (request.getParameter("error") != null) { %>
<div class="message error">
    <%= request.getParameter("error") %>
</div>
<% } %>

<form action="list_students.jsp" method="GET">
    <input type="text" name="keyword" placeholder="Search by name or code...">
    <button type="submit">Search</button>
    <a href="list_students.jsp">Clear</a>
</form>


<a href="add_student.jsp" class="btn">➕ Add New Student</a>

<table>
    <thead>
    <tr>
        <th>ID</th>
        <th>Student Code</th>
        <th>Full Name</th>
        <th>Email</th>
        <th>Major</th>
        <th>Created At</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <%
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3366/student_management",
                    "root",
                    "Trung2511."
            );

            String sql="";

            if (keyword != null && !keyword.isEmpty()) {
                sql = "SELECT * FROM students WHERE full_name LIKE ? OR student_code LIKE ? OR major LIKE ? ORDER BY id DESC LIMIT ? OFFSET ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, "%" + keyword + "%");
                pstmt.setString(2, "%" + keyword + "%");
                pstmt.setString(3, "%" + keyword + "%");
                pstmt.setInt(4, recordPerPage);
                pstmt.setInt(5, offset);
            } else {

                sql = "SELECT * FROM students ORDER BY id DESC LIMIT ? OFFSET ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, recordPerPage);
                pstmt.setInt(2, offset);
            }
            rs = pstmt.executeQuery();

            while (rs.next()) {
                int id = rs.getInt("id");
                String studentCode = rs.getString("student_code");
                String fullName = rs.getString("full_name");
                String email = rs.getString("email");
                String major = rs.getString("major");
                Timestamp createdAt = rs.getTimestamp("created_at");
    %>
    <tr>
        <td><%= id %></td>
        <td><%= studentCode %></td>
        <td><%= fullName %></td>
        <td><%= email != null ? email : "N/A" %></td>
        <td><%= major != null ? major : "N/A" %></td>
        <td><%= createdAt %></td>
        <td>
            <a href="edit_student.jsp?id=<%= id %>" class="action-link">✏️ Edit</a>
            <a href="delete_student.jsp?id=<%= id %>"
                class="action-link delete-link"
                onclick="return confirm('Are you sure?')">🗑️ Delete</a>
        </td>
    </tr>
    <%
            }
            rs.close();
            pstmt.close();

            int totalRecords = 0;
            if (keyword != null && !keyword.isEmpty()) {
                sql = "SELECT COUNT(*) FROM students WHERE full_name LIKE ? OR student_code LIKE ? OR major LIKE ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, "%" + keyword + "%");
                pstmt.setString(2, "%" + keyword + "%");
                pstmt.setString(3, "%" + keyword + "%");
            } else {
                sql = "SELECT COUNT(*) FROM students";
                pstmt = conn.prepareStatement(sql);
            }
            rs = pstmt.executeQuery();
            if (rs.next()) totalRecords = rs.getInt(1);

            int totalPages = (int)Math.ceil(totalRecords * 1.0 / recordPerPage);
            rs.close();
            pstmt.close();
            conn.close();
    %>
    </tbody>
</table>
<div class="pagination">
<%
    String baseUrl = "list_students.jsp?" + (keyword != null && !keyword.isEmpty() ? "keyword=" + keyword + "&" : "");

    if (currentPage > 1) {
%>
    <a href="<%= baseUrl %>page=<%= currentPage - 1 %>">Previous</a>
<%
    }

    int start = Math.max(1, currentPage - 2);
    int end = Math.min(totalPages, currentPage + 2);

    for (int i = start; i <= end; i++) {
        if (i == currentPage) {
%>
    <a class="active" href="#"><%= i %></a>
<%
        } else {
%>
    <a href="<%= baseUrl %>page=<%= i %>"><%= i %></a>
<%
        }
    }

    if (currentPage < totalPages) {
%>
    <a href="<%= baseUrl %>page=<%= currentPage + 1 %>">Next</a>
<%
    }
%>
</div>
    <%
        }
    catch (ClassNotFoundException e) {
        out.println("<tr><td colspan='7'>Error: JDBC Driver not found!</td></tr>");
        e.printStackTrace();
    } catch (SQLException e) {
        out.println("<tr><td colspan='7'>Database Error: " + e.getMessage() + "</td></tr>");
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
</body>
</html>
