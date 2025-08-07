<%@ Language=VBScript %>
<%
    ' Check if user is logged in
    If Session("username") = "" Then
        Response.Redirect "default.asp"
    End If
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ABC HealthCare - Search Requests</title>
    <link rel="stylesheet" href="css/styles.css">
    <script src="js/search.js"></script>
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
        <div class="search-content">
            <div class="search-window">
                <div class="search-window-header">
                    Search
                </div>
                
                <form method="post" action="search.asp" id="searchForm">
                    <div class="search-form-grid">
                        <div class="form-group form-inline">
                            <label for="episodeCaseNo">Episode/Case No.</label>
                            <input type="text" id="episodeCaseNo" name="episodeCaseNo" value="<%= Request.Form("episodeCaseNo") %>">
                        </div>
                        
                        <div class="form-group form-inline">
                            <label for="patientId">Patient ID</label>
                            <input type="text" id="patientId" name="patientId" value="<%= Request.Form("patientId") %>">
                        </div>
                        
                        <div class="form-group form-inline">
                            <label for="patientName">Patient Name</label>
                            <input type="text" id="patientName" name="patientName" value="<%= Request.Form("patientName") %>">
                        </div>
                        
                        <div class="form-group form-inline">
                            <label for="refPhysicianId">Physician ID</label>
                            <input type="text" id="refPhysicianId" name="refPhysicianId" value="<%= Request.Form("refPhysicianId") %>">
                        </div>
                        
                        <div class="form-group form-inline">
                            <label for="physicianName">Physician Name</label>
                            <input type="text" id="physicianName" name="physicianName" value="<%= Request.Form("physicianName") %>">
                        </div>
                        
                        <div class="form-group form-inline">
                            <label for="siteId">Site ID</label>
                            <input type="text" id="siteId" name="siteId" value="<%= Request.Form("siteId") %>">
                        </div>

                        <div class="form-group form-inline">
                            <label for="siteName">Site Name</label>
                            <input type="text" id="siteName" name="siteName" value="<%= Request.Form("siteName") %>">
                        </div>
                        
                        <div class="form-group form-inline">
                            <label for="cptCode">CPT Code</label>
                            <select id="cptCode" name="cptCode">
                                <option value="">Select CPT Code</option>
                                <option value="99213">99213</option>
                                <option value="99214">99214</option>
                                <option value="99215">99215</option>
                            </select>
                        </div>
                        
                        <div class="form-group form-inline">
                            <label for="payor">Payor</label>
                            <select id="payor" name="payor">
                                <option value="">Select Payor</option>
                                <option value="CIGNA">CIGNA</option>
                                <option value="AETNA">AETNA</option>
                                <option value="HIGHMARK">HIGHMARK</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="search-button-row">
                        <button type="submit" class="btn-search">Search [ENTER]</button>
                        <button type="button" class="btn-search" onclick="clearForm()">Clear</button>
                        <button type="button" class="btn-search" onclick="window.location.href='home.asp'">Close</button>
                    </div>                    
                </form>
            </div>
            
            <div class="search-results">
                
                <% 
                ' Only execute search logic if form was submitted
                If Request.ServerVariables("REQUEST_METHOD") = "POST" And Request.Form.Count > 0 Then
    On Error Resume Next
    Dim conn, cmd, rs, connStr
    connStr = "Provider=SQLOLEDB;Data Source=imageonedb.database.windows.net;Initial Catalog=ImageOne;User ID=ioadmin;Password=io_12345;"
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open connStr
    
    If Err.Number <> 0 Then
        Response.Write "<div style='color:red'>Database Connection Error: " & Err.Description & "</div>"
        Err.Clear
    Else
        Set cmd = Server.CreateObject("ADODB.Command")
        Set cmd.ActiveConnection = conn
        cmd.CommandType = 4 ' adCmdStoredProc
        cmd.CommandText = "SearchEpisode"
        ' Only append parameters if they have values
        If Trim(Request.Form("episodeCaseNo")) <> "" Then
            cmd.Parameters.Append cmd.CreateParameter("@EpisodeID", 200, 1, 15, Request.Form("episodeCaseNo"))
        Else
            cmd.Parameters.Append cmd.CreateParameter("@EpisodeID", 200, 1, 15, Null)
        End If
        If Trim(Request.Form("patientId")) <> "" Then
            cmd.Parameters.Append cmd.CreateParameter("@PatientID", 200, 1, 25, Request.Form("patientId"))
        Else
            cmd.Parameters.Append cmd.CreateParameter("@PatientID", 200, 1, 25, Null)
        End If
        If Trim(Request.Form("patientName")) <> "" Then
            cmd.Parameters.Append cmd.CreateParameter("@PatientName", 200, 1, 35, Request.Form("patientName"))
        Else
            cmd.Parameters.Append cmd.CreateParameter("@PatientName", 200, 1, 35, Null)
        End If
        If Trim(Request.Form("cptCode")) <> "" Then
            cmd.Parameters.Append cmd.CreateParameter("@CPTCode", 200, 1, 6, Request.Form("cptCode"))
        Else
            cmd.Parameters.Append cmd.CreateParameter("@CPTCode", 200, 1, 6, Null)
        End If
        If Trim(Request.Form("refPhysicianId")) <> "" Then
            cmd.Parameters.Append cmd.CreateParameter("@OAOPhysID", 200, 1, 6, Request.Form("refPhysicianId"))
        Else
            cmd.Parameters.Append cmd.CreateParameter("@OAOPhysID", 200, 1, 6, Null)
        End If
        If Trim(Request.Form("physicianName")) <> "" Then
            cmd.Parameters.Append cmd.CreateParameter("@PhysicianName", 200, 1, 100, Request.Form("physicianName"))
        Else
            cmd.Parameters.Append cmd.CreateParameter("@PhysicianName", 200, 1, 100, Null)
        End If
        If Trim(Request.Form("siteId")) <> "" Then
            cmd.Parameters.Append cmd.CreateParameter("@SiteID", 200, 1, 6, Request.Form("siteId"))
        Else
            cmd.Parameters.Append cmd.CreateParameter("@SiteID", 200, 1, 6, Null)
        End If
        If Trim(Request.Form("siteName")) <> "" Then
            cmd.Parameters.Append cmd.CreateParameter("@SiteName", 200, 1, 100, Request.Form("siteName"))
        Else
            cmd.Parameters.Append cmd.CreateParameter("@SiteName", 200, 1, 100, Null)
        End If
        If Trim(Request.Form("payor")) <> "" Then
            cmd.Parameters.Append cmd.CreateParameter("@InsCarrier", 200, 1, 25, Request.Form("payor"))
        Else
            cmd.Parameters.Append cmd.CreateParameter("@InsCarrier", 200, 1, 25, Null)
        End If

        Set rs = cmd.Execute
        If Err.Number <> 0 Then
            Response.Write "<div style='color:red'>Query Execution Error: " & Err.Description & "</div>"
            Err.Clear
        Else
            If Not rs.EOF Then
                %>
                <h3>Search Results</h3>
                <table class="results-table">
                    <thead>
                        <tr>
                            <th>Episode/Case No.</th>
                            <th>InsCarrier</th>
                            <th>Patient ID</th>
                            <th>Patient Name</th>
                            <th>Episode Date</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% Do While Not rs.EOF %>
                        <tr>
                            <td><%= rs("EpisodeID") %></td>
                            <td><%= rs("InsCarrier") %></td>
                            <td><%= rs("PatientID") %></td>
                            <td><%= rs("PatientName") %></td>
                            <td><%= rs("EpisodeDate") %></td>
                            <td>
                                <a href="edit_view.asp?id=<%= rs("EpisodeID") %>" class="btn-small btn-primary">Edit/View</a>
                            </td>
                        </tr>
                        <% rs.MoveNext %>
                        <% Loop %>
                    </tbody>
                </table>
                <% Else
                    Response.Write "<div class='no-records' style='text-align:center;font-weight:bold;margin:24px 0;'>Records not found.</div>"
                        End If ' End If for Not rs.EOF
                      End If   
                    End If ' End If for Err.Number <> 0 (query)
                End If ' End If for Err.Number <> 0 (conn)
                ' Clean up objects safely
                On Error Resume Next
                If IsObject(rs) Then
                    If Not rs Is Nothing Then
                        rs.Close
                        Set rs = Nothing
                    End If
                End If
                If IsObject(conn) Then
                    If Not conn Is Nothing Then
                        conn.Close
                        Set conn = Nothing
                    End If
                End If
                %>
            </div>
        </div>
    </div>
    
    <div class="footer">
        <p>&copy; 2025 ABC HealthCare. All rights reserved.</p>
    </div>
</body>
</html>
