<%@ Language=VBScript %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ABC HealthCare - Prior Authorization System</title>
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>
    <div class="login-container">
        <div class="login-header-section">
            <div class="login-brand">
                <img src="images/abc_healthcare_logo.svg" alt="ABC HealthCare" class="logo">
                <h1>ABC HealthCare Database Management System</h1>
            </div>
        </div>
        
        <div class="login-form-section">
            <form method="post" action="home.asp" class="structured-login-form">
                <div class="form-group">
                    <label for="domain">Domain:</label>
                    <select id="domain" name="domain" required>
                        <option value="">Select Domain</option>
                        <option value="domain1">domain1</option>
                        <option value="domain2">domain2</option>
                        <option value="domain3">domain3</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="username">User Name:</label>
                    <input type="text" id="username" name="username" required>
                </div>
                
                <div class="form-group">
                    <label for="password">Password:</label>
                    <input type="password" id="password" name="password" required>
                </div>
                
                <div class="form-group">
                    <button type="submit" class="btn-login">Login</button>
                </div>
                
                <div class="login-note">
                    <p>Use your Username & Password for login into ABC HealthCare.</p>
                    <p>Call the assigned ABC HealthCare representative for assistance.</p>
                </div>
            </form>
        </div>
        
        <div class="login-footer">
            <p>&copy; 2025 ABC HealthCare. All Rights Reserved.</p>
        </div>
    </div>
</body>
</html>
