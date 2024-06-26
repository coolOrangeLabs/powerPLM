#==============================================================================#
# (c) 2024 coolOrange s.r.l.                                                   #
#                                                                              #
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#==============================================================================#

Register-VaultEvent -EventName UpdateItemStates_Restrictions -Action {
	param($items = @())

    #TODO: adjust your workspace name if it's not "Items"
    $workspaceName = "Items"

    #TODO: adjust your item number field if it's not "NUMBER"
    $itemNumberField = "NUMBER"

    # Connect to Fusion Manage
    $connected = $false
    $settings = $vault.KnowledgeVaultService.GetVaultOption("POWERFLC_SETTINGS")
    if ($settings) {
        $settings = ConvertFrom-Json $settings
        $connected = Connect-FLC -Tenant $settings.Tenant.Name -ClientId $settings.Tenant.ClientId -ClientSecret $settings.Tenant.ClientSecret -UserId $settings.Tenant.SystemUserEmail
    }

    if (-not $connected) {
        foreach ($item in $items) {
            Add-VaultRestriction -EntityName $item._Number -Message ("Connection to Fusion Manage '$($settings.Tenant.Name)' failed.")
        }
        return
    }

    foreach ($item in $items) {
        if ($item._NewState -eq "Released") {
            # Get Fusion Manage Item
            $workspace = $flcConnection.Workspaces.Find($workspaceName)
            $flcItem = (Get-FLCItems -Workspace $workspace.Name -Filter ('ITEM_DETAILS:{0}="{1}"' -f $itemNumberField, $item._Number))[0]
            if ($? -eq $false) { return }

            if (-not $flcItem) {
                continue
            }

            # Get Fusion Manage Change Order
            $flcItemRaw = Invoke-RestMethod -Uri "$($flcConnection.Url.AbsoluteUri)api/v3/workspaces/$($workspace.Id)/items/$($flcItem.RootId)" -Method Get -Headers @{
                "Content-Type"  = "application/json"
                "Authorization" = $flcConnection.AuthenticationToken
                "X-tenant"      = $flcConnection.Tenant.ToUpper()
                "X-user-id"     = $flcConnection.UserId
            }
            $flcChangeOrder = (Get-FLCItems -Workspace "Change Orders" -Filter ('{0}="{1}"' -f "itemDescriptor", $flcItemRaw.undergoingChange.title))[0]
            if ($flcChangeOrder) {
                if ($flcChangeOrder.WorkflowState -eq "Preparation") {
                    Add-VaultRestriction -EntityName $item._Number -Message ("The associated PLM Change Order '$($flcChangeOrder.Title)' is in '$($flcChangeOrder.WorkflowState)'. The item cannot be released.")
                }
            }
        }
    }
}