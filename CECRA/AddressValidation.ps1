Param(
    [String]$FileName
)

Function Get-AddressId {
# Function to comsume RestFul API
    [cmdletbinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$Address
    )
    Begin{}
    Process{
        $Uri = "http://api.mcap.com/addressvalidation/v1/validate?address=$Address"
        Invoke-RestMethod -Method GET -ContentType 'application/json' -Uri $Uri
    }
    END{}

}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"


$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$File = $ScriptPath + '\' + $FileName
Write-Output $File
$List = Import-Csv $File

ForEach($App in $List){
    $Address = $App.Unit.Trim() + ' ' + $App.StreetNumber.Trim() + ' ' + $App.StreetName.Trim() + ' ' + $App.City.Trim() + ' ' + $App.Province.Trim() + ' ' + $App.PostalCode.Trim()
    if(! [String]::IsNullOrEmpty($App.StreetName)){
        #Write-Output $Address.Trim()
        $Results = Get-AddressId -Address $Address
        Write-Output $Results
        if($Results.Length -gt 0){
            $App.SuggestedScore = $Results.Get(0).score
            $App.SuggestedUAID = $Results.Get(0).uaid
            $app.SuggestedUUAID = $Results.Get(0).uuaid
            $App.SuggestedStreetNumber = $Results.Get(0).streetNumber
            $App.SuggestedStreetName = $Results.Get(0).streetName
            $App.SuggestedStreetSubAddress = $Results.Get(0).streetSubAddress
            $App.SuggestedPostalCode = $Results.Get(0).postalCode
            $App.SuggestedMunicipality = $Results.Get(0).municipality
            $App.SuggestedProvince = $Results.Get(0).stateProvince
            $app.SuggestedCountry = $Results.Get(0).country
            $App.SuggestedPropertyTypeCode = $Results.Get(0).propertyTypeCode
            $App.SuggestedLatitude = $Results.Get(0).coordinates.lat
            $App.SuggestedLongitude = $Results.Get(0).coordinates.lon
        }
    }
}

$List | Export-Csv $File -Force -NoTypeInformation -Encoding Unicode

