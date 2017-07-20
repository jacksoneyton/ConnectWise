Function Connect-Connectwise
{
    Param(
        [Parameter(
        Mandatory = $true,
        ParameterSetName = '',
        ValueFromPipeline = $true)]
        [string]$URL,
        [Parameter(
        Mandatory = $true,
        ParameterSetName = '',
        ValueFromPipeline = $true)]
        [string]$Company,
        [Parameter(
        Mandatory = $true,
        ParameterSetName = '',
        ValueFromPipeline = $true)]
        [string]$PublicKey,
        [Parameter(
        Mandatory = $true,
        ParameterSetName = '',
        ValueFromPipeline = $true)]
        [string]$PrivateKey
    )
    
    
    $req = Invoke-WebRequest -Uri "$URL/login/companyinfo/$Company"
    $info = ConvertFrom-Json $req.Content
    $baseurl = "$URL/$($info.Codebase)apis/3.0"
    $script:baseurl = "$URL" + "v4_6_release/apis/3.0"
    Write-Output $script:baseurl
    [string]$Authstring = $Company + '+' + $PublicKey + ':' + $PrivateKey
    $encodedAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));
    #Create Header
    $script:header = [Hashtable] @{
    Authorization = ("Basic {0}" -f $encodedAuth)
    Accept = "application/vnd.connectwise.com+json;"
    "Content-Type" = "application/json"
    'x-cw-usertype' = "member"
    };
    return $script:header;
}

Function Get-AllObjects
{
    Param (
    [Parameter(Mandatory = $false)]
    [System.Collections.Hashtable]$Header = $null,
    [Parameter(
    Mandatory = $true,
    ValueFromPipeline = $true)]
    [string]$Endpoint,
    [Parameter(
    Mandatory = $false,
    ValueFromPipeline = $true)]
    [string]$Conditions=""  
    )
    if($header -eq $null)
    {
        $header = $script:header
    }
    if($header -eq $null)
    {
        Write-Error "No header information. Please run Connect-Connectwise method"
        return;
    }
    $ReturnObject = @()
    $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
    $PAGE_SIZE = 1000;
    $CountRequest = [System.UriBuilder]($script:baseurl + $EndPoint + "/count")
    $Request = [System.UriBuilder]($script:baseurl + $EndPoint)
    if($Conditions -notlike "")
    {
        $Parameters['Conditions'] = $Conditions
    }
    $CountRequest.Query = $Parameters.ToString()
    $Parameters['pageSize'] = $PAGE_SIZE
    
    $count = (Invoke-RestMethod -Uri $CountRequest.Uri -Method Get -Headers $header -ContentType $contentType).Count
 
    if ($count -ne 0)
    {
        $total_pages = [int]($count / $PAGE_SIZE);
        for ($i = 1; $i -le ($total_pages + 1); $i++)
        {
            $Parameters['page'] = $i
            $Request.Query = $Parameters.ToString()
            $ReturnObject += Invoke-RestMethod -Uri "$($Request.Uri)" -Method Get -Headers $header -ContentType $contentType
        }
    }

    if($Endpoint -like "*/system/reports/*")
    {
        $CustomObjectArray = @()
        $ReturnObject.row_values | %{
            $row = $_
            $CustomObject = New-Object psobject    
            $i = 0;
            $row | %{ $CustomObject | Add-Member -MemberType NoteProperty -Name ($ReturnObject.column_definitions[$i++] | get-member -type NoteProperty).Name -Value $_ }
            $CustomObjectArray += $CustomObject
        }
        $ReturnObject = $CustomObjectArray;
    }

    return $ReturnObject;
}

Function New-CWTicket
{
    Param (
    [Parameter(Mandatory = $false)]
    [System.Collections.Hashtable]$Header,
    [Parameter(
    Mandatory = $true,
    ValueFromPipeline = $true)]
    [string]$Summary,
    [Parameter(
    Mandatory = $false,
    ValueFromPipeline = $true)]
    [string]$CompanyName,
    [Parameter(
    Mandatory = $false,
    ValueFromPipeline = $true)]
    [string]$Status,
    [Parameter(
    Mandatory = $false,
    ValueFromPipeline = $true)]
    $BudgetHours,
    [Parameter(
    Mandatory = $false,
    ValueFromPipeline = $true)]
    $Type,
    [Parameter(
    Mandatory = $false,
    ValueFromPipeline = $true)]
    $SubType,
    [Parameter(
    Mandatory = $false,
    ValueFromPipeline = $true)]
    $Item
    )

    $JSON =  @{
        summary = $Summary;
        company = @{ name = $CompanyName };
        status = @{ name = $Status };
        type = @{ name = $Type };
        subType = @{ name = $SubType };
        item = @{ name = $Item };

    } | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$($script:baseurl)/service/tickets" -Method Post -Headers $header -Body $JSON;
    $response
}

Function Invoke-CWRestMethod
{
param(
    $Endpoint,
    $Method,
    $Body)
    Invoke-RestMethod -Uri "$($script:baseurl)$Endpoint" -Method $Method -Headers $script:header -Body $Body #-ContentType "application/json" 
}
Export-ModuleMember -Function *