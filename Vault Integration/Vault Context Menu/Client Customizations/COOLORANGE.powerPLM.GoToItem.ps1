#==============================================================================#
# (c) 2024 coolOrange s.r.l.                                                   #
#                                                                              #
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#==============================================================================#

Add-VaultMenuItem -Location ItemContextMenu -Name "Go To Fusion Manage Item..." -Action {
    param($entities)

    #TODO: adjust your workspace name if it's not "Items"
    $workspaceName = "Items"
    
    #TODO: adjust your item number field if it's not "NUMBER"
    $itemNumberField = "NUMBER"
   
    if (-not $flcConnection) {
        # Connect to Fusion Manage
        $connected = $false
        $settings = $vault.KnowledgeVaultService.GetVaultOption("POWERFLC_SETTINGS")
        if ($settings) {
            $settings = ConvertFrom-Json $settings
            $connected = Connect-FLC -Tenant $settings.Tenant.Name -ClientId $settings.Tenant.ClientId -ClientSecret $settings.Tenant.ClientSecret -UserId $settings.Tenant.SystemUserEmail
        }
 
        if (-not $connected) {
            [System.Windows.Forms.MessageBox]::Show("Connection to Fusion Manage '$($settings.Tenant.Name)' failed.")
            return
        }        
    }
 
    $workspace = $flcConnection.Workspaces.Find($workspaceName)
    if (-not $workspace) {
        [System.Windows.Forms.MessageBox]::Show("Workspace '$workspaceName' not found in Fusion Manage '$($settings.Tenant.Name)'")
        return
    }

    foreach($item in $entities){
        $flcItem = (Get-FLCItems -Workspace $workspace.Name -Filter ('ITEM_DETAILS:{0}="{1}"' -f $itemNumberField, $item._Number))[0]
        if ($? -eq $false -or -not $flcItem) { 
            [System.Windows.Forms.MessageBox]::Show("Item '$($item._Number)' not found in Fusion Manage '$($settings.Tenant.Name)'")
            continue
        }

        $urn = "urn:adsk.plm:tenant.workspace.item:$($flcConnection.Tenant.ToUpper()).$($workspace.Id).$($flcItem.Id)"
        $itemId = $urn.Replace(":", "%60").Replace(".", ",")
        Start-Process "$($flcConnection.Url.AbsoluteUri)plm/workspaces/$($workspace.Id)/items/itemDetails?view=full&tab=details&mode=view&itemId=$($itemId)"
    }
}