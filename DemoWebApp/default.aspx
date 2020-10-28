<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="default.aspx.cs" Inherits="DemoWebApp._default" %>
<%@ Import Namespace="DemoWebApp.Properties" %>
<%@ Import Namespace="Microsoft.VisualStudio.Web.PageInspector.Runtime" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Settings Demo</title>
</head>
<body>
    <form id="form1" runat="server">
        <h1>Settings Demo:</h1>
        <div>
            <p>My Setting is: <b><%= Settings.Default.MySetting %></b></p>
	        <p>My Secret is: <b><%= Settings.Default.MySecret %></b></p>
        </div>
    </form>
</body>
</html>
