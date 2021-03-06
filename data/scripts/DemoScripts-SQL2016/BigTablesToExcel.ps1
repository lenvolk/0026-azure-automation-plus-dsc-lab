# Courtesy of Buck Woody
# http://blogs.msdn.com/b/buckwoody/archive/2009/11/09/create-an-excel-graph-of-your-big-tables-with-powershell.aspx
#
# Big Tables to Excel Chart
# Keep this next part on one line… This gets your objects to put in the chart
Import-Module SQLPS
$ServerName = "SQLADMIN11CluN1"      #"PankajWin7"
$InstanceName = "Default"  #"Default"
$DatabaseName = "AdventureWorks2012DW"           #"AdventureWorks2012

$ConnectionString = "SQLSERVER:\SQL\"+$ServerName+"\"+$InstanceName+"\Databases\"+$DatabaseName+"\Tables"

$BigTables= DIR $ConnectionString | sort-Object -Property RowCount -desc | select-Object -First 10
$excel = new-object -comobject excel.application
$excel.visible = $true
$chartType = "microsoft.office.interop.excel.xlChartType" -as [type]
$workbook = $excel.workbooks.add()
$workbook.WorkSheets.item(1).Name = "BigTables"
$sheet = $workbook.WorkSheets.Item("BigTables")
$x = 2
$sheet.cells.item(1,1) = "Schema Name"
$sheet.cells.item(1,2) = "Table Name"
$sheet.cells.item(1,3) = "RowCount"
Foreach($BigTable in $BigTables)
{
$sheet.cells.item($x,1) = $BigTable.Schema
$sheet.cells.item($x,2) = $BigTable.Name
$sheet.cells.item($x,3) = $BigTable.RowCount
$x++
} 
$range = $sheet.usedRange
$range.EntireColumn.AutoFit()
$workbook.charts.add()
