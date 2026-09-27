Imports System.Data
Imports System.Data.SQLite
Imports System.Configuration
Imports System.Globalization

Partial Class AnimalPage
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim animalId As String = Request.QueryString("id")

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

        conn.Open()
        Dim keeperDa As New SQLiteDataAdapter("SELECT k.Name, CASE WHEN ak.IsPrimary = 1 THEN 'Primary' ELSE '' END AS KeeperStatus " & _
            "FROM AnimalKeeper ak INNER JOIN Keeper k ON k.KeeperId = ak.KeeperId " & _
            "WHERE ak.AnimalId = " & animalId & " ORDER BY ak.IsPrimary DESC, k.Name", conn)
        Dim keeperDt As New DataTable()
        keeperDa.Fill(keeperDt)
        conn.Close()
        gvKeepers.DataSource = keeperDt
        gvKeepers.DataBind()

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

End Class
