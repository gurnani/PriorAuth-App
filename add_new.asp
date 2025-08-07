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
    <title>ABC HealthCare - Add New Request</title>
    <link rel="stylesheet" href="css/styles.css">
    <script src="js/compiled/form.js"></script>
</head>
<body>
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
                    <a href="#" class="btn-toolbar" onclick="document.getElementById('requestForm').reset();return false;">Clear</a>
                    <a href="home.asp" class="btn-toolbar">Close</a>
                </div>
                
                <div class="form-header-info">
                    <strong>Add New</strong>
                </div>
                
                <% ' Handle form submission
                If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
                    %><!--#include file="common.asp"--><% 
                    Dim params, field, errors, result, status, msg
                    Set params = Server.CreateObject("Scripting.Dictionary")
                    errors = ""
                    ' Collect all relevant form fields
                    For Each field In Request.Form
                        params.Add field, Request.Form(field)
                    Next
                    ' Basic required field validation (add more as needed)
                    If params.Exists("patientId") And params("patientId") = "" Then errors = errors & "Patient ID is required.<br>"
                    If params.Exists("physicianId") And params("physicianId") = "" Then errors = errors & "Physician ID is required.<br>"
                    If params.Exists("siteId") And params("siteId") = "" Then errors = errors & "Site ID is required.<br>"
                    If params.Exists("diagnosisCode") And params("diagnosisCode") = "" Then errors = errors & "Diagnosis Code is required.<br>"
                    If errors = "" Then
                        Dim jsMsg, jsType, episodeId
                        result = UpsertPriorAuthorizationData(params)

                        If InStr(result, "|") > 0 Then
                            status = Split(result, "|")(0)
                            episodeId = Split(result, "|")(1)
                        Else
                            status = result
                        End If

                        If status = "SUCCESS" Then
                            jsMsg = "Case Created Successfully - Episode ID: " & episodeId
                            jsType = "success"
                        Else
                            jsMsg = result
                            jsType = "error"
                        End If
                        Response.Write "<script type='text/javascript'>window.formSaveResult = { message: '" & Replace(jsMsg, "'", "\'") & "', type: '" & jsType & "' };</script>"
                        'If jsType = "success" Then
                           'Response.Write "<div id='formSaveResultMsg' style='color:green;text-align:center;font-weight:bold;'>" & jsMsg & "</div>"
                        'Else
                           'Response.Write "<div id='formSaveResultMsg' style='color:red;text-align:center;font-weight:bold;'>" & jsMsg & "</div>"
                        'End If
                    Else
                        Response.Write "<script type='text/javascript'>window.formSaveResult = { message: '" & Replace(errors, "'", "\'") & "', type: 'error' };</script>"
                        'Response.Write "<div id='formSaveResultMsg' style='color:red;text-align:center;font-weight:bold;'>" & errors & "</div>"
                    End If
                End If
                %>
                <form method="post" action="add_new.asp" id="requestForm">
                    <input type="hidden" name="mode" value="add">
                    
                    <div class="form-content-grid">
                        <div class="form-group form-inline">
                            <label for="episodeNo">Episode No.</label><input type="text" id="episodeNo" name="episodeNo" readonly>
                        </div>
                        <div class="form-group form-inline">
                            <label for="episodeDate">Episode Date</label><input type="text" id="episodeDate" name="episodeDate" readonly>
                        </div>
                        <div class="form-group form-inline">
                            <label for="payor">Payor</label><select id="payor" name="payor">
                                <option value="">Select Payor</option>
                                <option value="CIGNA">CIGNA</option>
                                <option value="AETNA">AETNA</option>
                                <option value="HIGHMARK">HIGHMARK</option>
                            </select>
                        </div>
                        <div class="form-group form-inline">
                            <label for="program">Program</label><select id="program" name="program">
                                <option value="0">Select Program</option>
                                <option value="1">Radiology</option>
                                <option value="2">Cardiology</option>
                            </select>
                        </div>
                        <div class="form-group form-inline">
                            <label for="cptCode">CPT Code</label><select id="cptCode" name="cptCode">
                                <option value="0">Select CPT Code</option>
                                <option value="99213">99213</option>
                                <option value="99214">99214</option>
                                <option value="99215">99215</option>
                            </select>
                        </div>
                        <div class="form-group form-inline">
                            <label for="patientId">Patient ID</label><input type="text" id="patientId" name="patientId" value="123"><button type="button" class="btn-lookup" onclick="openPatientLookup()">Lookup</button>
                        </div>
                        <div class="form-group form-inline">
                            <label for="patientMemberCode">Member Code</label><input type="text" id="patientMemberCode" name="patientMemberCode" readonly>
                        </div>
                        <div class="form-group form-inline">
                            <label for="patientDob">Patient DOB</label><input type="text" id="patientDob" name="patientDob" readonly>
                        </div>
                        <div class="form-group form-inline">
                            <label for="patientName">Patient Name</label><input type="text" id="patientName" name="patientName" readonly>
                        </div>
                        <div class="form-group form-inline">
                            <label for="patientSex">Patient Sex</label><input type="text" id="patientSex" name="patientSex" readonly>
                        </div>
                        <div class="form-group form-inline">
                            <label for="patientAddr1">Address</label><input type="text" id="patientAddr1" name="patientAddr1" readonly>
                        </div>
                        <div class="form-group form-inline">
                            <label for="patientCity">City</label><input type="text" id="patientCity" name="patientCity" readonly>
                        </div>
                        <div class="form-group form-inline">
                            <label for="patientState">State</label><input type="text" id="patientState" name="patientState" readonly>
                        </div>
                        <div class="form-group form-inline">
                            <label for="patientZip">Zip</label><input type="text" id="patientZip" name="patientZip" readonly>
                        </div>
                        <div class="form-group form-inline">
                            <label for="patientPhone">Phone</label><input type="text" id="patientPhone" name="patientPhone" readonly>
                        </div>
                        <div class="form-group form-inline">
                            <label for="groupNumber">Group Number</label><input type="text" id="groupNumber" name="groupNumber" readonly>
                        </div>
                        <!-- Physician Lookup Section -->
                        <div class="form-group form-inline">
                            <label for="physicianId">Physician ID</label><input type="text" id="physicianId" name="physicianId" value="ph123"><button type="button" class="btn-lookup" onclick="openPhysicianLookup()">Lookup</button>
                        </div>
                        <div class="form-group form-inline">
                            <label for="physicianName">Physician Name</label><input type="text" id="physicianName" name="physicianName" readonly>
                        </div>
                        <!-- Site Lookup Section -->
                        <div class="form-group form-inline">
                            <label for="siteId">Site ID</label><input type="text" id="siteId" name="siteId" value="site123"><button type="button" class="btn-lookup" onclick="openSiteLookup()">Lookup</button>
                        </div>
                        <div class="form-group form-inline">
                            <label for="siteName">Site Name</label><input type="text" id="siteName" name="siteName" readonly>
                        </div>
                        <!-- Diagnosis Lookup Section -->
                        <div class="form-group form-inline">
                            <label for="diagnosisCode">Diagnosis Code</label><input type="text" id="diagnosisCode" name="diagnosisCode" value="D123"><button type="button" class="btn-lookup" onclick="openDiagnosisLookup()">Lookup</button>
                        </div>
                        <div class="form-group form-inline">
                            <label for="diagnosisDescription">Diagnosis Description</label><input type="text" id="diagnosisDescription" name="diagnosisDescription" readonly>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <div class="footer">
        <p>&copy; 2025 ABC HealthCare. All rights reserved.</p>
    </div>   
    
</body>
</html>
