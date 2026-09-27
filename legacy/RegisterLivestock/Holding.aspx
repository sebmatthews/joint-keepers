<%@ Page Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Holding.aspx.vb" Inherits="HoldingPage" Title="Register livestock - Holding" %>

<asp:Content ID="Main" ContentPlaceHolderID="MainContent" runat="server">
    <h2><asp:Label ID="lblHoldingName" runat="server" /></h2>
    <p>Holding number: <asp:Label ID="lblHoldingNumber" runat="server" /><br />
       Address: <asp:Label ID="lblAddress" runat="server" /></p>

    <h3>Animal register</h3>
    <asp:GridView ID="gvAnimals" runat="server" AutoGenerateColumns="False" CssClass="grid" GridLines="Both" EmptyDataText="No animals on this holding.">
        <Columns>
            <asp:HyperLinkField DataTextField="TagNumber" HeaderText="Tag number" DataNavigateUrlFields="AnimalId" DataNavigateUrlFormatString="Animal.aspx?id={0}" />
            <asp:BoundField DataField="Species" HeaderText="Species" />
            <asp:BoundField DataField="DateOfBirth" HeaderText="Date of birth" />
            <asp:BoundField DataField="KeeperName" HeaderText="Keeper" />
        </Columns>
    </asp:GridView>

    <h3>Register an animal</h3>
    <asp:Label ID="lblMessage" runat="server" CssClass="message" />
    <table class="form">
        <tr><td>Tag number</td><td><asp:TextBox ID="txtTag" runat="server" /></td></tr>
        <tr><td>Species</td><td>
            <asp:DropDownList ID="ddlSpecies" runat="server">
                <asp:ListItem Value="">-- Select --</asp:ListItem>
                <asp:ListItem>Cattle</asp:ListItem>
                <asp:ListItem>Sheep</asp:ListItem>
                <asp:ListItem>Pig</asp:ListItem>
                <asp:ListItem>Goat</asp:ListItem>
            </asp:DropDownList></td></tr>
        <tr><td>Date of birth (DD/MM/YYYY)</td><td><asp:TextBox ID="txtDob" runat="server" /></td></tr>
        <tr><td>Keeper</td><td><asp:DropDownList ID="ddlKeeper" runat="server" /></td></tr>
        <tr><td></td><td><asp:Button ID="btnRegister" runat="server" Text="Register animal" /></td></tr>
    </table>
</asp:Content>
