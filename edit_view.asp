<%@ Language=VBScript %>
<%
    ' Check if user is logged in
    If Session("username") = "" Then
        Response.Redirect "default.asp"
    End If
    
    Dim requestId
    requestId = Request.QueryString("id")
    If requestId = "" Then
        Response.Redirect "search.asp"
    End If
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ABC HealthCare - Edit/View Request</title>
    <link rel="stylesheet" href="css/styles.css">
    <script src="js/compiled/form.js"></script>
</head>
<body>
<%
    
    ' Fetch data for this requestId 
    On Error Resume Next
    Set conn = Server.CreateObject("ADODB.Connection")
    connStr = "Provider=SQLOLEDB;Data Source=imageonedb.database.windows.net;Initial Catalog=ImageOne;User ID=ioadmin;Password=io_12345;"
    conn.Open connStr
    If Err.Number <> 0 Then
        Response.Write "<div style='color:red;text-align:center;font-weight:bold;'>Database Connection Error: " & Err.Description & "</div>"
        Err.Clear
    Else
        sql = "SELECT TOP 1 * FROM [dbo].[tblAuthorization] ta " & _
              "JOIN [dbo].[tblpatient] tp ON ta.EpisodeID = tp.EpisodeID " & _
              "JOIN [dbo].[tblSite] ts ON ta.EpisodeID = ts.EpisodeID " & _
              "JOIN [dbo].[tblPhysician] tph ON ta.EpisodeID = tph.EpisodeID " & _
              "WHERE ta.EpisodeID = '" & Replace(requestId, "'", "''") & "'"
        Set rs = conn.Execute(sql)
        If Err.Number <> 0 Then
            Response.Write "<div style='color:red;text-align:center;font-weight:bold;'>Query Execution Error: " & Err.Description & "</div>"
            Err.Clear
        End If
    End If 
%>
    <% If Session("formErrors") <> "" Then %>
    <script type="text/javascript">
        window.serverFormError = '<%= Replace(Replace(Session("formErrors"), "'", "\'"), "\n", " ") %>';
    </script>
    <% Session("formErrors") = "" %>
    <% End If %>
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
        <div class="form-content">
            <div class="form-window">
                <div class="form-toolbar">
                    <button type="submit" form="requestForm" class="btn-toolbar">Save</button>
                    <a href="#" class="btn-toolbar">Duplicate</a>
                    <a href="home.asp" class="btn-toolbar">Close</a>                    
                    <a href="#" class="btn-toolbar">Print</a>
                    <a href="#" class="btn-toolbar">Help</a>
                </div>
                
                <div class="form-header-info">
                    <strong>Edit/View</strong> Request - <span class="request-id"><%= requestId %></span>
                </div>
                
                <% ' Handle form submission
                If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
                    %><!--#include file="common.asp"--><%
                    Dim params, field, errors, result, status, msg
                    Set params = Server.CreateObject("Scripting.Dictionary")
                    errors = ""
                    For Each field In Request.Form
                        params.Add field, Request.Form(field)
                    Next
                    If params.Exists("patientId") And params("patientId") = "" Then errors = errors & "Patient ID is required.<br>"
                    If params.Exists("physicianId") And params("physicianId") = "" Then errors = errors & "Physician ID is required.<br>"
                    If params.Exists("siteId") And params("siteId") = "" Then errors = errors & "Site ID is required.<br>"
                    If params.Exists("diagnosisCode") And params("diagnosisCode") = "" Then errors = errors & "Diagnosis Code is required.<br>"
                    If errors = "" Then
                        result = UpsertPriorAuthorizationData(params)
                        
                        If InStr(result, "|") > 0 Then
                            status = Split(result, "|")(0)
                        Else
                            status = result
                        End If

                        Dim jsMsg, jsType
                        If status = "SUCCESS" Then
                            jsMsg = "Case Updated Successfully"
                            jsType = "success"
                        Else
                            jsMsg = result
                            jsType = "error"
                        End If
                        Response.Write "<script type='text/javascript'>window.formSaveResult = { message: '" & Replace(jsMsg, "'", "\'") & "', type: '" & jsType & "' };</script>"
                    Else
                        Response.Write "<script type='text/javascript'>window.formSaveResult = { message: '" & Replace(errors, "'", "\'") & "', type: 'error' };</script>"
                        Response.Write "<div id='formSaveResultMsg' style='color:red;text-align:center;font-weight:bold;'>" & errors & "</div>"
                    End If
                End If
                %>
                <form method="post" action="edit_view.asp?id=<%= requestId %>" id="requestForm">
                    <input type="hidden" name="mode" value="edit">
                    <input type="hidden" name="requestId" value="<%= requestId %>">
                     <div class="form-content-grid">
                        <% If IsObject(rs) And Not rs Is Nothing And Not rs.EOF Then %>                        
                        <div class="form-group form-inline">
                            <label for="episodeNo">Episode No.</label>
                            <input type="text" id="episodeNo" name="episodeNo" value="<%= rs("EpisodeID") %>">
                        </div>
                        <!-- <div class="form-group form-inline">
                            <label for="episodeDate">Episode Date</label>
                            <input type="text" id="episodeDate" name="episodeDate" value="<%= rs("DateCreated") %>">
                        </div>
                        <div class="form-group form-inline">
                            <label for="expires">Expires</label>
                            <input type="text" id="expires" name="expires" value="<%= rs("ExpDate") %>">
                        </div> -->
                        <!-- <div class="form-group form-inline">
                            <label for="priority">Priority</label>
                            <select id="priority" name="priority">
                                <option value="R" <% If rs("Priority") = "R" Then Response.Write "selected" %>>R</option>
                                <option value="U" <% If rs("Priority") = "U" Then Response.Write "selected" %>>U</option>
                                <option value="E" <% If rs("Priority") = "E" Then Response.Write "selected" %>>E</option>
                            </select>
                        </div> -->
                        <!-- <div class="form-group form-inline">
                            <label for="approvedDate">Approved Date</label>
                            <input type="text" id="approvedDate" name="approvedDate" value="<%= rs("ApprovedDate") %>">
                        </div> -->
                        <div class="form-group form-inline">
                            <label for="companyId">Company Id</label>
                            <input type="text" id="program" name="program" value="<%= rs("CompanyID") %>">
                        </div>
                        <div class="form-group form-inline">
                            <label for="payor">Payor</label>
                            <input type="text" id="payor" name="payor" value="<%= rs("InsCarrier") %>">
                        </div>
                        <div class="form-group form-inline">
                            <label for="cptCode">CPT Code</label>
                            <input type="text" id="cptCode" name="cptCode" value="<%= rs("CPTCode") %>">
                        </div>
                        <div class="form-group form-inline">
                            <label for="patientName">Patient Name</label>
                            <input type="text" id="patientName" name="patientName" value="<%= rs("PatientName") %>">
                        </div>
                        <div class="form-group form-inline">
                            <label for="patientId">Patient ID</label>
                            <input type="text" id="patientId" name="patientId" value="<%= rs("PatientID") %>">
                        </div>
                        <div class="form-group form-inline">
                            <label for="memCode">Mem Code</label>
                            <input type="text" id="patientMemberCode" name="patientMemberCode" value="<%= rs("PatientMemberCode") %>">
                        </div>
                        <div class="form-group form-inline">
                            <label for="patientDob">Patient DOB</label>
                            <input type="text" id="patientDob" name="patientDob" value="<%= rs("PatientDOB") %>">
                        </div>
                        <div class="form-group form-inline">
                            <label for="physName">Phys. Name</label>
                            <input type="text" id="physicianName" name="physicianName" value="<%= rs("PhysName") %>">
                        </div>
                        <div class="form-group form-inline">
                            <label for="siteName">Site Name</label>
                            <input type="text" id="siteName" name="siteName" value="<%= rs("SiteName") %>">
                        </div>
                        <div class="form-group form-inline" style="display:none;">                            
                            <input type="text" id="patientSex" name="patientSex" value="<%= rs("PatientSex") %>">
                            <input type="text" id="patientAddr1" name="patientAddr1" value="<%= rs("PatientAddr1") %>">
                            <input type="text" id="patientCity" name="patientCity" value="<%= rs("PatientCity") %>">
                            <input type="text" id="patientState" name="patientState" value="<%= rs("PatientState") %>">
                            <input type="text" id="patientZip" name="patientZip" value="<%= rs("PatientZip") %>">
                            <input type="text" id="patientPhone" name="patientPhone" value="<%= rs("PatientPhone") %>">
                            <input type="text" id="groupNumber" name="groupNumber" value="<%= rs("GroupNumber") %>">
                            <input type="text" id="physicianId" name="physicianId" value="<%= rs("OAOPhysID") %>">
                            <input type="text" id="siteId" name="siteId" value="<%= rs("OAOSiteID") %>">
                        </div>
                        <% Else %>
                        <div style="text-align:center;font-weight:bold;color:red;grid-column:1/3;">No data found for this request.</div>
                        <% End If %>
                    </div>
                     
                    <!-- <div class="form-navigation">         
                        <input type="text" value="1" style="width: 40px; text-align: center;">
                        <a href="#" class="btn-nav">Go!</a>                      
                    </div> -->
                </form>
            </div>
        </div>
    </div>
    
    <div class="footer">
        <p>&copy; 2025 ABC HealthCare. All rights reserved.</p>
    </div>
</body>
</html>
