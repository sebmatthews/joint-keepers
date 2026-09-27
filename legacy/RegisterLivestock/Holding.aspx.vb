Imports System.Data
Imports System.Data.SQLite
Imports System.Configuration
Imports System.Collections.Generic
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
        BindKeeperList(ddlPrimaryKeeper, dt)
        BindKeeperList(ddlAdditionalKeeper1, dt)
        BindKeeperList(ddlAdditionalKeeper2, dt)
        BindKeeperList(ddlAdditionalKeeper3, dt)
    End Sub

    Private Sub BindKeeperList(ByVal list As DropDownList, ByVal dt As DataTable)
        list.DataSource = dt
        list.DataTextField = "Name"
        list.DataValueField = "KeeperId"
        list.DataBind()
        list.Items.Insert(0, New ListItem("-- Select --", ""))
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

        If ddlPrimaryKeeper.SelectedValue = "" Then
            lblMessage.Text = "Select a keeper"
            Exit Sub
        End If

        Dim keeperIds As New List(Of String)()
        keeperIds.Add(ddlPrimaryKeeper.SelectedValue)
        If Not AddKeeper(keeperIds, ddlAdditionalKeeper1.SelectedValue) OrElse _
           Not AddKeeper(keeperIds, ddlAdditionalKeeper2.SelectedValue) OrElse _
           Not AddKeeper(keeperIds, ddlAdditionalKeeper3.SelectedValue) Then
            lblMessage.Text = "Select each keeper only once"
            Exit Sub
        End If

        Dim conn As New SQLiteConnection(ConfigurationManager.ConnectionStrings("Livestock").ConnectionString)
        conn.Open()
        Dim check As New SQLiteCommand("SELECT COUNT(*) FROM Animal WHERE TagNumber = '" & tag & "'", conn)
        If CInt(check.ExecuteScalar()) > 0 Then
            conn.Close()
            lblMessage.Text = "An animal with this tag number is already registered"
            Exit Sub
        End If

        Dim transaction As SQLiteTransaction = conn.BeginTransaction()
        Dim sql As String = "INSERT INTO Animal (TagNumber, Species, DateOfBirth, HoldingId) VALUES ('" & _
            tag & "', '" & ddlSpecies.SelectedValue & "', '" & dob.ToString("yyyy-MM-dd") & "', " & holdingId & ")"
        Dim cmd As New SQLiteCommand(sql, conn)
        cmd.Transaction = transaction
        Try
            cmd.ExecuteNonQuery()
            Dim idCmd As New SQLiteCommand("SELECT last_insert_rowid()", conn)
            idCmd.Transaction = transaction
            Dim animalId As String = idCmd.ExecuteScalar().ToString()
            For i As Integer = 0 To keeperIds.Count - 1
                Dim keeperSql As String = "INSERT INTO AnimalKeeper (AnimalId, KeeperId, IsPrimary, DateAdded) VALUES (" & _
                    animalId & ", " & keeperIds(i) & ", " & If(i = 0, "1", "0") & ", '" & DateTime.Today.ToString("yyyy-MM-dd") & "')"
                Dim keeperCmd As New SQLiteCommand(keeperSql, conn)
                keeperCmd.Transaction = transaction
                keeperCmd.ExecuteNonQuery()
            Next
            transaction.Commit()
        Catch
            transaction.Rollback()
            conn.Close()
            Throw
        End Try
        conn.Close()

        lblMessage.CssClass = "message success"
        lblMessage.Text = "Animal " & tag & " registered"
        txtTag.Text = ""
        txtDob.Text = ""
        ddlSpecies.SelectedIndex = 0
        ddlPrimaryKeeper.SelectedIndex = 0
        ddlAdditionalKeeper1.SelectedIndex = 0
        ddlAdditionalKeeper2.SelectedIndex = 0
        ddlAdditionalKeeper3.SelectedIndex = 0
        LoadAnimals()
    End Sub

    Private Function AddKeeper(ByVal keeperIds As List(Of String), ByVal keeperId As String) As Boolean
        If keeperId = "" Then
            Return True
        End If
        If keeperIds.Contains(keeperId) Then
            Return False
        End If
        keeperIds.Add(keeperId)
        Return True
    End Function

End Class
