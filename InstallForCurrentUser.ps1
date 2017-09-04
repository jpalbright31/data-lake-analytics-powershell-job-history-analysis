﻿# PURPOSE
# -------
# Manually installs the Visio PowerShell module into the user's PowerShell folder
#
# NOTES
# -----
# - If another PowerShell session has the Visio PS module loaded, then the VisioPS binaries cannot 
#   be replaced by this script because those binaries are locked. In this case, those PS sessions
#   must be terminated before the script will work

Set-StrictMode -Version 2
$ErrorActionPreference = "Stop"

function New-Folder($path)
{
    if (!(test-path $path))
    {
        mkdir $path
    }
}

function Assert-Path($path)
{
    if (!(test-path $path))
    {
		$msg = "Path does not exist " + $path
		Write-Error $msg
    }
}

function Clean-Folder($path)
{
	if (Test-Path $path)
	{
		Remove-Item $path -Recurse -Force 
	}
}

function Mirror-Folder($frompath, $topath)
{
	# /njh - no job header
	# /njh - no job summary
	# /fp - show full paths for files
	# /ns - don't show sizes
	robocopy $frompath $topath /mir /njh /njs /ns /nc /np 
}


function Test-Locked($filePath)
{
    $fileInfo = New-Object System.IO.FileInfo $filePath

    try 
    {
        $fileStream = $fileInfo.Open( [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read )
        return $false
    }
    catch
    {
        return $true
    }
}

# -------------------------------------------
# User-supplied information about this module
$module_foldername = "AzureDataLakeUtils"
$release = "Debug"

# -------------------
# Calculate the paths

$script_path = $myinvocation.mycommand.path
$script_folder = Split-Path $script_path -Parent
$src_folder = Join-Path $script_folder "AzureDataLakeUtils"
$docfolder =  "$home/documents" 
$wps =  Join-Path $docfolder "WindowsPowerShell"
$modules =  Join-Path $wps "Modules"
$the_module_folder=  Join-Path $modules $module_foldername
Assert-Path $src_folder 
Assert-Path $docfolder

# ------------------------------
# Prepare the Distination Folder
New-Folder $wps 
New-Folder $modules
Assert-Path $wps
Assert-Path $modules 
Clean-Folder $the_module_folder
New-Folder $the_module_folder
Assert-Path $the_module_folder 

# -----------------
# Copy the contents
Mirror-Folder $src_folder $the_module_folder 

