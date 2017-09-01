Set-StrictMode -Version 2
$ErrorActionPreference = "Stop"

function get-daterange( [datetime] $start, [datetime] $end )
{
    $curdate = $staRT
    while ($curdate -le $end)
    {
        $curdate
        $curdate = $curdate.AddDays(1)        
    }
}

function get-dailyfilename( [string] $account, [string] $folder, [datetime] $date )
{
    $date = $date.Date
    $filename = Join-Path $folder ( "jobs_" + $account + "_" + $date.ToString("yyyyMMdd") + ".clixml")
    $filename
}

function Export-AdlJobHistory( [string] $account, [datetime] $start, [datetime] $end, [string] $folder, [bool] $overwrite=$false)
{
    $dates = get-daterange $startdate $enddate

    foreach ($date in $dates)
    {
        $after = $date
        $before = $date.AddDays(1)
        $top = 10000
        $filename = get-dailyfilename $account $folder $date
        Write-Host $date " => " $filename

        if ( Test-Path $filename )
        {
            if ($overwrite)
            {
                Remove-Item $filename
            }
        }


        if ( !(Test-Path $filename) )
        {
            $jobs = Get-AdlJob -Account $account -SubmittedAfter $after -SubmittedBefore $before -top $top
            if ($jobs -ne $null)
            {
                Write-Host "Num jobs" = $jobs.Count
                $jobs | Export-Clixml -Path $filename
            }
        }
    }

}



function Import-AdlJobHistory( [string] $account, [datetime] $start, [datetime] $end, [string] $folder)
{
    $items = New-Object System.Collections.Generic.List[System.Object]

    $dates = get-daterange $startdate $enddate
    foreach ($date in $dates)
    {
        
        $filename = get-dailyfilename $account $folder $date

        Write-Host $date " => " $filename

        if ( Test-Path $filename )
        {
            $jobs = Import-Clixml $filename
            $items.AddRange($jobs)
        }

    }

    $items

}


# $startdate = get-date 8/1/2017
# $enddate = get-date 8/31/2017
# $adla_accountname = "datainsights"
# $output_folder = "D:\jobhistory"


# Save daily job history
# Export-AdlJobHistory -account $adla_accountname -start $startdate -end $enddate -folder $output_folder -overwrite $false


# $jobs = Import-AdlJobHistory -account $adla_accountname -start $startdate -end $enddate -folder $output_folder 

# $jobs | ConvertTo-Json | Out-file d:\jobhistory.json



# select the properties you want
# $jobs | Select Submitter,ErrorMessage,DegreeOfParallelism,Priority,SubmitTime,StartTime,EndTime,State,Result | ConvertTo-Json | Out-file d:\jobhistory2.json            
