# Query both endpoints and compare project lists
Write-Host "=== Data Model Endpoint Verification ==="
Write-Host ""

# Cloud endpoint
Write-Host "[1] Cloud Endpoint"
try {
    $cloud = Invoke-RestMethod "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/model/projects/" -TimeoutSec 10 -SkipCertificateCheck
    $cloud_count = if ($cloud -is [array]) { $cloud.Count } elseif ($cloud -is [object]) { 1 } else { 0 }
    Write-Host "[OK] Cloud responded: $cloud_count projects"
    
    # Sample first few
    if ($cloud_count -gt 0) {
        Write-Host "Sample projects:"
        $cloud | Select-Object -First 3 | ForEach-Object { 
            Write-Host "    - [$($_.obj_id)] $($_.title) (maturity=$($_.maturity), phase=$($_.phase))"
        }
    }
}
catch {
    Write-Host "[ERROR] Cloud failed: $_"
}

Write-Host ""

# Local endpoint
Write-Host "[2] Local Endpoint"
try {
    $local = Invoke-RestMethod "http://localhost:8010/model/projects/" -TimeoutSec 10
    $local_count = if ($local -is [array]) { $local.Count } elseif ($local -is [object]) { 1 } else { 0 }
    Write-Host "[OK] Local responded: $local_count projects"
    
    # Sample first few
    if ($local_count -gt 0) {
        Write-Host "Sample projects:"
        $local | Select-Object -First 3 | ForEach-Object { 
            Write-Host "    - [$($_.obj_id)] $($_.title) (maturity=$($_.maturity), phase=$($_.phase))"
        }
    }
}
catch {
    Write-Host "[ERROR] Local failed: $_"
}

Write-Host ""

# Validation
Write-Host "[3] Validation"
if ($cloud_count -eq $local_count -and $cloud_count -gt 0) {
    Write-Host "[PASS] Both endpoints serve $cloud_count projects - governance data ACCESSIBLE"
} else {
    Write-Host "[WARNING] Count mismatch (Cloud=$cloud_count, Local=$local_count)"
}
