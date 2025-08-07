<%@ Language=VBScript %>
<%
    ' Check if user is logged in
    If Session("username") = "" Then
        Response.Redirect "default.asp"
    End If
    
    Dim mode, requestId, message
    mode = Request.Form("mode")
    requestId = Request.Form("requestId")
    
    ' Handle form submission
    If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
        ' Load shared DB function
        %> <!--#include file="common.asp" --> <%
        Dim params, field, errors, result, status, msg
        Set params = Server.CreateObject("Scripting.Dictionary")
        errors = ""

        ' Collect all relevant form fields
        For Each field In Request.Form
            params.Add field, Request.Form(field)
        Next

        ' Debug: Output all parameters before calling SP
        'Response.Write "<div style='background:#fffbe6;color:#333;padding:8px;border:1px solid #ffe58f;margin-bottom:8px;'>"
        'Response.Write "<strong>Debug: Parameters sent to SP:</strong><br>"
        'For Each field In params.Keys
         ''   Response.Write field & " = '" & params(field) & "'<br>"
        'Next
        'Response.Write "</div>"


        ' Basic required field validation (add more as needed)
        If params.Exists("patientId") And params("patientId") = "" Then errors = errors & "Patient ID is required.<br>"
        If params.Exists("physicianId") And params("physicianId") = "" Then errors = errors & "Physician ID is required.<br>"
        If params.Exists("siteId") And params("siteId") = "" Then errors = errors & "Site ID is required.<br>"
        If params.Exists("diagnosisCode") And params("diagnosisCode") = "" Then errors = errors & "Diagnosis Code is required.<br>"
        
        
        If errors = "" Then
            ' Call the upsert function
            result = UpsertPriorAuthorizationData(params)
            Response.Write result
            
            If result = "SUCCESS" Then
                ' Use returned EpisodeId if available
                If params.Exists("requestId") And params("requestId") <> "" Then
                    requestId = params("requestId")
                ElseIf params.Exists("EpisodeId") And params("EpisodeId") <> "" Then
                    requestId = params("EpisodeId")
                End If
                message = msg
                Response.Write "Case Created Successfully"
                'Response.Redirect "edit_view.asp?id=" & requestId & "&message=" & Server.URLEncode(message)
            Else
                ' Show error message
                Response.Write "<div style='color:red;text-align:center;font-weight:bold;'>" & msg & "</div>"
            End If
        Else
            ' Return to form with errors
            Session("formErrors") = errors
            Session("formData") = Request.Form
            If mode = "add" Then
                Response.Redirect "add_new.asp?error=1"
            Else
                Response.Redirect "edit_view.asp?id=" & requestId & "&error=1"
            End If
        End If
    Else
        Response.Redirect "home.asp"
    End If
%>
