Imports System.Data
Imports System.Data.SQLite
Imports System.Configuration
Imports System.Globalization

Partial Class AnimalPage
    Inherits System.Web.UI.Page

    Dim animalId As String

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        animalId = Request.QueryString("id")
        If Not IsPostBack Then
            LoadKeeperList()
        End If

        Dim conn As New SQLiteConnection(ConfigurationManager.ConnectionStrings("Livestock").ConnectionString)
        conn.Open()
        Dim sql As String = "SELECT a.TagNumber, a.Species, a.DateOfBirth, a.HoldingId, h.Name AS HoldingName " & _
            "FROM Animal a INNER JOIN Holding h ON h.HoldingId = a.HoldingId " & _
            "WHERE a.AnimalId = " & animalId
        Dim cmd As New SQLiteCommand(sql, conn)
        Dim rdr As SQLiteDataReader = cmd.ExecuteReader()
        If rdr.Read() Then
            lblTag.Text = rdr("TagNumber").ToString()
            lblTagNumber.Text = rdr("TagNumber").ToString()
            lblSpecies.Text = rdr("Species").ToString()
            lblDob.Text = DateTime.ParseExact(rdr("DateOfBirth").ToString(), "yyyy-MM-dd", CultureInfo.InvariantCulture).ToString("dd/MM/yyyy")
            lnkHolding.Text = rdr("HoldingName").ToString()
            lnkHolding.NavigateUrl = "Holding.aspx?id=" & rdr("HoldingId").ToString()
            lnkMove.NavigateUrl = "Movement.aspx?tag=" & rdr("TagNumber").ToString()
        End If
        rdr.Close()
        conn.Close()

        LoadKeepers()

        Try
            conn.Open()
            Dim da As New SQLiteDataAdapter("SELECT m.MovementDate, f.Name AS FromName, t.Name AS ToName FROM Movement m " & _
                "INNER JOIN Holding f ON f.HoldingId = m.FromHoldingId INNER JOIN Holding t ON t.HoldingId = m.ToHoldingId " & _
                "WHERE m.AnimalId = " & animalId & " ORDER BY m.MovementDate", conn)
            Dim dt As New DataTable()
            da.Fill(dt)
            conn.Close()
            For Each row As DataRow In dt.Rows
                row("MovementDate") = DateTime.ParseExact(row("MovementDate").ToString(), "yyyy-MM-dd", CultureInfo.InvariantCulture).ToString("dd/MM/yyyy")
            Next
            gvMovements.DataSource = dt
            gvMovements.DataBind()
        Catch ex As Exception
        End Try
    End Sub

    Private Sub LoadKeeperList()
        Dim conn As New SQLiteConnection(ConfigurationManager.ConnectionStrings("Livestock").ConnectionString)
        conn.Open()
        Dim da As New SQLiteDataAdapter("SELECT KeeperId, Name FROM Keeper ORDER BY Name", conn)
        Dim dt As New DataTable()
        da.Fill(dt)
        conn.Close()
        ddlAddKeeper.DataSource = dt
        ddlAddKeeper.DataTextField = "Name"
        ddlAddKeeper.DataValueField = "KeeperId"
        ddlAddKeeper.DataBind()
        ddlAddKeeper.Items.Insert(0, New ListItem("-- Select --", ""))
    End Sub

    ' The primary keeper first, then the others by name
    Private Sub LoadKeepers()
        Dim conn As New SQLiteConnection(ConfigurationManager.ConnectionStrings("Livestock").ConnectionString)
        conn.Open()
        Dim da As New SQLiteDataAdapter("SELECT k.Name AS KeeperName, " & _
            "CASE WHEN ak.IsPrimary = 1 THEN 'Primary' ELSE 'Additional' END AS Role, ak.DateAdded " & _
            "FROM AnimalKeeper ak INNER JOIN Keeper k ON k.KeeperId = ak.KeeperId " & _
            "WHERE ak.AnimalId = " & animalId & " ORDER BY ak.IsPrimary DESC, k.Name", conn)
        Dim dt As New DataTable()
        da.Fill(dt)
        conn.Close()
        For Each row As DataRow In dt.Rows
            row("DateAdded") = DateTime.ParseExact(row("DateAdded").ToString(), "yyyy-MM-dd", CultureInfo.InvariantCulture).ToString("dd/MM/yyyy")
        Next
        gvKeepers.DataSource = dt
        gvKeepers.DataBind()
    End Sub

    Protected Sub btnAddKeeper_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAddKeeper.Click
        lblMessage.CssClass = "message error"

        If ddlAddKeeper.SelectedValue = "" Then
            lblMessage.Text = "Select a keeper to add"
            Exit Sub
        End If

        Dim conn As New SQLiteConnection(ConfigurationManager.ConnectionStrings("Livestock").ConnectionString)
        conn.Open()
        Dim check As New SQLiteCommand("SELECT COUNT(*) FROM AnimalKeeper WHERE AnimalId = " & animalId & " AND KeeperId = " & ddlAddKeeper.SelectedValue, conn)
        If CInt(check.ExecuteScalar()) > 0 Then
            conn.Close()
            lblMessage.Text = "This keeper is already recorded for this animal"
            Exit Sub
        End If

        Dim count As New SQLiteCommand("SELECT COUNT(*) FROM AnimalKeeper WHERE AnimalId = " & animalId, conn)
        If CInt(count.ExecuteScalar()) >= 4 Then
            conn.Close()
            lblMessage.Text = "An animal cannot have more than four keepers"
            Exit Sub
        End If

        Dim insert As New SQLiteCommand("INSERT INTO AnimalKeeper (AnimalId, KeeperId, IsPrimary, DateAdded) VALUES (" & _
            animalId & ", " & ddlAddKeeper.SelectedValue & ", 0, '" & DateTime.Today.ToString("yyyy-MM-dd") & "')", conn)
        insert.ExecuteNonQuery()
        conn.Close()

        lblMessage.CssClass = "message success"
        lblMessage.Text = "Keeper " & ddlAddKeeper.SelectedItem.Text & " added"
        ddlAddKeeper.SelectedIndex = 0
        LoadKeepers()
    End Sub

End Class
