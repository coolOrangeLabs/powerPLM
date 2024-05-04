Import-Module powerVault

# Connection to Vault
Open-VaultConnection -Server "localhost" -Vault "PDMC-Sample" -User "Administrator" -Password ""

$vault
$vaultConnection

# Query Vault objects
$item = Get-VaultItem -Number "000001"

# Update Vault objects
$updatedItem = Update-VaultItem -Number $item.Number -Description "powerPLM Scripting Training"
$updatedItem.'Description (Item,CO)'

# Access Vault API (Vault Options)
$option = $vault.KnowledgeVaultService.GetVaultOption("POWERFLC_SETTINGS")
$settings = ConvertFrom-Json $option
$settings.tenant

$workflow = $settings.Workflows | Where-Object { $_.Name -eq "Sample.TransferItemBoms" }
$workflow.Settings
$workflow.Name

Import-Module powerFLC

# Connection to Fusion Manage
Connect-FLC -Tenant $settings.Tenant.Name -ClientId $settings.Tenant.ClientId -ClientSecret $settings.Tenant.ClientSecret -UserId $settings.Tenant.SystemUserEmail
Connect-FLC

# $flcConnection object
$flcConnection.Url
$flcConnection.Workspaces.Name

# Finding Workspaces and Configuration
$workspace = $flcConnection.Workspaces.Find("Suppliers")
$workspace = $flcConnection.Workspaces[14]
$workspace.Name
$workspace.ItemFields.Find("Name")

# Query PLM items
$flcItems = Get-FLCItems -Workspace $workspace.Name -Filter "ITEM_DETAILS:NAME=Panasonic"
$flcItem = $flcItems[0]
$flcItem.Type
$flcItem.'Main Phone'

# Update PLM items
$updatedFlcItem = Update-FLCItem -InputObject $flcItem -Properties @{
    "URL" = "http://www.panasonic.com"
    "Notes" = "powerPLM Scripting Training"
}
$updatedFlcItem.URL
$updatedFlcItem.Notes
