function Install-Agent
{
   # Download Monitoring Agent
   if ( -not (Test-Path "C:\rs-pkgs\rackspace-monitoring-agent-x64.msi") )
   {
      try
      {
         (New-Object System.Net.webclient).DownloadFile('http://stable.packages.cloudmonitoring.rackspace.com/rackspace-monitoring-agent-x64.msi','C:\rs-pkgs\rackspace-monitoring-agent-x64.msi')
      }
      catch [Exception]
      {
         Write-Debug $_.Exception.Message
         Write-EventLog -LogName DevOps -Source RS_rsRaxMon -EntryType Error -EventId 1000 -Message ("Error Downloading Rackspace Cloud Monitoring Agent`r`n$_.Exception.Message")
      }
   }
   # Install Agent
   if ( -not (Test-Path "C:\Program Files (x86)\Rackspace Monitoring\rackspace-monitoring-agent.exe") )
   {
      start -wait "C:\rs-pkgs\rackspace-monitoring-agent-x64.msi" -ArgumentList '/qn'
   }
}
function Get-TargetResource
{
   param
   (
      [Parameter(Mandatory)]
      [String] $Label,
      
      [Parameter(Mandatory)]
      [ValidateNotNullOrEmpty()]
      $Type,
      
      [System.String]
      $Disabled = "<NULL>",
      
      [System.String]
      $Period = "<NULL>",
      
      [System.String]
      $Timeout = "<NULL>",
      
      [System.String]
      $Target_Hostname = "<NULL>",
      
      [System.String]
      $Target = "<NULL>",
      
      [System.String]
      $Url = "<NULL>",
      
      [System.String]
      $UrlMethod = "<NULL>",
      
      [System.String[]]
      $Zones_Poll = $null,
      
      [System.String]
      $Alarm1_Label = "<NULL>",
      
      [System.String]
      $Alarm1_Plan_ID = "<NULL>",
      
      [System.String]
      $Alarm1_Criteria = "<NULL>",
      
      [System.String]
      $Alarm2_Label = "<NULL>",
      
      [System.String]
      $Alarm2_Plan_ID = "<NULL>",
      
      [System.String]
      $Alarm2_Criteria = "<NULL>",
      
      [System.String]
      $Monitoring_ID = $null,
      
      [System.String]
      $Monitoring_Token = $null,
      
      [Parameter(Mandatory = $true)]
      [ValidateSet("Present","Absent")]
      [System.String]
      $Ensure
   )
   
   if ( $Ensure -eq "Present" )
   {
      if ( Test-Path "C:\ProgramData\Rackspace Monitoring\config\rackspace-monitoring-agent.conf.d\$label.yaml" )
      {
         $content = Get-Content "C:\ProgramData\Rackspace Monitoring\config\rackspace-monitoring-agent.conf.d\$label.yaml"
      }
   }
   
   $returnvalue = @{
                        Type = [String](($content -match "Type") -split ": ")[1]
                        Label = [String](($content -match "Label") -split ": ")[1]
                        Disabled = [String](($content -match "Disabled") -split ": ")[1]
                        Period = [String](($content -match "Period") -split ": ")[1]
                        Timeout = [String](($content -match "Timeout") -split ": ")[1]
                        Target_Hostname = [String](($content -match "Target_Hostname") -split ": ")[1]
                        Target = [String](($content -match "Target") -split ": ")[1]
                        Url = [String](($content -match "Url") -split ": ")[1]
                        UrlMethod = [String](($content -match "Method") -split ": ")[1]
                        Zones_Poll = ([String](($content -match "- mz"))).TrimStart().Trim("- mz") -split " "
                        Alarm1_Label = (([String](($content -match "Label"))) -split "label : ")[2]
                        Alarm1_Plan_ID = (([String](($content -match "notification_plan_id :"))) -split "notification_plan_id :")[0]
                        Alarm1_Criteria = $Alarm1_Criteria
                        Alarm2_Label = (([String](($content -match "Label"))) -split "label : ")[3]
                        Alarm2_Plan_ID = (([String](($content -match "notification_plan_id :"))) -split "notification_plan_id :")[1]
                        Alarm2_Criteria  = $Alarm2_Criteria
                        Monitoring_ID = $Monitoring_ID
                        Monitoring_Token = $Monitoring_Token
                        Ensure = if(Test-Path "C:\ProgramData\Rackspace Monitoring\config\rackspace-monitoring-agent.conf.d\$label.yaml") {"Present"} else {"Absent"}
                    }
   
   $returnvalue
}

function Set-TargetResource
{
   param
   (
      [Parameter(Mandatory)]
      [String] $Label,
      
      [Parameter(Mandatory)]
      [ValidateNotNullOrEmpty()]
      [System.String]
      $Type,
      
      [System.String]
      $Disabled = "<NULL>",
      
      [System.String]
      $Period = "<NULL>",
      
      [System.String]
      $Timeout = "<NULL>",
      
      [System.String]
      $Target_Hostname = "<NULL>",
      
      [System.String]
      $Target = "<NULL>",
      
      [System.String]
      $Url = "<NULL>",
      
      [System.String]
      $UrlMethod = "<NULL>",
      
      [System.String[]]
      $Zones_Poll = $null,
      
      [System.String]
      $Alarm1_Label = "<NULL>",
      
      [System.String]
      $Alarm1_Plan_ID = "<NULL>",
      
      [System.String]
      $Alarm1_Criteria = "<NULL>",
      
      [System.String]
      $Alarm2_Label = "<NULL>",
      
      [System.String]
      $Alarm2_Plan_ID = "<NULL>",
      
      [System.String]
      $Alarm2_Criteria = "<NULL>",
      
      [System.String]
      $Monitoring_ID = $null,
      
      [System.String]
      $Monitoring_Token = $null,
      
      [Parameter(Mandatory = $true)]
      [ValidateSet("Present","Absent")]
      [System.String]
      $Ensure
   )
   
   if ( $Ensure -eq "Absent" )
   {
      if ( Test-Path "C:\ProgramData\Rackspace Monitoring\config\rackspace-monitoring-agent.conf.d\$label.yaml" )
      {
         Write-EventLog -LogName DevOps -Source RS_rsRaxMon -EntryType Information -EventId 1000 -Message ("Removing $label.yaml")
         Remove-Item -Path "C:\ProgramData\Rackspace Monitoring\config\rackspace-monitoring-agent.conf.d\$label.yaml"
         Write-EventLog -LogName DevOps -Source RS_rsRaxMon -EntryType Information -EventId 1000 -Message ("Restarting Rackspace Cloud Monitoring Agent")
         try {
            if ( (get-service "Rackspace Cloud Monitoring Agent").Status -eq 'Running' ) { Stop-service "Rackspace Cloud Monitoring Agent" }
         }
         catch {
            Write-EventLog -LogName DevOps -Source RS_rsRaxMon -EntryType Error -EventId 1000 -Message "Failed to Stop RackSpace Cloud Monitoring Agent `n $($_.Exception.Message)"
         }
         try {
            if ( (get-service "Rackspace Cloud Monitoring Agent").Status -ne 'Running' ) { Start-service "Rackspace Cloud Monitoring Agent" }
         }
         catch {
            Write-EventLog -LogName DevOps -Source RS_rsRaxMon -EntryType Error -EventId 1000 -Message "Failed to Start RackSpace Cloud Monitoring Agent `n $($_.Exception.Message)"
         }
         
      }
   }
   else
   {
      try {
         $MonitoringServiceStatus = Get-Service "Rackspace Cloud Monitoring Agent" -ErrorAction SilentlyContinue
      }
      catch {
         Write-EventLog -LogName DevOps -Source RS_rsRaxMon -EntryType Error -EventId 1000 -Message "Failed to get status of RackSpace Cloud Monitoring Service `n $($_.Exception.Message)"
      }
      if( -not $MonitoringServiceStatus)
      {
         if ( $Monitoring_ID -eq $null -or $Monitoring_Token -eq $null )
         {
            Write-Verbose "Need Monitoring_ID and Monitoring_Token to Install Rackspace Cloud Monitoring Agent"
            Write-EventLog -LogName DevOps -Source RS_rsRaxMon -EntryType Error -EventId 1000 -Message ("Need Monitoring_ID and Monitoring_Token to Install Rackspace Cloud Monitoring Agent")
            Throw "Need ID and Token to Install Agent"
         }
         else
         {
            Install-Agent
         }
      }
      if ( -not (Test-Path "C:\ProgramData\Rackspace Monitoring\Config\rackspace-monitoring-agent.cfg") )
      {
         Set-Content "C:\ProgramData\Rackspace Monitoring\Config\rackspace-monitoring-agent.cfg" -Value "Monitoring_ID `nMonitoring_Token"
      }
      if ( $Monitoring_ID -ne "" -and $Monitoring_Token -ne "" )
      {
         Write-Verbose "Creating test.cfg"
         $filecontent = "monitoring_token " + $Monitoring_Token
         $filecontent +=  [Environment]::NewLine + "monitoring_id " + $Monitoring_ID
         Set-Content "C:\ProgramData\Rackspace Monitoring\config\test.cfg" $filecontent
         
         if ( (Compare-Object (Get-Content "C:\ProgramData\Rackspace Monitoring\Config\test.cfg") (Get-Content "C:\ProgramData\Rackspace Monitoring\Config\rackspace-monitoring-agent.cfg") ).count -ne $null)
         {
            Write-Verbose "Updating Agent Config at C:\ProgramData\Rackspace Monitoring\Config\rackspace-monitoring-agent.cfg"
            Write-EventLog -LogName DevOps -Source RS_rsRaxMon -EntryType Information -EventId 1000 -Message ("Updating Agent Config at C:\ProgramData\Rackspace Monitoring\Config\rackspace-monitoring-agent.cfg")
            Set-Content "C:\ProgramData\Rackspace Monitoring\config\rackspace-monitoring-agent.cfg" $filecontent
            Write-Verbose "Restarting Rackspace Cloud Monitoring Agent"
            try {
               if ( (get-service "Rackspace Cloud Monitoring Agent").Status -eq 'Running' ) { Stop-service "Rackspace Cloud Monitoring Agent" }
            }
            catch {
               Write-EventLog -LogName DevOps -Source RS_rsRaxMon -EntryType Error -EventId 1000 -Message "Failed to Stop RackSpace Cloud Monitoring Agent `n $($_.Exception.Message)"
            }
            try {
               if ( (get-service "Rackspace Cloud Monitoring Agent").Status -ne 'Running' ) { Start-service "Rackspace Cloud Monitoring Agent" }
            }
            catch {
               Write-EventLog -LogName DevOps -Source RS_rsRaxMon -EntryType Error -EventId 1000 -Message "Failed to Start RackSpace Cloud Monitoring Agent `n $($_.Exception.Message)"
            }
         }
         
      }
      if( $zones_poll -ne $null )
      {
         $pollers = " "
         $pollers += $zones_poll | % { "`r`n               - mz$_"}
      }
      else { $pollers = "<NULL>" }
      $template = @"
type : $Type
label : $label
disabled : $disabled
period : $period
timeout : $timeout
target_hostname : $target_hostname
details : $(if($target -eq "<NULL>" -and $url -eq "<NULL>" -and $UrlMethod -eq "<NULL>") { "<NULL>" } )
    target : $target
    url : $url
    method: $UrlMethod
monitoring_zones_poll: $pollers
alarms : $(if($alarms1_label -eq "<NULL>" -and $alarm2_label -eq "<NULL>") { "<NULL>" } )
    alarm1 : $(if($alarm1_label -eq "<NULL>") { "<NULL>" } )
        label : $alarm1_label
        notification_plan_id : $alarm1_plan_id
        criteria : $alarm1_criteria
    alarm2 : $(if($alarm2_label -eq "<NULL>") { "<NULL>" } )
        label : $alarm2_label
        notification_plan_id : $alarm2_plan_id
        criteria : $alarm2_criteria
"@ -split [Environment]::NewLine
      
      $template = $template -notmatch "<NULL>"
      Write-EventLog -LogName DevOps -Source RS_rsRaxMon -EntryType Information -EventId 1000 -Message ("Creating $label.yaml")
      Set-Content -Path "C:\ProgramData\Rackspace Monitoring\config\rackspace-monitoring-agent.conf.d\$label.yaml" -Value $template
      
      Write-EventLog -LogName DevOps -Source RS_rsRaxMon -EntryType Information -EventId 1000 -Message ("Restarting Rackspace Cloud Monitoring Agent")
      try {
         if ( (get-service "Rackspace Cloud Monitoring Agent").Status -eq 'Running' ) { Stop-service "Rackspace Cloud Monitoring Agent" }
      }
      catch {
         Write-EventLog -LogName DevOps -Source RS_rsRaxMon -EntryType Error -EventId 1000 -Message "Failed to Stop RackSpace Cloud Monitoring Agent `n $($_.Exception.Message)"
      }
      try {
         if ( (get-service "Rackspace Cloud Monitoring Agent").Status -ne 'Running' ) { Start-service "Rackspace Cloud Monitoring Agent" }
      }
      catch {
         Write-EventLog -LogName DevOps -Source RS_rsRaxMon -EntryType Error -EventId 1000 -Message "Failed to Start RackSpace Cloud Monitoring Agent `n $($_.Exception.Message)"
      }
      
      Start-Sleep -Seconds "10"
      $errors = $null
      $logs = Get-Content -Path "C:\ProgramData\Rackspace Monitoring\log.txt" -Tail 150
      foreach( $log in $logs)
      {
         $logdate = $log.Remove($log.IndexOf( "$((Get-Date).Year)" ) + 4 )
         $logdate = [datetime]::ParseExact($logdate,"ddd MMM dd HH:mm:ss yyyy",$null)
         if ( $logdate -gt (Get-Date).AddSeconds(-5) )
         {
            if ( ($log -match "failure") )
            {
               $errors += $log + [Environment]::NewLine
            }
         }
      }
      if ( $errors -ne $null )
      {
         Write-Verbose "Error: Malformed $label.yaml"
         Write-Debug "$errors"
         Write-EventLog -LogName DevOps -Source RS_rsRaxMon -EntryType Error -EventId 1000 -Message ("Malformed YAML for $label.yaml: $errors `r`nFor complete logs check: C:\ProgramData\Rackspace Monitoring\log.txt")
      }
      else
      {
         Write-Verbose "Success for Monitoring: $label"
         Write-EventLog -LogName DevOps -Source RS_rsRaxMon -EntryType Information -EventId 1000 -Message ("Success adding $label Check")
      }
      
   }
}

function Test-TargetResource
{
   param
   (
      [Parameter(Mandatory)]
      [String] $Label,
      
      [Parameter(Mandatory)]
      [ValidateNotNullOrEmpty()]
      $Type,
      
      [System.String]
      $Disabled = "<NULL>",
      
      [System.String]
      $Period = "<NULL>",
      
      [System.String]
      $Timeout = "<NULL>",
      
      [System.String]
      $Target_Hostname = "<NULL>",
      
      [System.String]
      $Target = "<NULL>",
      
      [System.String]
      $Url = "<NULL>",
      
      [System.String]
      $UrlMethod = "<NULL>",
      
      [System.String[]]
      $Zones_Poll = $null,
      
      [System.String]
      $Alarm1_Label = "<NULL>",
      
      [System.String]
      $Alarm1_Plan_ID = "<NULL>",
      
      [System.String]
      $Alarm1_Criteria = "<NULL>",
      
      [System.String]
      $Alarm2_Label = "<NULL>",
      
      [System.String]
      $Alarm2_Plan_ID = "<NULL>",
      
      [System.String]
      $Alarm2_Criteria = "<NULL>",
      
      [System.String]
      $Monitoring_ID = $null,
      
      [System.String]
      $Monitoring_Token = $null,
      
      [Parameter(Mandatory = $true)]
      [ValidateSet("Present","Absent")]
      [System.String]
      $Ensure
   )
   
   $testresult = $true
   try {
      $MonitoringServiceStatus = Get-Service "Rackspace Cloud Monitoring Agent" -ErrorAction SilentlyContinue
   }
   catch {
      Write-EventLog -LogName DevOps -Source RS_rsRaxMon -EntryType Error -EventId 1000 -Message "Failed to get status of RackSpace Cloud Monitoring Service `n $($_.Exception.Message)"
   }
   if( -not $MonitoringServiceStatus)
   {
      if ( $Monitoring_ID -eq $null -or $Monitoring_Token -eq $null )
      {
         Write-Verbose "Need Monitoring_ID and Monitoring_Token to Install Rackspace Cloud Monitoring Agent"
         Write-EventLog -LogName DevOps -Source RS_rsRaxMon -EntryType Error -EventId 1000 -Message ("Need Monitoring_ID and Monitoring_Token to Install Rackspace Cloud Monitoring Agent")
         Throw "Need ID and Token to Install Agent"
      }
      return $false
   }
   if ( -not (Test-Path "C:\ProgramData\Rackspace Monitoring\Config\rackspace-monitoring-agent.cfg") )
   {
      return $false
   }
   if ( $Ensure -eq "Absent" )
   {
      if ( Test-Path "C:\ProgramData\Rackspace Monitoring\config\rackspace-monitoring-agent.conf.d\$label.yaml" )
      {
         Write-Verbose "Need to Delete $label.yaml"
         return $false
      }
   }
   else
   {
      if ( $Monitoring_ID -ne "" -and $Monitoring_Token -ne "" )
      {
         $filecontent = "monitoring_token " + $Monitoring_Token
         $filecontent +=  [Environment]::NewLine + "monitoring_id " + $Monitoring_ID
         Set-Content "C:\ProgramData\Rackspace Monitoring\config\test.cfg" $filecontent
         
         if ( (Compare-Object (Get-Content "C:\ProgramData\Rackspace Monitoring\Config\test.cfg") (Get-Content "C:\ProgramData\Rackspace Monitoring\Config\rackspace-monitoring-agent.cfg") ).count -ne 0)
         {
            Write-Verbose "Need to Update .cfg file"
            $testresult = $false
         }
         
      }
      if ( -not (Test-Path "C:\ProgramData\Rackspace Monitoring\config\rackspace-monitoring-agent.conf.d\$label.yaml") )
      {
         Write-Verbose "Need to Create YAML"
         return $false
      }
      if( $zones_poll -ne $null )
      {
         $pollers = " "
         $pollers += $zones_poll | % { "`r`n               - mz$_"}
      }
      else { $pollers = "<NULL>" }
      
      $template = @"
type : $Type
label : $label
disabled : $disabled
period : $period
timeout : $timeout
target_hostname : $target_hostname
details : $(if($target -eq "<NULL>" -and $url -eq "<NULL>" -and $UrlMethod -eq "<NULL>") { "<NULL>" } )
    target : $target
    url : $url
    method: $UrlMethod
monitoring_zones_poll: $pollers
alarms : $(if($alarms1_label -eq "<NULL>" -and $alarm2_label -eq "<NULL>") { "<NULL>" } )
    alarm1 : $(if($alarm1_label -eq "<NULL>") { "<NULL>" } )
        label : $alarm1_label
        notification_plan_id : $alarm1_plan_id
        criteria : $alarm1_criteria
    alarm2 : $(if($alarm2_label -eq "<NULL>") { "<NULL>" } )
        label : $alarm2_label
        notification_plan_id : $alarm2_plan_id
        criteria : $alarm2_criteria
"@ -split [Environment]::NewLine
      foreach ( $line in $template )
      {
         $linetrim = $line.Trim()
      }
      
      foreach ( $line in $template )
      {
         if ($line -notlike "*<NULL>*")
         {
            $templateyaml += $line + "`r`n"
         }
      }
      Write-Verbose "Creating test.yaml"
      Set-Content "C:\ProgramData\Rackspace Monitoring\Config\test.yaml" $templateyaml
      
      if ( (Compare-Object (Get-Content "C:\ProgramData\Rackspace Monitoring\Config\test.yaml") (Get-Content "C:\ProgramData\Rackspace Monitoring\config\rackspace-monitoring-agent.conf.d\$label.yaml") ).count -ne $null)
      {
         $testresult = $false
         Write-Verbose "Need to Update YAML"
      }
      
   }
   $testresult
}
Export-ModuleMember -Function *-TargetResource