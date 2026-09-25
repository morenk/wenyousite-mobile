param([Parameter(Mandatory = $true)][string]$Name)
$ErrorActionPreference = 'Stop'
$mutex = [System.Threading.Mutex]::new($false, $Name)
$owned = $false
try {
  try { $owned = $mutex.WaitOne(30000) }
  catch [System.Threading.AbandonedMutexException] { $owned = $true }
  if (-not $owned) { throw 'Lifecycle lock timeout' }
  [Console]::Out.WriteLine('READY')
  [Console]::Out.Flush()
  # Node 退出时 pipe EOF 释放系统互斥；无 PID 文件的删除竞态。
  [void][Console]::In.ReadLine()
} finally {
  if ($owned) { $mutex.ReleaseMutex() }
  $mutex.Dispose()
}
