UploadFile.jsp

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*, javax.servlet.*"%>
<%@ page import="javax.servlet.http.*"%>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="org.apache.commons.fileupload.disk.*"%>
<%@ page import="org.apache.commons.fileupload.servlet.*"%>
<%@ page import="org.apache.commons.io.output.*"%>
<%@ page import="com.amazonaws.auth.AWSCredentials"%>
<%@ page import="com.amazonaws.auth.BasicAWSCredentials"%>
<%@ page import="com.amazonaws.services.s3.AmazonS3"%>
<%@ page import="com.amazonaws.services.s3.AmazonS3Client"%>
<%@ page import="com.amazonaws.services.s3.model.ObjectMetadata"%>
<%@ page import="com.amazonaws.services.s3.model.PutObjectRequest"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.sql.DriverManager"%>
<%@ page import="java.sql.SQLException"%>
<%@ page import="java.sql.Statement"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="java.sql.PreparedStatement"%>


<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
</head>
<body>

    <%
    	String contentType = request.getContentType();
    	String imageName = "";
    	String desc = "";

    	if ((contentType.indexOf("multipart/form-data") >= 0)) {

    		DiskFileItemFactory factory = new DiskFileItemFactory();
    		ServletFileUpload uploadHandler = new ServletFileUpload(factory);
    		uploadHandler.setSizeMax(1024 * 1024 * 1); //1MB

    		List<FileItem> fileItems = uploadHandler.parseRequest(request);
    		Iterator<FileItem> iterator = fileItems.iterator();

    		try {
    			BasicAWSCredentials awsCredentials = new BasicAWSCredentials("AKIAJBITMRRBRIMPOKXQ",
    					"B810lz/HigDZ5J9ByUlNhUc4XynLX7oRv6c+ZNDg");
    			AmazonS3 s3client = new AmazonS3Client(awsCredentials);

    			while (iterator.hasNext()) {
    				FileItem fileItem = (FileItem) iterator.next();

    				if (fileItem.isFormField()) {

    					String name = fileItem.getFieldName();//description
    					desc = fileItem.getString(); //value of description

    				}
    				if (!fileItem.isFormField()) {
    					String fileName = fileItem.getName();
    					imageName = fileName;
    					boolean isInMemory = fileItem.isInMemory();
    					ObjectMetadata objectMetadata = new ObjectMetadata();
    					objectMetadata.setContentLength(fileItem.getSize());
    					s3client.putObject(new PutObjectRequest("mkhan9", fileName, fileItem.getInputStream(),
    							objectMetadata));
    					out.println("<h1>" + fileName + " uploaded </h1>");

    				}
    			}
    		} catch (Exception e) {
    			out.println(e);
    		}
    	}

    	Statement stmt = null;
    	Connection connection = null;
    	PreparedStatement prep = null;
    	ResultSet rs;

    	try {

    		Class.forName("com.mysql.jdbc.Driver");
    		//Creating a connection to the required database

    		connection = DriverManager.getConnection(
    				"jdbc:mysql://mkhan9.cxjfdlvd1ypl.us-west-2.rds.amazonaws.com/photos", "mkhan9", "bluebird9");
    		stmt = connection.createStatement();
    		prep = connection
    				.prepareStatement("insert into photos.photoDetails(photo_name,photo_description) values(?,?)");
    		prep.setString(1, imageName.trim());
    		imageName = "";
    		prep.setString(2, desc.trim());
    		prep.executeUpdate();
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
    %>

    <h3>
        <a href="index.html"> Back to home page</a>
    </h3>
</body>
</html>
