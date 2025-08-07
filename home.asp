<%@ Language=VBScript %>
<%
    ' Check if user is logged in
    If Request.Form("username") = "" And Session("username") = "" Then
        Response.Redirect "default.asp"
    End If
    
    If Request.Form("username") <> "" Then
        Session("username") = Request.Form("username")
    End If
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ABC HealthCare - Home</title>
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>
    <div class="header">
        <div class="header-content">
            <img src="images/abc_healthcare_logo.svg" alt="ABC HealthCare" class="logo">
            <h1>Prior Authorization System</h1>
            <div class="user-info">
                Welcome, <%= Session("username") %> | <a href="logout.asp">Logout</a>
            </div>
        </div>
    </div>
    
    <div class="main-container">
        <div class="dashboard-content">
            <div class="dashboard-header">
                <h2>------------ Pre-Authorization Database ------------</h2>
                <div class="environment-info">
                    <p>ABC HealthCare</p>
                </div>
            </div>
            
            <div class="dashboard-sections">
                <div class="dashboard-column">
                    <h3>Data Entry</h3>
                    <div class="button-section">
                        <a href="add_new.asp" class="btn-dashboard btn-primary">Add New</a>
                        <a href="search.asp" class="btn-dashboard btn-secondary">Edit / View</a>
                        <a href="#" class="btn-dashboard btn-secondary">Clinical Needed</a>
                        <a href="#" class="btn-dashboard btn-secondary">Scheduling</a>                        
                    </div>
                </div>
                
                <div class="dashboard-column">
                    <h3>Control</h3>
                    <div class="button-section">
                        <a href="#" class="btn-dashboard btn-secondary">Eligibility</a>
                        <a href="#" class="btn-dashboard btn-secondary">Patient CallBack</a>
                        
                    </div>
                </div>
                
                <div class="dashboard-column">
                    <h3>Tools</h3>
                    <div class="button-section">
                        <a href="#" class="btn-dashboard btn-secondary">Licensure</a>
                    </div>
                </div>
            </div>
            
            <div class="dashboard-footer-section">
                <div class="dashboard-actions">
                    <a href="logout.asp" class="btn-dashboard btn-secondary">Exit</a>
                </div>
                
                <div class="dashboard-status">
                    <p>Welcome: <%= Session("username") %></p>
                    <p>Environment: abc.healthdev1</p>
                    <p>Version: 1.05.15.02A</p>
                </div>
                
                
            </div>
        </div>
    </div>
    
    <div class="footer">
        <p>&copy; 2025 ABC HealthCare. All rights reserved.</p>
    </div>
</body>
</html>
