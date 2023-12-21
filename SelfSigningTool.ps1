$executablePath = "PATHTOEXE"
$certificatePath = "CERTPATH"
$certificatePassword = "PASSWORD"

# Generate a self-signed certificate suitable for code signing
$certificate = New-SelfSignedCertificate -DnsName "Exarlo" -CertStoreLocation cert:\LocalMachine\My -Type CodeSigningCert
$certificatePathTemp = "C:\Users\exarlo\Desktop\dist\SelfSignedCertificateTemp.pfx"
$certificate | Export-PfxCertificate -FilePath $certificatePathTemp -Password (ConvertTo-SecureString -String $certificatePassword -Force -AsPlainText)

# Import the temporary certificate file
$tempCertificate = Get-PfxCertificate -FilePath $certificatePathTemp

# Move the temporary certificate file to the final path
Move-Item -Path $certificatePathTemp -Destination $certificatePath -Force

$signingParameters = @{
    "FilePath"        = $executablePath
    "Certificate"     = $tempCertificate
    "TimestampServer" = "http://timestamp.digicert.com"
}

try {
    Set-AuthenticodeSignature @signingParameters -ErrorAction Stop
    Write-Host "Executable successfully signed with a dynamically generated self-signed certificate."
}
catch {
    Write-Host "Error occurred during the signing process: $_"
}
