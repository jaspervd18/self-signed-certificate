# Run ensure script elevated
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Write-Error "This script needs to be run as admin."
    Break
    # $CommandLine = "-File `"" + $MyInvocation.PSCommandPath + "`" " + $MyInvocation.UnboundArguments
    # $proc = Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
    # $proc.WaitForExit()
    # Exit
}

function EnsureSignerCert([string] $signerSubject) {
    $signer = (Get-ChildItem cert:\LocalMachine\Root | Where-Object { $_.subject -eq "CN=$signerSubject"})
    if ($signer) {
        Write-Host "Trusted signer certificate found: $($signer.Thumbprint)"
    }
    else {
        $signer = (Get-ChildItem cert:\LocalMachine\My | Where-Object { $_.subject -eq "CN=$signerSubject"})
        if ($signer) {
            Write-Host "Signer certificate found: $($signer.Thumbprint)"
        }
        else {
            $signer = New-SelfSignedCertificate -Subject "DlwNetRootCA" -KeyUsage CertSign,CRLSign,DigitalSignature -KeyUsageProperty All -CertStoreLocation Cert:\LocalMachine\My -NotAfter (Get-Date).AddYears(10)
            Write-Host "Created signer certificate: $($signer.Thumbprint)"
        }

        # Trust signer certificate
        $store = get-item cert:\LocalMachine\Root
        $store.Open("ReadWrite")
        $store.Add($signer)
        $store.Close()
        Write-Host "Copied signer certificate to trusted roots."
    }
    Write-Output $signer
}

function EnsureHttpsCert([string] $subject, [string[]] $dns, $signer) {
    $cert = (Get-ChildItem cert:\CurrentUser\My | Where-Object { $_.subject -eq "CN=$subject"})
    if ($cert) {
        Write-Output "Certificate found for $subject`: $($cert.Thumbprint)"
    }
    else {
        $cert = New-SelfSignedCertificate -Subject $subject -DnsName $dns -CertStoreLocation Cert:\CurrentUser\My -NotAfter (Get-Date).AddYears(10) -Signer $signer
        Write-Output "Created certificate for $subject`: $($cert.Thumbprint)"
    }
}
$signerSubject = 'DlwNetRootCA'
$signer =  EnsureSignerCert $signerSubject;

EnsureHttpsCert "PeeQLocal" @(
    "*.peeq.ecom.local.peeq.dlwnet.com",
    "*.bicycle.local.epibase.dlwnet.com"
    ) $signer