#!/usr/bin/php
<?php

// get average load
$aLoadAVG = explode(' ', file_get_contents('/proc/loadavg'));
$aLoadAVG = array(
    '1'     => $aLoadAVG[0],
    '5'     => $aLoadAVG[1],
    '15'    => $aLoadAVG[2],
);

// get sum of up/download of eth0
preg_match_all('/(^|\s+)(.*?)\s+Link.*?RX bytes:.*?\((.*?)\)\s+TX bytes:.*?\((.*?)\)/s', shell_exec('/sbin/ifconfig'), $aNetworkTraffic);

// get up / idle time
$aUpIdleTime = explode(' ', file_get_contents('/proc/uptime'));
$sUpTime = $sIdleTime = '';
foreach($aUpIdleTime as $iKey => $sUpIdle)
{
    $iSeconds = (int)$sUpIdle;

    switch($iKey)
    {   
        // uptime
        case 0:
        {
            $sUpTime .= '# Up since ' . date('Y-m-d H:i:s', time() - $iSeconds);
            break;
        }
        
        // idletime
        case 1:
        {
            // vois right now
            break;
        }
    }
}

$sNetworkTraffic = '';
if(!empty($aNetworkTraffic) && is_array($aNetworkTraffic) && isset($aNetworkTraffic[2]))
{
    foreach($aNetworkTraffic[2] as $iKey => $sNetworkName)
    {
        if($iKey > 0)
        {
            $sNetworkTraffic .= "\n";
        }
        $sNetworkTraffic .= '# Traffic "' . sprintf("%-10s", $sNetworkName . '"') . ' Down@ ' . sprintf("%-10s", $aNetworkTraffic[3][$iKey]) . ' Up@ ' . sprintf("%-14s", $aNetworkTraffic[4][$iKey]);
    }
}

// get disk usage
$aDiskUsageShow = array(
    '/^rootfs/',
    '/^\/dev\/sd/'
);
$aDiskUsage = explode("\n", shell_exec('df -h'));
$aDiskUsageLines = array();
foreach($aDiskUsage as $iKey => $sLine)
{
    if($iKey == 0)
    {
        $aDiskUsageLines[] = '# ' . $sLine;
        continue;
    }

    foreach($aDiskUsageShow as $sRegex)
    {
        if(preg_match($sRegex, $sLine) === 1)
        {
            $aDiskUsageLines[] = '# ' . $sLine;
        }
    }
}

// get kernel
$sKernel = trim(file_get_contents('/proc/sys/kernel/osrelease'));

// get hostname
$sHostname = trim(file_get_contents('/etc/hostname'));

// create motd
$sMotd = "
# Welcome on " . $sHostname . " ! (Kernel: " . $sKernel . ")
#
" . $sUpTime . "
#
# Average Load: " . $aLoadAVG[1] . " " . $aLoadAVG[5] . " " . $aLoadAVG[15] . "
#
" . $sNetworkTraffic . "
#
" . implode("\n", $aDiskUsageLines) . "
#
";

#echo $sMotd;
file_put_contents('/etc/motd', $sMotd);
