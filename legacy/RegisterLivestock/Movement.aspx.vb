Imports System.Data
Imports System.Data.SQLite
Imports System.Configuration
Imports System.Globalization
Imports System.Text.RegularExpressions

Partial Class MovementPage
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            Dim conn As New SQLiteConnection(ConfigurationManager.ConnectionStrings("Livestock").ConnectionString)
            conn.Open()
            Dim da As New SQLiteDataAdapter("SELECT HoldingId, Name FROM Holding ORDER BY Name", conn)
            Dim dt As New DataTable()
            da.Fill(dt)
            conn.Close()

            ddlFrom.DataSource = dt
            ddlFrom.DataTextField = "Name"
            ddlFrom.DataValueField = "HoldingId"
            ddlFrom.DataBind()
            ddlFrom.Items.Insert(0, New ListItem("-- Select --", ""))

            ddlTo.DataSource = dt
            ddlTo.DataTextField = "Name"
            ddlTo.DataValueField = "HoldingId"
            ddlTo.DataBind()
            ddlTo.Items.Insert(0, New ListItem("-- Select --", ""))

            If Request.QueryString("tag") <> "" Then
                txtTag.Text = Request.QueryString("tag")
            End If
        End If
    End Sub

    Protected Sub btnRecord_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnRecord.Click
        lblMessage.CssClass = "message error"

        ' Check the tag number
        Dim tag As String = txtTag.Text.ToUpper()
        If Not Regex.IsMatch(tag, "^LV[0-9]{8}$") Then
            lblMessage.Text = "Enter a valid tag number"
            Exit Sub
        End If

        If ddlFrom.SelectedValue = "" Or ddlTo.SelectedValue = "" Then
            lblMessage.Text = "Select the holdings the animal is moving from and to"
            Exit Sub
        End If

        If ddlFrom.SelectedValue = ddlTo.SelectedValue Then
            lblMessage.Text = "An animal cannot be moved to the holding it is already on"
            Exit Sub
        End If

        Dim moveDate As DateTime
        If Not DateTime.TryParseExact(txtDate.Text.Trim(), "dd/MM/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, moveDate) Then
            lblMessage.Text = "Enter the movement date as DD/MM/YYYY"
            Exit Sub
        End If

        Dim conn As New SQLiteConnection(ConfigurationManager.ConnectionStrings("Livestock").ConnectionString)
        conn.Open()
        Dim cmd As New SQLiteCommand("SELECT AnimalId, HoldingId FROM Animal WHERE TagNumber = '" & tag & "'", conn)
        Dim rdr As SQLiteDataReader = cmd.ExecuteReader()
        If Not rdr.Read() Then
            rdr.Close()
            conn.Close()
            lblMessage.Text = "No animal found with that tag number"
            Exit Sub
        End If
        Dim animalId As String = rdr("AnimalId").ToString()
        Dim currentHolding As String = rdr("HoldingId").ToString()
        rdr.Close()

        If currentHolding <> ddlFrom.SelectedValue Then
            conn.Close()
            lblMessage.Text = "This animal is not on the holding you are moving it from"
            Exit Sub
        End If

        Dim insert As New SQLiteCommand("INSERT INTO Movement (AnimalId, FromHoldingId, ToHoldingId, MovementDate) VALUES (" & _
            animalId & ", " & ddlFrom.SelectedValue & ", " & ddlTo.SelectedValue & ", '" & moveDate.ToString("yyyy-MM-dd") & "')", conn)
        insert.ExecuteNonQuery()

        Try
            Dim update As New SQLiteCommand("UPDATE Animal SET HoldingId = " & ddlTo.SelectedValue & " WHERE AnimalId = " & animalId, conn)
            update.ExecuteNonQuery()
        Catch ex As Exception
        End Try
        conn.Close()

        lblMessage.CssClass = "message success"
        lblMessage.Text = "Movement recorded for " & tag
        txtTag.Text = ""
        txtDate.Text = ""
        ddlFrom.SelectedIndex = 0
        ddlTo.SelectedIndex = 0
    End Sub

End Class
