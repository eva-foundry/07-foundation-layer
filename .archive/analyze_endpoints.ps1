# Detailed analysis of cloud vs local endpoint data
Write-Host "=== Project Data Consistency Check ==="
Write-Host ""

# Disable SSL cert check
if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type) {
    Add-Type -TypeDefinition @'
        using System;
        using System.Net;
        using System.Net.Security;
        using System.Security.Cryptography.X509Certificates;
        public class ServerCertificateValidationCallback
        {
            public static void Ignore()
            {
                ServicePointManager.ServerCertificateValidationCallback += 
                    (Object obj, X509Certificate certificate, X509Chain chain, SslPolicyErrors errors) => true;
            }
        }
'@
}
[ServerCertificateValidationCallback]::Ignore()

# Query both endpoints
$cloud = Invoke-RestMethod "https://marco-eva-data-model.livelyflower-7990bc7b.canadacentral.azurecontainerapps.io/model/projects/" -TimeoutSec 10
$local = Invoke-RestMethod "http://localhost:8010/model/projects/" -TimeoutSec 10

Write-Host "[Cloud Endpoint Analysis]"
Write-Host "  Total records: $($cloud.Count)"
$cloud_with_id = @($cloud | Where-Object { $_.obj_id })
Write-Host "  Records with obj_id: $($cloud_with_id.Count)"
$cloud_missing_id = @($cloud | Where-Object { -not $_.obj_id })
if ($cloud_missing_id.Count -gt 0) {
    Write-Host "  Records with NO obj_id: $($cloud_missing_id.Count) [INCOMPLETE]"
}

Write-Host ""
Write-Host "[Local Endpoint Analysis]"
Write-Host "  Total records: $($local.Count)"
$local_with_id = @($local | Where-Object { $_.obj_id })
Write-Host "  Records with obj_id: $($local_with_id.Count)"
$local_missing_id = @($local | Where-Object { -not $_.obj_id })
if ($local_missing_id.Count -gt 0) {
    Write-Host "  Records with NO obj_id: $($local_missing_id.Count) [INCOMPLETE]"
}

Write-Host ""
Write-Host "[Data Comparison]"
Write-Host "  Difference: $($cloud.Count - $local.Count) extra records on cloud"
if (($cloud.Count - $local.Count) -gt 0) {
    Write-Host "  Status: ⚠ Cloud and local are OUT OF SYNC"
}

# Find differences
$cloud_ids = @($cloud.obj_id | Where-Object { $_ })
$local_ids = @($local.obj_id)
$only_in_cloud = @($cloud_ids | Where-Object { $_ -notin $local_ids })
if ($only_in_cloud.Count -gt 0) {
    Write-Host ""
    Write-Host "  Projects only in Cloud (may be orphaned):"
    $only_in_cloud | ForEach-Object { Write-Host "    - $_" }
}

Write-Host ""
Write-Host "[Conclusion]"
if ($cloud.Count -gt 0 -and $local.Count -gt 0) {
    Write-Host "✓ GOVERNANCE DATA ACCESSIBLE:"
    Write-Host "  • Cloud (ACA/Cosmos): $($cloud.Count) projects - ACTIVE"
    Write-Host "  • Local (Development): $($local.Count) projects - ACTIVE"
    Write-Host "  • Data Model endpoints are operational and serving project data"
    
    if ($cloud.Count -ne $local.Count) {
        Write-Host ""
        Write-Host "⚠ ATTENTION: Data synchronization gap detected"
        Write-Host "  • Cloud has $($cloud.Count - $local.Count) additional records"
        Write-Host "  • Recommend: Verify if additional records are current or orphaned"
    }
} else {
    Write-Host "✗ ERROR: One or both endpoints failed"
}
