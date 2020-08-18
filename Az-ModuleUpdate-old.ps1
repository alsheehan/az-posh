
[CmdletBinding(DefaultParameterSetName = 'plan')]
Param
(
    [Parameter(ParameterSetName = 'plan')]
    [switch]$plan,
    [Parameter(ParameterSetName = 'apply')]
    [switch]$apply
)


# Compare the Keys and Values of a two HashTables
function compare-hashtables {

    param ($currentState, $desiredState)

    $newValues = @{ }
    $newKeys = @{ }
    
    foreach ($pubModuleName in $desiredState.keys) {
        if ($installed_module_dictionary.ContainsKey($pubModuleName)) {
            if (!($installed_module_dictionary[$pubModuleName] -eq $desiredState[$pubModuleName])) {
                #Write-Output "version:`t$($pubModuleName)`t $($desiredState[$($pubModuleName)])"
                $newValues += @{$pubModuleName = $desiredState[$pubModuleName] }
            }
        }
        else {
            #$newVersions.add($pubModuleName, $desiredState[$pubModuleName])
            #Write-Output "module:`t$($pubModuleName)"
            $newKeys += @{$pubModuleName = $desiredState[$pubModuleName] }
        }
    }
    
    $newVersions
    $newModules  

    return @{
        "newValues" = $newValues
        "newKeys" = $newKeys
    }
}

# Compare the Properties of an Object
Function Compare-ObjectProperties {
    Param(
        [PSObject]$CurrentStateObject,
        [PSObject]$DesiredStateObject
    )
    $objprops = $CurrentStateObject | Get-Member -MemberType Property,NoteProperty | ForEach-Object Name
    $objprops += $DesiredStateObject | Get-Member -MemberType Property,NoteProperty | ForEach-Object Name
    $objprops = $objprops | Sort-Object | Select-Object -Unique
    $diffs = @()
    foreach ($objprop in $objprops) {
        $diff = Compare-Object $CurrentStateObject $DesiredStateObject -Property $objprop
        if ($diff) {            
            $diffprops = @{
                PropertyName=$objprop
                CurrentStateValue=($diff | Where-Object {$_.SideIndicator -eq '<='} | ForEach-Object $($objprop))
                DesiredStateValue=($diff | Where-Object {$_.SideIndicator -eq '=>'} | ForEach-Object $($objprop))
            }
            $diffs += New-Object PSObject -Property $diffprops
        }        
    }
    if ($diffs) {return ($diffs | Select-Object PropertyName,CurrentStateValue,DesiredStateValue)}     
}

function getModuleDictionary {
    Param([PSObject] $modules)

    $returnDictionary = @{}

    foreach($module in $modules){
        $returnDictionary.add($module.Name, $module.Version)
    }
    return $returnDictionary
}

# checking the Az modules 


$searchString = "az.*"
$published_modules = find-module -Name $searchString
$installed_modules = Get-InstalledModule -Name $searchString #az.*


$published_module_dictionary = getModuleDictionary $published_modules
$installed_module_dictionary = getModuleDictionary $installed_modules

$moduleChanges = compare-hashtables $installed_module_dictionary $published_module_dictionary



if($plan) {
    write-Output "`n<<SHOW>> The Following Az.* Module(s) are NEW and SHOULD BE Installed"
    foreach($newValue in $moduleChanges.newKeys.Keys){
        Write-Output "`tinstall-module -name $($newValue) -AllowClobber -Force"
    }


    write-Output "`n<<SHOW>> The Following Az.* Module(s) are OUT OF DATE and SHOULD be Updated"
    foreach($newValue in $moduleChanges.newValues.keys){
        Write-Output "`tupdate-module -name $($newValue) -Force"
    }
} 
    
if($apply){
Write-Output "apply mode"
    write-Output "`n<<APPLY>> The Following Az.* Module(s) are NEW and ARE BEING Installed"
    foreach($newValue in $moduleChanges.newKeys.Keys){
        Write-Output "`tInvoke-Expression 'install-module -name $($newValue) -AllowClobber -Force'"
        Invoke-Expression "install-module -name $($newValue) -AllowClobber -Force"
    }


    write-Output "`n<<APPLY>> The Following Az.* Module(s) are OUT OF DATE and ARE BEING Updated"
    foreach($newValue in $moduleChanges.newValues.keys){
        Write-Output "`tInvoke-Expression 'update-module -name $($newValue) -Force'"
        Invoke-Expression "update-module -name $($newValue) -Force"
    }
}

