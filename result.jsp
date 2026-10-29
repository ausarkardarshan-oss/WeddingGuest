<%@ page import="java.sql.*" %>
<%
String url=System.getenv("DB_URL");
String user=System.getenv("DB_USER");
String pass=System.getenv("DB_PASSWORD");
String filter=request.getParameter("filter");
String error="";

try {
if(url==null || user==null || pass==null) {
throw new IllegalStateException("DB_URL, DB_USER and DB_PASSWORD must be configured.");
}
Class.forName("com.mysql.cj.jdbc.Driver");
try(Connection con=DriverManager.getConnection(url,user,pass)) {

if("POST".equalsIgnoreCase(request.getMethod())) {
String guest=request.getParameter("guest");
String side=request.getParameter("side");
String city=request.getParameter("city");
int m=0;

try { m=Integer.parseInt(request.getParameter("members")); }
catch(Exception e) { error="Members must be 1 to 10"; }

if(error.isEmpty()) {
if(guest==null || guest.trim().isEmpty() ||
city==null || city.trim().isEmpty() ||
guest.length()>40 || city.length()>30 ||
(!"Bride".equals(side) && !"Groom".equals(side)) ||
m<1 || m>10) error="Invalid input!";
else {
PreparedStatement p=con.prepareStatement(
"INSERT INTO wedding_guest(guest,side,members,city) VALUES(?,?,?,?)");
p.setString(1,guest.trim());
p.setString(2,side);
p.setInt(3,m);
p.setString(4,city.trim());
p.executeUpdate();
}
}
}

boolean f="Bride".equals(filter)||"Groom".equals(filter);
String sql="SELECT * FROM wedding_guest"+(f?" WHERE side=?":"")+" ORDER BY id";
int total=0;
%>

<!DOCTYPE html>
<html>
<head><title>Guest List</title></head>
<body>
<h2>Wedding Guest List</h2>
<p style="color:red"><%=error%></p>

<form action="result.jsp">
Filter:
<select name="filter">
<option value="All">All</option>
<option value="Bride" <%= "Bride".equals(filter)?"selected":"" %>>Bride</option>
<option value="Groom" <%= "Groom".equals(filter)?"selected":"" %>>Groom</option>
</select>
<button>Show</button>
</form>

<table border="1" cellpadding="8">
<tr><th>ID</th><th>Guest</th><th>Side</th><th>Members</th><th>City</th></tr>
<%
try(PreparedStatement p=con.prepareStatement(sql)) {
if(f) p.setString(1,filter);
try(ResultSet r=p.executeQuery()) {
while(r.next()) {
total+=r.getInt("members");
%>
<tr>
<td><%=r.getInt("id")%></td>
<td><%=r.getString("guest")%></td>
<td><%=r.getString("side")%></td>
<td><%=r.getInt("members")%></td>
<td><%=r.getString("city")%></td>
</tr>
<% } } } %>
<tr><th colspan="3">Total Members</th><th colspan="2"><%=total%></th></tr>
</table>
<br><a href="index.html">Add Guest</a>
</body>
</html>

<%
}
} catch(Exception e) {
application.log("Guest list error",e);
out.println("Database error. Check MySQL settings.");
}
%>