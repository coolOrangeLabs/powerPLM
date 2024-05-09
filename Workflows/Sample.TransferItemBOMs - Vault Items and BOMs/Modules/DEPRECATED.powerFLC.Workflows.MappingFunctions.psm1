#==============================================================================#
# (c) 2023 coolOrange s.r.l.                                                   #
#                                                                              #
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#==============================================================================#

if ((get-process -id $pid).Name -eq 'Connectivity.JobProcessor.Delegate.Host') {
    function GetVaultThickClientLinkCompat($Entity) {
        if ($Entity._EntityTypeID -eq "ITEM") {
            $objectId = [System.Web.HttpUtility]::UrlEncode($Entity._Number)
            $objectType = "ItemRevision"
        } elseif ($Entity._EntityTypeID -eq "FILE") {
            $objectId = [System.Web.HttpUtility]::UrlEncode($Entity._FullPath)
            $objectType = "File"
        } else {
            return ""
        }
        $serverUri = New-Object Uri -ArgumentList $vault.InformationService.Url
        $hostname = $serverUri.Host
        if ($hostname -ieq "localhost") { $hostname = [System.Net.Dns]::GetHostName() }
        return "$($serverUri.Scheme)://$($hostname)/AutodeskDM/Services/EntityDataCommandRequest.aspx?Vault=$($vaultConnection.Vault)&ObjectId=$($objectId)&ObjectType=$($objectType)&Command=Select"
    }

    function GetVaultThinClientLinkCompat($Entity) {
        # Only works for item and file
        $id = GetVaultPersistentId -entity $Entity
        $serverUri = New-Object Uri -ArgumentList $vault.InformationService.Url
        $hostname = $serverUri.Host
        if ($hostname -ieq "localhost") { $hostname = [System.Net.Dns]::GetHostName() }
        return "$($serverUri.Scheme)://$($hostname)/AutodeskTC/$($hostname)/$($vaultConnection.Vault)#/Entity/Details?id=m$($id)&itemtype=$($Entity._EntityType.DisplayName)"
    }
}


