$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {


$Core = Split-Path $PSScriptRoot -Parent
Push-Location -Path $Core

Set-Location (Join-Path "bin" "smo")
# - Loading necessary SMO Assemblies:
$Assem = (
  "Microsoft.SqlServer.Management.Sdk.Sfc",
  "Microsoft.SqlServer.Smo",
  "Microsoft.SqlServer.ConnectionInfo",
  "Microsoft.SqlServer.SqlEnum"
  );
Add-Type -AssemblyName $Assem

# # - Prepare variables for connection strings to SQL Server using SQL Authentication:
# $SQLServerInstanceName = 'Sql01,1451';
# $SQLUserName = 'sauser';
# $sqlPwd = '$MyPwd99!';

# ## - Prepare connection to SQL Server:
# $SQLSrvConn = new-object Microsoft.SqlServer.Management.Common.SqlConnectionInfo($SQLServerInstanceName, $SQLUserName, $SqlPwd);
# $SQLSrvObj = new-object Microsoft.SqlServer.Management.Smo.Server($SQLSrvConn);

# ## - SMO sample 1
# ## -&gt; Get SQL Server Info:
# $SQLSrvObj.Information `
# | Select-Object parent, platform, product, productlevel, `
# OSVersion, Edition, version, HostPlatform, HostDistribution `
# | Format-List;

# ## - SMO sample 2
# ## -&gt; To execute T-SQL Query:

# # - Prepare query string variable:
# $SqlQuery = "SP_WHO2";

# # - Execute T-SQL Query:
# [array]$result = $SQLSrvObj.Databases['master'].ExecuteWithResults($SqlQuery);

# # - Display T-SQL Query results:
# $result.tables.Rows | Select-object -first 10 $_ | Format-Table -AutoSize;

Pop-Location