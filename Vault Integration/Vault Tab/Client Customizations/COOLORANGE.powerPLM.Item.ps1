#==============================================================================#
# (c) 2024 coolOrange s.r.l.                                                   #
#                                                                              #
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#==============================================================================#

if ($processName -notin @('Connectivity.VaultPro')) {
    return
}

Add-VaultTab -Name 'Fusion Manage Item' -EntityType Item -Action {
    param($selectedItem)

    #TODO: adjust your workspace name if it's not "Items"
    $workspaceName = "Items"

    #TODO: adjust your item number field if it's not "NUMBER"
    $itemNumberField = "NUMBER"

    $partNumber = $selectedItem._Number
    $xamlFile = [xml](Get-Content "$PSScriptRoot\COOLORANGE.powerPLM.Item.xaml")
    $tab = [Windows.Markup.XamlReader]::Load( (New-Object System.Xml.XmlNodeReader $xamlFile) )

    $tab.FindName('Button').Visibility = "Collapsed"
    $tab.FindName('ItemData').Visibility = "Collapsed"

    # Connect to Fusion Manage
    $connected = $false
    $settings = $vault.KnowledgeVaultService.GetVaultOption("POWERFLC_SETTINGS")
    if ($settings) {
        $settings = ConvertFrom-Json $settings
        $connected = Connect-FLC -Tenant $settings.Tenant.Name -ClientId $settings.Tenant.ClientId -ClientSecret $settings.Tenant.ClientSecret -UserId $settings.Tenant.SystemUserEmail
    }

    if (-not $connected) {
        $tab.FindName('Title').Content = "Connection to Fusion Manage '$($settings.Tenant.Name)' failed."
        return $tab
    }
    
    # Get Fusion Manage Item
    $workspace = $flcConnection.Workspaces.Find($workspaceName)
    $flcItem = (Get-FLCItems -Workspace $workspace.Name -Filter ('ITEM_DETAILS:{0}="{1}"' -f $itemNumberField, $partNumber))[0]
    if ($? -eq $false) { return }

    if (-not $flcItem) {
        $tab.FindName('Title').Content = "No Fusion Manage Item associated with item $($partNumber)"
        return $tab
    }

    # Display Fusion Manage Item
    $tab.FindName('ItemData').Visibility = "Visible"
    $tab.FindName('ItemData').DataContext = $flcItem
    $tab.FindName('Title').Content = "Fusion Manage Item '$partNumber' - '$($flcItem.Title)'"
    $tab.FindName('Button').Visibility = "Visible"
    $tab.FindName('Button').Content = "Go To PLM Item..."

    # Get Fusion Manage Change Order
    $flcItemRaw = Invoke-RestMethod -Uri "$($flcConnection.Url.AbsoluteUri)api/v3/workspaces/$($workspace.Id)/items/$($flcItem.RootId)" -Method Get -Headers @{
        "Content-Type"  = "application/json"
        "Authorization" = $flcConnection.AuthenticationToken
        "X-tenant"      = $flcConnection.Tenant.ToUpper()
        "X-user-id"     = $flcConnection.UserId
    }
    $flcChangeOrder = (Get-FLCItems -Workspace "Change Orders" -Filter ('{0}="{1}"' -f "itemDescriptor", $flcItemRaw.undergoingChange.title))[0]
    if ($flcChangeOrder) {
        $tab.FindName('ChangeOrderData').DataContext = $flcChangeOrder
    }

    # Add button click event
    $urn = $flcItemRaw.urn.Replace(":", "%60").Replace(".", ",")
    $tab.FindName('Button').Tag = "$($flcConnection.Url.AbsoluteUri)plm/workspaces/$($workspace.Id)/items/itemDetails?view=full&tab=details&mode=view&itemId=$($urn)"
    $tab.FindName('Button').Add_Click({
            param ($button, $e)
            Start-Process $button.Tag
        }.GetNewClosure())

    return $tab
}