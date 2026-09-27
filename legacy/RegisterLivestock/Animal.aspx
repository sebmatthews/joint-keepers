<%@ Page Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Animal.aspx.vb" Inherits="AnimalPage" Title="Register livestock - Animal" %>

<asp:Content ID="Main" ContentPlaceHolderID="MainContent" runat="server">
    <h2>Animal <asp:Label ID="lblTag" runat="server" /></h2>
    <table class="grid" id="details">
        <tr><th>Tag number</th><td><asp:Label ID="lblTagNumber" runat="server" /></td></tr>
        <tr><th>Species</th><td><asp:Label ID="lblSpecies" runat="server" /></td></tr>
        <tr><th>Date of birth</th><td><asp:Label ID="lblDob" runat="server" /></td></tr>
        <tr><th>Current holding</th><td><asp:HyperLink ID="lnkHolding" runat="server" /></td></tr>
    </table>

    <h3>Keepers</h3>
    <asp:GridView ID="gvKeepers" runat="server" AutoGenerateColumns="False" CssClass="grid" GridLines="Both">
        <Columns>
            <asp:BoundField DataField="KeeperName" HeaderText="Keeper" />
            <asp:BoundField DataField="Role" HeaderText="Role" />
            <asp:BoundField DataField="DateAdded" HeaderText="Date added" />
        </Columns>
    </asp:GridView>

    <h3>Add a keeper</h3>
    <asp:Label ID="lblMessage" runat="server" CssClass="message" />
    <table class="form">
        <tr><td>Keeper</td><td><asp:DropDownList ID="ddlAddKeeper" runat="server" /></td></tr>
        <tr><td></td><td><asp:Button ID="btnAddKeeper" runat="server" Text="Add keeper" /></td></tr>
    </table>

    <h3>Movements</h3>
    <asp:GridView ID="gvMovements" runat="server" AutoGenerateColumns="False" CssClass="grid" GridLines="Both" EmptyDataText="No movements recorded.">
        <Columns>
            <asp:BoundField DataField="MovementDate" HeaderText="Date" />
            <asp:BoundField DataField="FromName" HeaderText="From" />
            <asp:BoundField DataField="ToName" HeaderText="To" />
        </Columns>
    </asp:GridView>
    <p><asp:HyperLink ID="lnkMove" runat="server" Text="Record a movement for this animal" /></p>
</asp:Content>
