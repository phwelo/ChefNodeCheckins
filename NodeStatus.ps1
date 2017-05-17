Class Node{
    [DateTime]$LastCheckin
    [String]$NodeName
    [Version]$Version
}

function Get-LastCheckin {
    $NodeLines = knife status -r
    $NodeContainer = @()
    foreach($Line in $NodeLines){
        $CurrentNode = New-Object Node
        $SplittedLine = $Line.split(' ') | where {$_}
        $TimeSpan = Get-Date
        if($SplittedLine[1] -like "hours"){
            $CurrentNode.LastCheckin = $TimeSpan.AddHours(-$SplittedLine[0])
            $CurrentNode.NodeName = $SplittedLine[3]
        } elseif ($SplittedLine[1] -like "minute*"){
            $CurrentNode.LastCheckin = $TimeSpan.AddMinutes(-$SplittedLine[0])
        } else {
            throw 'Could not figure out if minutes or hours'
        }
        $CurrentNode.NodeName = $SplittedLine[3].TrimEnd(',')
        Try {
            $CurrentNode.Version = $SplittedLine[-1].TrimEnd('.')
        } Catch {
            $CurrentNode.Version = 0.0.0
        }
        $NodeContainer += $CurrentNode
    }
    return $NodeContainer
}

# Get nodes who checked in more than a day ago
$DayAgo = (Get-Date).addDays(-1)
Get-LastCheckin | where-object{$_.LastCheckin -lt $DayAgo}
