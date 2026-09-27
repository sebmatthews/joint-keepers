<%@ Page Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Movement.aspx.vb" Inherits="MovementPage" Title="Register livestock - Record a movement" %>

<asp:Content ID="Main" ContentPlaceHolderID="MainContent" runat="server">
    <h2>Record a movement</h2>
    <asp:Label ID="lblMessage" runat="server" CssClass="message" />
    <table class="form">
        <tr><td>Tag number</td><td><asp:TextBox ID="txtTag" runat="server" /></td></tr>
        <tr><td>Moving from</td><td><asp:DropDownList ID="ddlFrom" runat="server" /></td></tr>
        <tr><td>Moving to</td><td><asp:DropDownList ID="ddlTo" runat="server" /></td></tr>
        <tr><td>Date of movement (DD/MM/YYYY)</td><td><asp:TextBox ID="txtDate" runat="server" /></td></tr>
        <tr><td></td><td><asp:Button ID="btnRecord" runat="server" Text="Record movement" /></td></tr>
    </table>
</asp:Content>
