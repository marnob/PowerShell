function update-ccm {
    $CompName = "." # . is the local computer. Enter a computername.
    $actions = (
        '{00000000-0000-0000-0000-000000000121}',
        '{00000000-0000-0000-0000-000000000003}',
        '{00000000-0000-0000-0000-000000000001}',
        '{00000000-0000-0000-0000-000000000021}',
        '{00000000-0000-0000-0000-000000000002}',
        '{00000000-0000-0000-0000-000000000031}',
        '{00000000-0000-0000-0000-000000000108}',
        '{00000000-0000-0000-0000-000000000113}',
        '{00000000-0000-0000-0000-000000000032}')
    foreach ($action in $actions) {
        $WMIPath = "\\" + $CompName + "\root\ccm:SMS_Client" 
        $SMSwmi = [wmiclass] $WMIPath 
        [Void]$SMSwmi.TriggerSchedule($action)
    }
}
update-ccm
