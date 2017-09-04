Set-StrictMode -Version 2
$ErrorActionPreference = "Stop"

class AdlJobDateRange
{
    [datetime] $Lower
    [datetime] $Upper
    [System.TimeSpan] $TimeSpan 

    # Constructor
    AdlJobDateRange([datetime] $start, [datetime] $end)
    {
        $this.Lower = $start
        $this.Upper = $end
        $this.TimeSpan = $end - $start
    }
}

function __expanddaterange( [AdlJobDateRange] $daterange )
{
    $curdate = $daterange.Lower
    while ($curdate -le $daterange.Upper)
    {
        $curdate
        $curdate = $curdate.AddDays(1)        
    }
}

function __getdailyfilename( [string] $account, [string] $folder, [datetime] $date )
{
    $date = $date.Date
    $filename = Join-Path $folder ( "jobs_" + $account + "_" + $date.ToString("yyyyMMdd") + ".clixml")
    $filename
}

function Get-AdlJobDateRange( [datetime] $start, [datetime] $end )
{
    $r = [AdlJobDateRange]::new( $start, $end )
    $r
}

function Export-AdlJobHistory( [string] $account, [AdlJobDateRange] $daterange, [string] $folder, [bool] $overwrite=$false)
{
    $dates = __expanddaterange $daterange

    foreach ($date in $dates)
    {
        $after = $date
        $before = $date.AddDays(1)
        $top = 10000
        $filename = __getdailyfilename $account $folder $date
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
            # Fetch the jobs - for analysis only get the jobs that have ended

            $jobs = Get-AdlJob -Account $account -SubmittedAfter $after -SubmittedBefore $before -top $top -State Ended
            if ($jobs -ne $null)
            {
                Write-Host "Num jobs" = $jobs.Count
                $jobs | Export-Clixml -Path $filename
            }
        }
    }

}


function Import-AdlJobHistory( [string] $account, [AdlJobDateRange] $daterange, [string] $folder)
{
    $dates = __expanddaterange $daterange

    foreach ($date in $dates)
    {
        
        $filename = __getdailyfilename $account $folder $date

        Write-Host $date " => " $filename

        if ( Test-Path $filename )
        {
            $jobs = Import-Clixml $filename
            foreach ($job in $jobs)
            {
                $job
            }
        }

    }
}


# $startdate = get-date 2017/8/16
# $enddate = get-date 2017/8/20
# $daterange = Get-AdlJobDateRange $startdate $enddate
# $adla_accountname = "datainsights"
# $output_folder = "D:\jobhistory"


# Save daily job history
# Export-AdlJobHistory -account $adla_accountname -daterange $daterange -folder $output_folder -overwrite $false


# Load the job back in
# $jobs = Import-AdlJobHistory -account $adla_accountname -daterange $daterange -folder $output_folder 


# Select the properties you want
# $jobs | Select Submitter,ErrorMessage,DegreeOfParallelism,Priority,SubmitTime,StartTime,EndTime,State,Result | ConvertTo-Json | Out-file d:\jobhistory2.json            
