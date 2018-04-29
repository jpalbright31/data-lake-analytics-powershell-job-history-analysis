---
services: data-lake-analytics
platforms: powershell
author: saveenr-msft
---

# Azure Data Lake Analytics analyze job history with PowerShell

PowerShell scripts to help analyze trends on U-SQL jobs.


## Common scenarios for listing jobs


#### List jobs submitted in the last five days and that successfully completed.

```
$d = (Get-Date).AddDays(-5)
Get-AdlJob -Account $adla -SubmittedAfter $d -State Ended -Result Succeeded
```

#### List all failed jobs submitted by `joe@contoso.com` within the past seven days.

```
Get-AdlJob -Account $adla -Submitter "joe@contoso.com" -SubmittedAfter (Get-Date).AddDays(-7) -Result Failed
```

## Filtering a list of jobs

Once you have a list of jobs in your current PowerShell session. You can use normal PowerShell cmdlets to filter the list.

#### Filter a list of jobs to the jobs submitted in the last 24 hours

```
$upperdate = Get-Date
$lowerdate = $upperdate.AddHours(-24)
$jobs | Where-Object { $_.EndTime -ge $lowerdate }
```

#### Filter a list of jobs to the jobs that ended in the last 24 hours

```
$upperdate = Get-Date
$lowerdate = $upperdate.AddHours(-24)
$jobs | Where-Object { $_.SubmitTime -ge $lowerdate }
```

### Filter a list of jobs to the jobs that started running. 

A job might fail at compile time - and so it never starts. Let's look at the failed jobs that actually started running and then failed.

```
$jobs | Where-Object { $_.StartTime -ne $null }
```

## Analyzing a list of jobs

Use the `Group-Object` cmdlet to analyze a list of jobs.

#### Count the number of jobs by Submitter

```
$jobs | Group-Object Submitter | Select -Property Count,Name
```

#### Count the number of jobs by Result
```
$jobs | Group-Object Result | Select -Property Count,Name
```

#### Count the number of jobs by State
```
$jobs | Group-Object State | Select -Property Count,Name
```

####  Count the number of jobs by DegreeOfParallelism
```
$jobs | Group-Object DegreeOfParallelism | Select -Property Count,Name
```

### Advanced techniques

#### Adding useful properties to Job objects

When performing an analysis, it can be useful to add properties to the Job objects to make filtering and grouping simpler. The following  snippet shows how to annotate a JobInfo with calculated properties.

```
function annotate_job( $j )
{
    $dic1 = @{
        Label='AUHours';
        Expression={ ($_.DegreeOfParallelism * ($_.EndTime-$_.StartTime).TotalHours)}}
    $dic2 = @{
        Label='DurationSeconds';
        Expression={ ($_.EndTime-$_.StartTime).TotalSeconds}}
    $dic3 = @{
        Label='DidRun';
        Expression={ ($_.StartTime -ne $null)}}

    $j2 = $j | select *, $dic1, $dic2, $dic3
    $j2
}

$jobs = Get-AdlJob -Account $adla -Top 10
$jobs = $jobs | %{ annotate_job( $_ ) }
```



# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.


