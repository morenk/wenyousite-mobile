param(
  [Parameter(Mandatory = $true)][string]$Executable,
  [Parameter(Mandatory = $true)][string]$ArgumentsBase64,
  [Parameter(Mandatory = $true)][int]$OwnerPid,
  [Parameter(Mandatory = $true)][string]$OwnerStarted
)
$ErrorActionPreference = 'Stop'
Add-Type -TypeDefinition @'
using System;
using System.Text;
using System.Runtime.InteropServices;
public static class WenyouJob {
  [StructLayout(LayoutKind.Sequential)] struct IO_COUNTERS { public ulong a,b,c,d,e,f; }
  [StructLayout(LayoutKind.Sequential)] struct BASIC_LIMITS { public long a,b; public uint flags; public UIntPtr min,max; public uint count; public UIntPtr affinity; public uint priority,scheduling; }
  [StructLayout(LayoutKind.Sequential)] struct EXTENDED_LIMITS { public BASIC_LIMITS basic; public IO_COUNTERS io; public UIntPtr processMemory,jobMemory,peakProcess,peakJob; }
  [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)] struct STARTUPINFO { public int cb; public string reserved,desktop,title; public int x,y,dx,dy,cx,cy,fill,flags; public short show,cbReserved; public IntPtr reserved2,input,output,error; }
  [StructLayout(LayoutKind.Sequential)] struct PROCESS_INFORMATION { public IntPtr process,thread; public uint pid,tid; }
  [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern IntPtr CreateJobObject(IntPtr attrs,string name);
  [DllImport("kernel32.dll", SetLastError=true)] static extern bool SetInformationJobObject(IntPtr job,int cls,ref EXTENDED_LIMITS limits,uint length);
  [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern bool CreateProcess(string app,StringBuilder command,IntPtr pa,IntPtr ta,bool inherit,uint flags,IntPtr env,string cwd,ref STARTUPINFO si,out PROCESS_INFORMATION pi);
  [DllImport("kernel32.dll", SetLastError=true)] static extern bool AssignProcessToJobObject(IntPtr job,IntPtr process);
  [DllImport("kernel32.dll")] static extern uint ResumeThread(IntPtr thread);
  [DllImport("kernel32.dll")] static extern uint WaitForSingleObject(IntPtr handle,uint timeout);
  [DllImport("kernel32.dll")] static extern uint WaitForMultipleObjects(uint count,IntPtr[] handles,bool all,uint timeout);
  [DllImport("kernel32.dll")] static extern bool GetExitCodeProcess(IntPtr process,out uint code);
  [DllImport("kernel32.dll")] static extern bool TerminateProcess(IntPtr process,uint code);
  [DllImport("kernel32.dll")] static extern IntPtr GetStdHandle(int kind);
  [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr handle);
  static string Quote(string value) {
    var result = new StringBuilder("\""); int slashes=0;
    foreach(char c in value) {
      if(c=='\\') { slashes++; continue; }
      if(c=='\"') { result.Append('\\',slashes*2+1); result.Append(c); slashes=0; continue; }
      result.Append('\\',slashes); slashes=0; result.Append(c);
    }
    result.Append('\\',slashes*2); return result.Append('"').ToString();
  }
  public static int Run(string executable,string[] arguments,int ownerPid,string ownerStarted) {
    using(var owner=System.Diagnostics.Process.GetProcessById(ownerPid)) {
    // 先绑定实际父进程句柄，避免登记子进程前 daemon 异常退出留下孤儿。
    var ownerHandle=owner.Handle;
    if(owner.StartTime.ToUniversalTime().Ticks.ToString()!=ownerStarted || owner.HasExited) throw new Exception("Process owner changed");
    IntPtr job=CreateJobObject(IntPtr.Zero,null); if(job==IntPtr.Zero) throw new Exception("Cannot create process job");
    PROCESS_INFORMATION pi=new PROCESS_INFORMATION();
    try {
      var limits=new EXTENDED_LIMITS(); limits.basic.flags=0x2000; // KILL_ON_JOB_CLOSE
      if(!SetInformationJobObject(job,9,ref limits,(uint)Marshal.SizeOf(limits))) throw new Exception("Cannot protect process job");
      var si=new STARTUPINFO(); si.cb=Marshal.SizeOf(si); si.flags=0x100; si.input=GetStdHandle(-10); si.output=GetStdHandle(-11); si.error=GetStdHandle(-12);
      var command=new StringBuilder(Quote(executable)); foreach(var arg in arguments) command.Append(' ').Append(Quote(arg));
      // 挂起创建后先归属 Job，再运行；编译后代没有逃逸窗口。
      if(!CreateProcess(executable,command,IntPtr.Zero,IntPtr.Zero,true,0x08000004,IntPtr.Zero,null,ref si,out pi)) throw new Exception("Cannot start protected process");
      if(!AssignProcessToJobObject(job,pi.process)) { TerminateProcess(pi.process,1); throw new Exception("Cannot assign protected process"); }
      if(ResumeThread(pi.thread)==0xffffffff) { TerminateProcess(pi.process,1); throw new Exception("Cannot resume protected process"); }
      var ended=WaitForMultipleObjects(2,new IntPtr[]{pi.process,ownerHandle},false,0xffffffff);
      if(ended!=0) return 1;
      uint code; GetExitCodeProcess(pi.process,out code); return unchecked((int)code);
    } finally {
      // 根进程先退出或 wrapper 被强杀，最后 Job handle 关闭会回收全部后代。
      CloseHandle(job); if(pi.thread!=IntPtr.Zero) CloseHandle(pi.thread); if(pi.process!=IntPtr.Zero) CloseHandle(pi.process);
    }
    }
  }
}
'@
$argumentList = [string[]]([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($ArgumentsBase64)) | ConvertFrom-Json)
exit [WenyouJob]::Run($Executable, $argumentList, $OwnerPid, $OwnerStarted)
