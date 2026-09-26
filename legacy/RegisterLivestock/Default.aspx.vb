Imports System.Data
Imports System.Data.SQLite
Imports System.Configuration

Partial Class HoldingsPage
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            BindHoldings("")
        End If
    End Sub

    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSearch.Click
        BindHoldings(txtSearch.Text)
    End Sub

    Private Sub BindHoldings(ByVal search As String)
        Dim sql As String = "SELECT h.HoldingId, h.HoldingNumber, h.Name, h.Address, " & _
            "(SELECT COUNT(*) FROM Animal a WHERE a.HoldingId = h.HoldingId) AS AnimalCount " & _
            "FROM Holding h"
        If search <> "" Then
            sql = sql & " WHERE h.Name LIKE '%" & search & "%'"
        End If
        sql = sql & " ORDER BY h.HoldingNumber"

        Dim conn As New SQLiteConnection(ConfigurationManager.ConnectionStrings("Livestock").ConnectionString)
        conn.Open()
        Dim da As New SQLiteDataAdapter(sql, conn)
        Dim dt As New DataTable()
        da.Fill(dt)
        conn.Close()

        gvHoldings.DataSource = dt
        gvHoldings.DataBind()
    End Sub

End Class
