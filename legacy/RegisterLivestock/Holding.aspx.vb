Imports System.Collections.Generic
Imports System.Data
Imports System.Data.SQLite
Imports System.Configuration
Imports System.Globalization
Imports System.Text.RegularExpressions

Partial Class HoldingPage
    Inherits System.Web.UI.Page

    Dim holdingId As String

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        holdingId = Request.QueryString("id")
        If Not IsPostBack Then
            LoadHolding()
            LoadKeepers()
        End If
        LoadAnimals()
    End Sub

    Private Sub LoadHolding()
        Dim conn As New SQLiteConnection(ConfigurationManager.ConnectionStrings("Livestock").ConnectionString)
        conn.Open()
        Dim cmd As New SQLiteCommand("SELECT HoldingNumber, Name, Address FROM Holding WHERE HoldingId = " & holdingId, conn)
        Dim rdr As SQLiteDataReader = cmd.ExecuteReader()
        If rdr.Read() Then
            lblHoldingNumber.Text = rdr("HoldingNumber").ToString()
            lblHoldingName.Text = rdr("Name").ToString()
            lblAddress.Text = rdr("Address").ToString()
        End If
        rdr.Close()
        conn.Close()
    End Sub

    Private Sub LoadKeepers()
        Dim conn As New SQLiteConnection(ConfigurationManager.ConnectionStrings("Livestock").ConnectionString)
        conn.Open()
        Dim da As New SQLiteDataAdapter("SELECT KeeperId, Name FROM Keeper ORDER BY Name", conn)
        Dim dt As New DataTable()
        da.Fill(dt)
        conn.Close()
        For Each ddl As DropDownList In New DropDownList() {ddlKeeper, ddlKeeper2, ddlKeeper3, ddlKeeper4}
            ddl.DataSource = dt
            ddl.DataTextField = "Name"
            ddl.DataValueField = "KeeperId"
            ddl.DataBind()
            ddl.Items.Insert(0, New ListItem("-- Select --", ""))
        Next
    End Sub

    Private Sub LoadAnimals()
        Dim conn As New SQLiteConnection(ConfigurationManager.ConnectionStrings("Livestock").ConnectionString)
        conn.Open()
        Dim sql As String = "SELECT a.AnimalId, a.TagNumber, a.Species, a.DateOfBirth, k.Name AS KeeperName " & _
            "FROM Animal a INNER JOIN AnimalKeeper ak ON ak.AnimalId = a.AnimalId AND ak.IsPrimary = 1 " & _
            "INNER JOIN Keeper k ON k.KeeperId = ak.KeeperId " & _
            "WHERE a.HoldingId = " & holdingId & " ORDER BY a.TagNumber"
        Dim da As New SQLiteDataAdapter(sql, conn)
        Dim dt As New DataTable()
        da.Fill(dt)
        conn.Close()
        ' Show dates the British way
        For Each row As DataRow In dt.Rows
            row("DateOfBirth") = DateTime.ParseExact(row("DateOfBirth").ToString(), "yyyy-MM-dd", CultureInfo.InvariantCulture).ToString("dd/MM/yyyy")
        Next
        gvAnimals.DataSource = dt
        gvAnimals.DataBind()
    End Sub

    Protected Sub btnRegister_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnRegister.Click
        lblMessage.CssClass = "message error"

        ' Tag numbers are LV followed by 8 digits
        Dim tag As String = txtTag.Text.Trim()
        If Not Regex.IsMatch(tag, "^LV\d{8}$") Then
            lblMessage.Text = "Tag number must be LV followed by 8 digits"
            Exit Sub
        End If

        If ddlSpecies.SelectedValue = "" Then
            lblMessage.Text = "Select a species"
            Exit Sub
        End If

        Dim dob As DateTime
        If Not DateTime.TryParseExact(txtDob.Text.Trim(), "dd/MM/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, dob) Then
            lblMessage.Text = "Enter the date of birth as DD/MM/YYYY"
            Exit Sub
        End If
        If dob > DateTime.Today Then
            lblMessage.Text = "Date of birth cannot be in the future"
            Exit Sub
        End If

        If ddlKeeper.SelectedValue = "" Then
            lblMessage.Text = "Select a keeper"
            Exit Sub
        End If

        ' Joint Keepers Regulations 2026: the same person may be a keeper of an animal only once
        Dim keeperIds As New List(Of String)
        For Each ddl As DropDownList In New DropDownList() {ddlKeeper, ddlKeeper2, ddlKeeper3, ddlKeeper4}
            If ddl.SelectedValue <> "" Then
                If keeperIds.Contains(ddl.SelectedValue) Then
                    lblMessage.Text = "Select each keeper only once"
                    Exit Sub
                End If
                keeperIds.Add(ddl.SelectedValue)
            End If
        Next

        Dim conn As New SQLiteConnection(ConfigurationManager.ConnectionStrings("Livestock").ConnectionString)
        conn.Open()
        Dim check As New SQLiteCommand("SELECT COUNT(*) FROM Animal WHERE TagNumber = '" & tag & "'", conn)
        If CInt(check.ExecuteScalar()) > 0 Then
            conn.Close()
            lblMessage.Text = "An animal with this tag number is already registered"
            Exit Sub
        End If

        Dim sql As String = "INSERT INTO Animal (TagNumber, Species, DateOfBirth, HoldingId) VALUES ('" & _
            tag & "', '" & ddlSpecies.SelectedValue & "', '" & dob.ToString("yyyy-MM-dd") & "', " & holdingId & ")"
        Dim cmd As New SQLiteCommand(sql, conn)
        cmd.ExecuteNonQuery()
        Dim animalId As String = New SQLiteCommand("SELECT last_insert_rowid()", conn).ExecuteScalar().ToString()
        ' The first keeper chosen is the primary keeper
        For i As Integer = 0 To keeperIds.Count - 1
            Dim keeperSql As String = "INSERT INTO AnimalKeeper (AnimalId, KeeperId, IsPrimary, DateAdded) VALUES (" & _
                animalId & ", " & keeperIds(i) & ", " & IIf(i = 0, "1", "0") & ", '" & DateTime.Today.ToString("yyyy-MM-dd") & "')"
            Dim keeperCmd As New SQLiteCommand(keeperSql, conn)
            keeperCmd.ExecuteNonQuery()
        Next
        conn.Close()

        lblMessage.CssClass = "message success"
        lblMessage.Text = "Animal " & tag & " registered"
        txtTag.Text = ""
        txtDob.Text = ""
        ddlSpecies.SelectedIndex = 0
        ddlKeeper.SelectedIndex = 0
        ddlKeeper2.SelectedIndex = 0
        ddlKeeper3.SelectedIndex = 0
        ddlKeeper4.SelectedIndex = 0
        LoadAnimals()
    End Sub

End Class
