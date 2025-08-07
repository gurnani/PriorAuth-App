<%
' common.asp - shared utilities for Prior Auth App

' Connection string for Azure App Service (OLEDB)
Const CONN_STRING = "Provider=SQLOLEDB;Data Source=PA_DB.database.windows.net;Initial Catalog=PA_Data;User ID=ioadmin;Password=io_12345;"



' Calls sp_UpsertPriorAuthorizationData with all required parameters
Function UpsertPriorAuthorizationData(params)    
    
    Dim conn, cmd, i, paramNames, paramValues, result, rs
    Set conn = Server.CreateObject("ADODB.Connection")
    Set cmd = Server.CreateObject("ADODB.Command")
   
    On Error Resume Next
    conn.Open CONN_STRING
    If Err.Number <> 0 Then        
        UpsertPriorAuthorizationData = Array("ERROR", "Database connection failed: " & Err.Description)
        Exit Function
    End If    
    On Error GoTo 0
    
    cmd.ActiveConnection = conn
    cmd.CommandType = 4 ' adCmdStoredProc
    cmd.CommandText = "sp_UpsertPriorAuthorizationData"

    ' Explicitly map form fields to SP parameters
    ' Use correct types for date fields: 135 (adDate)
    ' Send NULL for empty EpisodeId and EpisodeDate
    If params.Exists("episodeNo") And Trim(params("episodeNo")) <> "" Then
        cmd.Parameters.Append cmd.CreateParameter("@EpisodeId", 200, 1, 50, params("episodeNo"))
    Else
        cmd.Parameters.Append cmd.CreateParameter("@EpisodeId", 200, 1, 50, Null)
    End If   

    If params.Exists("episodeDate") And Trim(params("episodeDate")) <> "" Then
        cmd.Parameters.Append cmd.CreateParameter("@EpisodeDateStr", 200, 1, 50, params("episodeDate"))
    Else
        cmd.Parameters.Append cmd.CreateParameter("@EpisodeDateStr", 200, 1, 50, Null)
    End If
    
    cmd.Parameters.Append cmd.CreateParameter("@InsCarrier", 200, 1, 50, params("payor"))
    cmd.Parameters.Append cmd.CreateParameter("@CPTCode", 200, 1, 10, params("cptCode"))
    cmd.Parameters.Append cmd.CreateParameter("@CompanyID", 200, 1, 50, params("program"))

    If params.Exists("patientId") And Trim(params("patientId")) <> "" Then
        cmd.Parameters.Append cmd.CreateParameter("@PatientID", 200, 1, 50, params("patientId"))
    Else
        cmd.Parameters.Append cmd.CreateParameter("@PatientID", 200, 1, 50, Null)
    End If    
    cmd.Parameters.Append cmd.CreateParameter("@PatientName", 200, 1, 100, params("patientName"))
    cmd.Parameters.Append cmd.CreateParameter("@PatientGender", 200, 1, 10, params("patientSex"))
    cmd.Parameters.Append cmd.CreateParameter("@PatientAddressLine1", 200, 1, 200, params("patientAddr1"))
    cmd.Parameters.Append cmd.CreateParameter("@PatientAddressLine2", 200, 1, 200, Null)
    cmd.Parameters.Append cmd.CreateParameter("@PatientCity", 200, 1, 100, params("patientCity"))
    cmd.Parameters.Append cmd.CreateParameter("@PatientState", 200, 1, 100, params("patientState"))
    cmd.Parameters.Append cmd.CreateParameter("@PatientZipCode", 200, 1, 20, params("patientZip"))
    cmd.Parameters.Append cmd.CreateParameter("@PatientPhone", 200, 1, 20, params("patientPhone"))
    cmd.Parameters.Append cmd.CreateParameter("@PatientMemberCode", 200, 1, 50, params("patientMemberCode"))

    If params.Exists("patientDob") And params("patientDob") <> "" Then       
       cmd.Parameters.Append cmd.CreateParameter("@PatientDOB", 135, 1, , CDate(Split(params("patientDob"), "T")(0)))
    Else
       cmd.Parameters.Append cmd.CreateParameter("@PatientDOB", 135, 1, , Null)
    End If
    cmd.Parameters.Append cmd.CreateParameter("@PatientGroupNumber", 200, 1, 50, params("groupNumber"))

    If params.Exists("physicianId") And Trim(params("physicianId")) <> "" Then
        cmd.Parameters.Append cmd.CreateParameter("@PhysicianID", 200, 1, 50, params("physicianId"))
    Else
        cmd.Parameters.Append cmd.CreateParameter("@PhysicianID", 200, 1, 50, Null)
    End If
    
    cmd.Parameters.Append cmd.CreateParameter("@PhysicianFirstName", 200, 1, 100, params("physicianName"))
    cmd.Parameters.Append cmd.CreateParameter("@PhysicianLastName", 200, 1, 100, Null)
    cmd.Parameters.Append cmd.CreateParameter("@PhysicianNPI", 200, 1, 100, Null)
    cmd.Parameters.Append cmd.CreateParameter("@PhysicianSpecialty1", 200, 1,100, Null)
    cmd.Parameters.Append cmd.CreateParameter("@PhysicianSpecialty2", 200, 1,100, Null)
    cmd.Parameters.Append cmd.CreateParameter("@PhysicianAddressLine1", 200, 1, 100, Null)
    cmd.Parameters.Append cmd.CreateParameter("@PhysicianAddressLine2", 200, 1,100, Null)
    cmd.Parameters.Append cmd.CreateParameter("@PhysicianCity", 200, 1,100, Null)
    cmd.Parameters.Append cmd.CreateParameter("@PhysicianState", 200, 1,100, Null)
    cmd.Parameters.Append cmd.CreateParameter("@PhysicianZipCode", 200, 1,100, Null)
    cmd.Parameters.Append cmd.CreateParameter("@PhysicianPhone", 200, 1, 100, Null)
    cmd.Parameters.Append cmd.CreateParameter("@PhysicianFax", 200, 1,100, Null)
    cmd.Parameters.Append cmd.CreateParameter("@PhysicianEmailAddress", 200, 1,100, Null)
    cmd.Parameters.Append cmd.CreateParameter("@PhysicianCellPhone", 200, 1,100, Null)

    If params.Exists("siteId") And Trim(params("siteId")) <> "" Then
        cmd.Parameters.Append cmd.CreateParameter("@SiteID", 200, 1, 15, params("siteId"))
    Else
        cmd.Parameters.Append cmd.CreateParameter("@SiteID", 200, 1, 15, Null)
    End If    
    If params.Exists("siteName") And Trim(params("siteName")) <> "" Then
       cmd.Parameters.Append cmd.CreateParameter("@SiteName", 200, 1, 100, params("siteName"))
    Else
       cmd.Parameters.Append cmd.CreateParameter("@SiteName", 200, 1, 100, Null)
    End If

    ' Add more mappings as needed for your form/SP

    On Error Resume Next
    Set rs = Nothing
    Err.Clear
    Set rs = cmd.Execute
    <!-- Response.Write "<script type='text/javascript'>alert('After cmd.Execute');</script>" -->
    If Err.Number <> 0 Then
        Response.Write "<script type=""text/javascript"">alert('Error after cmd.Execute: " & Replace(Err.Description, "'", "\'") & "');</script>"
        Dim errorDetails
        errorDetails = "Stored procedure execution failed: " & Err.Description & "<br>"
        errorDetails = errorDetails & "Parameters sent:<br>"
        For i = 0 To cmd.Parameters.Count - 1
            errorDetails = errorDetails & cmd.Parameters(i).Name & " = '" & cmd.Parameters(i).Value & "'<br>"
        Next
           Dim jsErrorDetails
        jsErrorDetails = Replace(errorDetails, "'", "\'")
        jsErrorDetails = Replace(jsErrorDetails, "\r\n", " ")
        jsErrorDetails = Replace(jsErrorDetails, "\n", " ")
        jsErrorDetails = Replace(jsErrorDetails, "\r", " ")
        Response.Write "<script type=""text/javascript"">alert('" & jsErrorDetails & "');</script>"
        UpsertPriorAuthorizationData = Array("ERROR", errorDetails)
        conn.Close
        Exit Function
    End If
    On Error GoTo 0
    
    If Not rs.EOF Then        
        'result = Array(rs("Status"), rs("Message"))
        result = rs("Status") & "|" & rs("EpisodeId")
    Else
        'result = Array("ERROR", "No result returned from stored procedure.")
        result = "ERROR: No result returned from stored procedure."
    End If
    
    rs.Close
    conn.Close
    UpsertPriorAuthorizationData = result
End Function
%>
