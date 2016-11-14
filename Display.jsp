Display.jsp

<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="com.amazonaws.auth.AWSCredentials"%>
<%@ page import="com.amazonaws.auth.BasicAWSCredentials"%>
<%@ page import="com.amazonaws.util.StringUtils"%>
<%@ page import="com.amazonaws.services.s3.AmazonS3"%>
<%@ page import="com.amazonaws.services.s3.AmazonS3Client"%>
<%@ page import="com.amazonaws.services.s3.model.ObjectListing"%>
<%@ page import="com.amazonaws.services.s3.model.S3ObjectSummary"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.sql.DriverManager"%>
<%@ page import="java.sql.SQLException"%>
<%@ page import="java.sql.Statement"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="java.sql.PreparedStatement"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
</head>
<body>

    <%
    	String imageName = "";
    	BasicAWSCredentials awsCredentials = new BasicAWSCredentials("AKIAJBITMRRBRIMPOKXQ",
    			"B810lz/HigDZ5J9ByUlNhUc4XynLX7oRv6c+ZNDg");
    	AmazonS3 s3client = new AmazonS3Client(awsCredentials);
    	ObjectListing objects = s3client.listObjects("mkhan9");
    	do {
    		for (S3ObjectSummary objectSummary : objects.getObjectSummaries()) {
    			imageName = objectSummary.getKey().trim();
    			out.println("<img src=https://s3-ap-southeast-2.amazonaws.com/mkhan9/" + objectSummary.getKey()
    					+ " /> <p> <b>Image Name :</b> " + imageName + "<br />");

    			Statement stmt = null;
    			Connection connection = null;
    			PreparedStatement prep = null;

    			try {

    				Class.forName("com.mysql.jdbc.Driver");
    				//Creating a connection to the required database

    				connection = DriverManager.getConnection(
    						"jdbc:mysql://mkhan9.cxjfdlvd1ypl.us-west-2.rds.amazonaws.com/photos", "mkhan9",
    						"bluebird9");
    				stmt = connection.createStatement();
    				String sqlQuery = "select photo_description from photos.photoDetails where photo_name = ?";
    				prep = connection.prepareStatement(sqlQuery);
    				prep.setString(1, imageName.trim());
    				ResultSet rs = prep.executeQuery();
    				while (rs.next()) {
    					String imgDes = rs.getString("photo_description");
    					out.println("<br/><p><b>Image Description: </b>" + imgDes + "</p><br />");
    				}
    				rs.close();
    				imageName = "";
    				connection.close();

    			} catch (SQLException ex) {
    				// handle any errors
    				out.println("SQLException: " + ex.getMessage());
    				out.println("SQLState: " + ex.getSQLState());
    				out.println("VendorError: " + ex.getErrorCode());
    			}
    			//After the entire execution this block will execute and the connection with database gets closed

    			finally {

    				try {
    					connection.close();
    				} catch (Exception e) {
    					// TODO Auto-generated catch block
    					e.printStackTrace();
    				}

    			}
    		}
    		objects = s3client.listNextBatchOfObjects(objects);
    	} while (objects.isTruncated());
    %>


    <h3>
        <a href="index.html"> Back to home page</a>
    </h3>


</body>
</html>
