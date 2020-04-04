$Endpoint_registerapp = New-UDEndpoint -Url "/registerapp" -Method "POST" -Endpoint {
    param($Body)
    $parameters = ($Body | ConvertFrom-Json)
$ApplicationName = $parameters.ApplicationName
$AzureUser = $parameters.AzureUser
$User = 'xxxxx'
$DeveloperEmail = $parameters.DeveloperEmail
$Keyvault = 'true'
$KeyvaultName = $parameters.KeyvaultName
$Password = Get-Content C:\inetpub\wwwroot\UniversalDashboard\Encrypted.txt | ConvertTo-SecureString -Key (1..16)
$Creds = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $user,$Password
$appname = $ApplicationName.toupper()
$appuri = "https://$appname.azurewebsites.net"
$appreply = "https://localhost"
[parameter(parametersetname = "KeyVault")]$DeveloperEmail
Connect-AzureAD -Credential $Creds | out-null
Connect-AzAccount -Credential $Creds | out-null
Get-azsubscription | where {$_.id -match $id} | Select-AzSubscription | out-null
if (!(get-azadapplication -displaynamestartwith $($appname) -ErrorAction Stop)) {
$myapp = new-azadapplication -displayname $appname -identifieruri $appuri -replyurls $appreply
new-azadserviceprincipal -applicationid $myapp.applicationid
$myappsp = get-azadapplication  -displaynamestartwith $($appname)
}
else {
write-verbose "An Application with the name $($appname) is already registered"
}
write-verbose "$myapp"
$myapp = get-azadapplication -displaynamestartwith $($appname)
$startdate = get-date
$enddate = $startdate.AddYears(100)
try {
    $clientSecret = (New-AzureADApplicationPasswordCredential -objectid $myapp.ObjectId -CustomKeyIdentifier "Primary" -StartDate $startdate -EndDate $enddate).value
    write-verbose "Secret created -> $clientsecret"
    }
    catch {
    "Error setting app secret - $_"
    }
    
    Write-Verbose "Secret is valid for 100 years!"
    $securekey = ConvertTo-SecureString -string $clientSecret -AsPlainText -Force
    write-verbose "Secret string secured"
    $secretAppId = convertto-securestring -string $($myapp.ApplicationId) -AsPlainText -Force
    
            write-verbose "$($myapp.ObjectId) is the object ID of the App"
            #Change subscription ID so we can fetch keyvaults in this resource group
        $context = get-azsubscription -SubscriptionId xxxxx
        set-azcontext $context
        $vaultgroup = "xxxxx"
        $location = (Get-AzResourceGroup -Name $vaultgroup).location
            #No Vault - add one
        New-AzKeyVault -name $KeyvaultName -ResourceGroupName "xxxxx" -Location $location
        sleep 30
        $projectkeyvault = get-azkeyvault -resourcegroupname "xxxxx -VaultName $keyvaultname
            set-azkeyvaultsecret -VaultName $projectkeyvault.vaultname -name "$($appname)-Client-ID" -SecretValue $($secretAppId) | out-null
            set-azkeyvaultsecret -Vaultname $projectkeyvault.vaultname -name "$($appname)-ClientSecret" -SecretValue $($securekey) | out-null #-Expires $($startdate.adddays(10))
            write-verbose "secret for the Application Client Secret key vaulted"
            Set-AzKeyVaultAccessPolicy -VaultName $projectkeyvault.vaultname -ServicePrincipalName $($myappsp.IdentifierUris) -PermissionsToSecrets get,list
            write-verbose "Application access to key vault added as get/list"
            #Set-AzKeyVaultAccessPolicy -VaultName $($appname.replace('APP', 'kv')) -UserPrincipalName $DeveloperEmail -PermissionsToSecrets get, list
            Set-AzKeyVaultAccessPolicy -VaultName $projectkeyvault.vaultname -UserPrincipalName $DeveloperEmail -PermissionsToSecrets get,list
            write-verbose "Developer Access for $($developeremail) to key vault added as get/list"      
        }