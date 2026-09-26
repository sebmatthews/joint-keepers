<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Default.aspx.vb" Inherits="HoldingsPage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Register livestock - Holdings</title>
    <link href="Site.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div id="header">UK Government Demo Service</div>
    <div id="content">
        <h1>Register livestock</h1>
        <h2>Holdings</h2>
        <p>
            Search by name:
            <asp:TextBox ID="txtSearch" runat="server" />
            <asp:Button ID="btnSearch" runat="server" Text="Search" />
        </p>
        <asp:GridView ID="gvHoldings" runat="server" AutoGenerateColumns="False" CssClass="grid" GridLines="Both" EmptyDataText="No holdings found.">
            <Columns>
                <asp:BoundField DataField="HoldingNumber" HeaderText="Holding number" />
                <asp:BoundField DataField="Name" HeaderText="Name" />
                <asp:BoundField DataField="Address" HeaderText="Address" />
                <asp:BoundField DataField="AnimalCount" HeaderText="Animals" />
            </Columns>
        </asp:GridView>
    </div>
    <div id="footer">Demo service. Not a real government service.</div>
    </form>
</body>
</html>
