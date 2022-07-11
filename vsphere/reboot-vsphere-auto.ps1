# Reboot ESXi Server Function
Function RebootHost ($CurrentServer) {
    # Get VI-Server name
    $ServerName = $CurrentServer.Name
    ## $CurrentCluster = Get-Cluster -VMHost $CurrentServer
    
    # Put server in maintenance mode
    # Cmdlet shows a status bar so we don't have to iterate much
    Write-Host "$CurrentServer entering maintenance mode..." -ForegroundColor White -NoNewline
    Set-VMhost $CurrentServer -State Maintenance -Evacuate -VsanDataMigrationMode EnsureAccessibility -ErrorAction Stop | Out-Null
    
    do {
        $ServerState = (get-vmhost $ServerName).ConnectionState
        Write-Host "." -ForegroundColor White -NoNewline
        Start-Sleep 5
    }
    while ($ServerState -ne "Maintenance")
    Write-Host " done." -ForegroundColor Green
    
    # Reboot host
    Write-Host "$CurrentServer shutting down to restart..." -ForegroundColor White -NoNewline 
    Restart-VMHost $CurrentServer -confirm:$false -ErrorAction Stop | Out-Null
    
    do {
        Start-Sleep 5
        $ServerState = (get-vmhost $ServerName).ConnectionState
        Write-Host "." -ForegroundColor White -NoNewline
    }
    while ($ServerState -ne "NotResponding")
    Write-Host " done." -ForegroundColor Green
    
    # Wait for server to reboot
    Start-Sleep 5
    Write-Host "$CurrentServer waiting for restart..." -ForegroundColor White -NoNewline
    
    do {
        Start-Sleep 5
        $ServerState = (get-vmhost $ServerName).ConnectionState
        Write-Host "." -ForegroundColor White -NoNewline
    } while ($ServerState -ne "Maintenance")
    Write-Host " done." -ForegroundColor Green
    
    # Check vSAN Health
    # I cannot get this to work, just gonna sleep for a bit instead. I'm open to suggestions (I've done very little troubleshooting of this, tbh)
    
    #Start-Sleep 5
    #Write-Host "$CurrentServer pausing for vSAN stabilization..." -ForegroundColor White -NoNewline
    #do {
    #    Write-Host "." -ForegroundColor White -NoNewline
    #    Start-Sleep 10
    #} while ((Test-VsanClusterHealth -Cluster $CurrentCluster).HealthSystemVersion.IssueFound -ne "False")
    #Write-Host " done." -ForegroundColor Green
    
    
    #if ((Test-VsanClusterHealth -Cluster "VRTX").HealthSystemVersion.IssueFound -ne "False") {
    #    Write-Host " failed health check, aborting." -ForegroundColor Red
    #    Exit
    #} else {
    #    WRite-Host " done." -ForegroundColor Green
    #}
    
    # Exit maintenance mode

    # Cmdlet shows a status bar so we don't have to iterate much
    Start-Sleep 5
    Write-Host "$CurrentServer exiting maintenance mode...." -ForegroundColor White -NoNewline
    Set-VMhost $CurrentServer -State Connected -ErrorAction Stop | Out-Null
    do {
        $ServerState = (get-vmhost $ServerName).ConnectionState
        Write-Host "." -ForegroundColor White -NoNewline
        Start-Sleep 5
    } while ($ServerState -ne "Connected")
    Write-Host " done." -ForegroundColor Green
    
    Write-Host "$CurrentServer pausing for cluster stabilization..." -ForegroundColor White -NoNewline
    Start-Sleep 15
    Write-Host " done." -ForegroundColor Green
    Write-Host "$CurrentServer reboot complete." -ForegroundColor Green
    Write-Host ""
    }
    
    Write-Host "VMware vSphere Cluster Rolling Reboot Utility v1.0`n" -ForegroundColor Gray

    Write-Host "THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ""AS IS"" AND ANY EXPRESS OR" -ForegroundColor Yellow
    Write-Host "IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND" -ForegroundColor Yellow
    Write-Host "FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR" -ForegroundColor Yellow
    Write-Host "CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL" -ForegroundColor Yellow
    Write-Host "DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE," -ForegroundColor Yellow
    Write-Host "DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER" -ForegroundColor Yellow
    Write-Host "IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT" -ForegroundColor Yellow
    Write-Host "OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE." -ForegroundColor Yellow
    Write-Host ""

    Start-Sleep -Seconds 10
    
    if ($global:DefaultVIServers.Count -lt 1) {
        Write-Host "You need to be connected to a vCenter Server. Aborting." -ForegroundColor Red
        Exit
    }
    
    # Build a list of clusters
    $Hosts = Get-Cluster | Get-VMHost
    
    # Ignore hosts that are in a cluster without DRS enabled
    foreach ($ESXi in $Hosts) {
        $Cluster = Get-Cluster -VMHost $ESXi
        if ($ESXi.ConnectionState -ne "Connected") {
            Write-Host "$ESXi cannot be restarted by this script, host not in correct connection state. Skipping." -ForegroundColor Yellow
        } elseif ($Cluster.DrsEnabled -ne "True") {
            Write-Host "$ESXi cannot be restarted by this script, DRS not enabled in cluster. Skipping." -ForegroundColor Yellow
        } else {
            $CHosts = Get-Cluster -VMHost $ESXi | Get-VMHost
            if ($CHosts.count -lt 2) {
                Write-Host "$ESXi cannot be restarted by this script, DRS enabled but only one host in cluster. Skipping." -ForegroundColor Yellow
            } else {
                Write-Host "$ESXi beginning restart process..." -ForegroundColor Cyan
                RebootHost($ESXi)
            }
        }
    }
    
    