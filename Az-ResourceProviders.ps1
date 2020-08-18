#$myRps = Get-AzResourceProvider
$myRps = Get-AzResourceProvider -ListAvailable

$myRpTps = $myRps | ForEach-Object -MemberName ResourceTypes

Write-Output "there are $($myRps.Count) Resource Providers Today $(get-date)"
Write-Output "there are $($myRpTps.Count) Resource Providers TYPES Today $(get-date)"

<#
Get-AzResourceProvider -ProviderNamespace "Microsoft.managementpartner"

Get-AzResourceProvider -ProviderNamespace "Microsoft.cache"

Get-AzResourceProvider -ProviderNamespace "Microsoft.softwareplan"

Get-AzResourceProvider -ProviderNamespace "Microsoft.powerbidedicated"
Get-AzResourceProvider -ProviderNamespace "Microsoft.netapp"


Get-AzResourceProvider | Select-Object -Property ProviderNamespace | ? {$_.ProviderNamespace -like '*net*'}


Get-AzResourceProvider -ListAvailable | Select-Object -Property ProviderNamespace 

#>