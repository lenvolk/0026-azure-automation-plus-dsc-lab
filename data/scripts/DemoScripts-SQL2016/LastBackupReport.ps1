<#
    Core script courtesy of Aaron Nelson (http://sqlvariant.com/)
#>
<#Param(
[Parameter(Mandatory=$true,position=0)][String] $OutputFile,
[Parameter(ParameterSetName="SingleServer",position=1)][String] $SingleServer,
[Parameter(ParameterSetName="CMS",position=1)][String] $CMS,
[Parameter(ParameterSetName="ServerFile",position=1)][String] $ServerFile
)#>

Function Write-Excel($ServerName, $SaPassword, $IPAddress, $intRow, $Sheet)
{
     $Sheet.Cells.Item($intRow,1) = "INSTANCE NAME:"
     $Sheet.Cells.Item($intRow,2) = $ServerName
     $Sheet.Cells.Item($intRow,1).Font.Bold = $True
     $Sheet.Cells.Item($intRow,2).Font.Bold = $True
     $intRow++
     #Name, CreateDate, LastBackupDate, RecoveryModel, LastDifferentialBackupDate, LastLogBackupDate
     $Sheet.Cells.Item($intRow,1) = "DB NAME"
     $Sheet.Cells.Item($intRow,2) = "CREATE DATE"
     $Sheet.Cells.Item($intRow,3) = "RECOVERY MODEL"
     $Sheet.Cells.Item($intRow,4) = "LAST FULL BACKUP"
     $Sheet.Cells.Item($intRow,5) = "LAST DIFF BACKUP"
     $Sheet.Cells.Item($intRow,6) = "LAST LOG BACKUP"
     $Sheet.Cells.Item($intRow,7) = "SIZE (MB)"
<#     for ($col = 1; $col –le 7; $col++)
     {    $Sheet.Cells.Item($intRow,$col).Font.Bold = $True
          $Sheet.Cells.Item($intRow,$col).Interior.ColorIndex = 48
          $Sheet.Cells.Item($intRow,$col).Font.ColorIndex = 34
     }#>
    $intRow++
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
    $SrvConn = new-object Microsoft.SqlServer.Management.Common.ServerConnection
    $SrvConn.ServerInstance=$ServerName
    $SrvConn.LoginSecure = $false
    $SrvConn.Login = "sa"
    $SrvConn.Password = $SaPassword
    $SrvConn.ConnectTimeout = 1
    $srv = new-object Microsoft.SqlServer.Management.SMO.Server($SrvConn)
    $dbs = $srv.Databases
    try
    {
        ForEach ($db in $dbs) 
        {
          
              $Sheet.Cells.Item($intRow, 1) = $db.Name
              $Sheet.Cells.Item($intRow, 2) = $db.CreateDate
              $Sheet.Cells.Item($intRow, 3) = $db.RecoveryModel
              If ( $db.LastBackupDate -eq '1/1/0001 12:00:00 AM')
                {$Sheet.Cells.Item($intRow, 4) = "-"}
              else
                {$Sheet.Cells.Item($intRow, 4) = $db.LastBackupDate} 
              If (($db.LastBackupDate -gt (get-date).AddDays(-7)) -AND ( $db.LastBackupDate -ne '1/1/0001 12:00:00 AM')) 
                {$fgColor = 0 } else {$fgColor = 3 }
              $Sheet.Cells.item($intRow, 4).Interior.ColorIndex = $fgColor
		      
              If ( $db.LastDifferentialBackupDate -eq '1/1/0001 12:00:00 AM')
                {$Sheet.Cells.Item($intRow, 5) = "-"}
              else
                {$Sheet.Cells.Item($intRow, 5) = $db.LastDifferentialBackupDate} 
            		  
              If ( $db.LastLogBackupDate -eq '1/1/0001 12:00:00 AM')
                {$Sheet.Cells.Item($intRow, 6) = "-"}
              else
                {$Sheet.Cells.Item($intRow, 6) = $db.LastLogBackupDate} 

              If (($db.LastLogBackupDate -gt (get-date).AddDays(-1)) -and ($db.RecoveryModel = 1) -AND ( $db.LastBackupDate -ne '1/1/0001 12:00:00 AM')) { $fgColor = 0 } else { $fgColor = 3 }
              $Sheet.Cells.Item($intRow, 6) = $db.LastLogBackupDate 
              $Sheet.Cells.item($intRow, 6).Interior.ColorIndex = $fgColor
		  
              $Sheet.Cells.Item($intRow, 7) = $db.Size 
              $intRow ++
        }
     }
     catch
        {
            $Sheet.Cells.item($intRow -2, 1).Interior.ColorIndex = 3
            $Sheet.Cells.item($intRow -2, 2).Interior.ColorIndex = 3
            $Sheet.Cells.Item($intRow-2,3) = "Could not Connect to Server"
            $Sheet.Cells.item($intRow -2, 3).Interior.ColorIndex = 3
            Return $intRow
        }

    Return $intRow
}

Import-Module SQLPS -DisableNameChecking
import-module 'C:\Users\pansaty\Documents\WindowsPowerShell\Modules\SharedModules\WriteData.ps1'
$ServerName = "sqladmin11clun1"      #"PankajWin7"
$InstanceName = "Default"  #"Default"
$DatabaseName = "SQLDBA"
$intRow = 1
$ConnectionString = "SQLSERVER:\SQL\"+$ServerName+"\"+$InstanceName+"\Databases\"+$DatabaseName
$SQLQuery = "SELECT ServerName, sapassword, IPAddress  FROM [SQLDBA].[dbo].[dba_sqlservers]"
$ResultSet = Invoke-Sqlcmd -ServerInstance $ServerName -Database $DatabaseName -Query $SQLQuery

$ResultSet | get-Member


$ExcelOutput = 'C:\scripts\LastBackupReport.xls'
if (Test-Path $ExcelOutput) { Remove-Item $ExcelOutput}
$Excel = New-Object -ComObject Excel.Application 
$Excel.visible = $TRUE
$Excel = $Excel.Workbooks.Add()
$Sheet = $Excel.Worksheets.Item(1) 


ForEach($Server in $ResultSet)
{
    $intRow = Write-Excel $Server.ServerName $Server.SaPassword $Server.IPAddress $intRow $Sheet
    $intRow ++
}
$Sheet.UsedRange.EntireColumn.AutoFit()
$Excel.Worksheets.Item(3).Delete()
$Excel.Worksheets.Item(2).Delete()
$Excel.Worksheets.Item(1).Name = "Recovery models"
$Excel.SaveAs($ExcelOutput)
#$Excel.Close()
