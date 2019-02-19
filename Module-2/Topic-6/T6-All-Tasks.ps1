# ST_DevOps2_2019_Viktar_Tsybulko_2_6
# 
#1.1.	Вывести все IP адреса вашего компьютера (всех сетевых интерфейсов)

# полуичить все включенные сетевые адаптеры
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName .
# добавим вывод IP адресов
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . `
    | Select-Object -Property IPAddress
# или можно с адресами без скобок (все IP адреса из массива адресов)
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . `
    | Select-Object -ExpandProperty IPAddress


# 1.2.	Получить mac-адреса всех сетевых устройств вашего компьютера и удалённо.
# найдем свойство, отвечающее за mac-адреса
Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Get-Member

Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . `
    | Select-Object -Property IPAddress, MACAddress | Format-Table

# для удаленного просмотра mac-адресов
$myPassport = Get-Credential Administrator
$vms = @("169.254.56.25", "169.254.97.95", "169.254.186.90")

# через WMI
foreach ($vm in $vms) {
    Write-Output ("IP's and MAC's $vm :")
    Get-WmiObject Win32_NetworkAdapterConfiguration -Credential $myPassport `
        -Filter IPEnabled=TRUE -ComputerName $vm `
        | Select-Object -Property IPAddress, MACAddress | Format-Table
}
# Success!
# результат работы в ST_DevOps2_2019_Viktar_Tsybulko_2_6.docx

# или через PS-remoting rev.1
$myScript = {
    Get-WmiObject Win32_OperatingSystem | ForEach-Object {
        Write-Output ("This is host " + $_.CSName + ":")
    }
    Get-WmiObject Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE `
        | Select-Object -Property IPAddress, MACAddress | Format-Table
}
Invoke-Command -ScriptBlock $myScript -ComputerName $vms
# Success!
# результат работы в ST_DevOps2_2019_Viktar_Tsybulko_2_6.docx

# или через PS-remoting rev.2 (так возможно будет лучше, т.к. имя компа указано четко)
$myScript = {
    $VMName = (Get-WmiObject Win32_OperatingSystem).CSName
    Write-Output ("This is host " + $VMName + ":")
    Get-WmiObject Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName $VMName `
        | Select-Object -Property IPAddress, MACAddress | Format-Table
}
Invoke-Command -ScriptBlock $myScript -ComputerName $vms


# 1.3.	На всех виртуальных компьютерах настроить (удалённо) получение адресов с DHСP.
# (предварительно раздадим машинам статические IP)

$vms1 = @("vm1", "vm2", "vm3")

$myScript_EnableDHCP = {
    $VMName = (Get-WmiObject Win32_OperatingSystem).CSName
    $nics = Get-WmiObject Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName $VMName    
    #Write-Output $nic
    foreach ($nic in $nics) {
        $r = $nic.EnableDHCP()        
        #Write-Output $r
        if ($r -eq "0") {
            Write-Output ("DHCP succsessfully enabled on host " + $VMName + "!")
        }
        else {
            Write-Output ("Ups... Something is wrong on host " + $VMName + "!")
        }
    }
    # работает.
    # попытка отловить результат операции пока не удалась, хотя написано, что EnableDHCP() должна вернуть значение
    # https://docs.microsoft.com/en-us/windows/desktop/cimwin32prov/enabledhcp-method-in-class-win32-networkadapterconfiguration
}
#Invoke-Command -ScriptBlock $myScript_EnableDHCP -ComputerName "VM1"
Invoke-Command -ScriptBlock $myScript_EnableDHCP -ComputerName $vms1


# 1.4.	Расшарить папку на компьютере
# (Нужны админ-права!)

$sharepath = "C:\temp"
if (Test-Path($sharepath)) {    
    $share = Get-WmiObject -List -ComputerName . | Where-Object -FilterScript {$_.Name –eq "Win32_Share"}
    $result = $share.InvokeMethod("Create", ($sharepath, "Testing", 0, 25, "What you are looking for?"))
    if ($result -eq 0 ) {
        Write-Output "Share Created!"    
    }
    else {
        Write-Output "Share not Created!"
    }
}
else {
    Write-Output "Folder not exist!"
}

# 1.5.	Удалить шару из п.1.4
# не промазать с названием и тоже дать админ-права

$result = (Get-WmiObject -Class Win32_Share -ComputerName . -Filter "Name='Testing'").InvokeMethod("Delete", $null)
if ($result -eq 0 ) {
    Write-Output "Share Delete!"    
}
else {
    Write-Output "Share not Deleted!"
}

# 1.6 in progress.... breaking my teeth...


# 2.1.	Получить список коммандлетов работы с Hyper-V (Module Hyper-V)

Get-Command -Module Hyper-V




