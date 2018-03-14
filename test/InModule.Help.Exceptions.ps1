$global:FunctionHelpTestExceptions = @(
    "TabExpansion2"
)

$global:HelpTestEnumeratedArrays = @(
    "Sqlcollaborative.Dbatools.Connection.ManagementConnectionType[]"
)

$global:HelpTestSkipParameterType = @{
    "Get-CmObject"      = @("DoNotUse")
    "Test-CmConnection" = @("Type")
    "Get-Service"       = @("DoNotUse")
}
