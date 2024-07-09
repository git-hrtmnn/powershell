# Skript zur Überprüfung des Zustands von Storage Spaces Direct (S2D)

# Funktion zur Ausgabe von Problem-Details
function Output-ProblemDetails {
    param (
        [string]$Component,
        [string]$Name,
        [string]$HealthStatus,
        [string]$OperationalStatus,
        [string]$AdditionalInfo
    )
    Write-Output "Problem found with $Component on: $Name"
    Write-Output "Health Status: $HealthStatus"
    Write-Output "Oprational Status: $OperationalStatus"
    if ($AdditionalInfo) {
        Write-Output $AdditionalInfo
    }
    Write-Output ""
}

# Überprüfe den Zustand der Storage Pools
Write-Output "Checking State of Storage Pools..."
$pools = Get-StoragePool -IsPrimordial $False | Select-Object FriendlyName, HealthStatus, OperationalStatus, ReadOnlyReason

foreach ($pool in $pools) {
    if ($pool.HealthStatus -ne "Healthy") {
        $additionalInfo = "Read-Only Reason: $($pool.ReadOnlyReason)"
        Output-ProblemDetails -Component "Storage Pool" -Name $pool.FriendlyName -HealthStatus $pool.HealthStatus -OperationalStatus $pool.OperationalStatus -AdditionalInfo $additionalInfo
    }
}

# Überprüfe den Zustand der virtuellen Festplatten
Write-Output "Checking State of virtual Disks..."
$virtualDisks = Get-VirtualDisk | Select-Object FriendlyName, HealthStatus, OperationalStatus, DetachedReason

foreach ($vDisk in $virtualDisks) {
    if ($vDisk.HealthStatus -ne "Healthy") {
        $additionalInfo = "Reason for detaching: $($vDisk.DetachedReason)"
        Output-ProblemDetails -Component "Virtual Disk" -Name $vDisk.FriendlyName -HealthStatus $vDisk.HealthStatus -OperationalStatus $vDisk.OperationalStatus -AdditionalInfo $additionalInfo
    }
}

# Überprüfe den Zustand der physischen Festplatten
Write-Output "Checking State of physical Disk..."
$physicalDisks = Get-PhysicalDisk | Select-Object FriendlyName, HealthStatus, OperationalStatus, CannotPoolReason

foreach ($pDisk in $physicalDisks) {
    if ($pDisk.HealthStatus -ne "Healthy") {
        $additionalInfo = "Reason why Disks cannot be pooled: $($pDisk.CannotPoolReason)"
        Output-ProblemDetails -Component "Physical Disk" -Name $pDisk.FriendlyName -HealthStatus $pDisk.HealthStatus -OperationalStatus $pDisk.OperationalStatus -AdditionalInfo $additionalInfo
    }
}

Write-Output "Done."
