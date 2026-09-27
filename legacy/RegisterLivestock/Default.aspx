<%@ Page Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Default.aspx.vb" Inherits="HoldingsPage" Title="Register livestock - Holdings" %>

<asp:Content ID="Main" ContentPlaceHolderID="MainContent" runat="server">
    <h2>Holdings</h2>
    <p>
        Search by name:
        <asp:TextBox ID="txtSearch" runat="server" />
        <asp:Button ID="btnSearch" runat="server" Text="Search" />
    </p>
    <asp:GridView ID="gvHoldings" runat="server" AutoGenerateColumns="False" CssClass="grid" GridLines="Both" EmptyDataText="No holdings found.">
        <Columns>
            <asp:BoundField DataField="HoldingNumber" HeaderText="Holding number" />
            <asp:HyperLinkField DataTextField="Name" HeaderText="Name" DataNavigateUrlFields="HoldingId" DataNavigateUrlFormatString="Holding.aspx?id={0}" />
            <asp:BoundField DataField="Address" HeaderText="Address" />
            <asp:BoundField DataField="AnimalCount" HeaderText="Animals" />
        </Columns>
    </asp:GridView>
</asp:Content>
