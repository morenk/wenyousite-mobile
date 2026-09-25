using System;
using System.IO;
using System.Diagnostics;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;

// Flutter installApp 会在 install -r 失败后卸载旧包；持续预览必须保留本机数据。
public static class WenyouAdbGuard {
  static string Quote(string value) {
    var result=new StringBuilder("\""); int slashes=0;
    foreach(char c in value) {
      if(c=='\\') { slashes++; continue; }
      if(c=='\"') { result.Append('\\',slashes*2+1); result.Append(c); slashes=0; continue; }
      result.Append('\\',slashes); slashes=0; result.Append(c);
    }
    result.Append('\\',slashes*2); return result.Append('"').ToString();
  }
  public static int Main(string[] args) {
    File.WriteAllText(Path.Combine(AppDomain.CurrentDomain.BaseDirectory,"adb-guard-used"),DateTime.UtcNow.ToString("O"));
    foreach(var arg in args) {
      if(Regex.IsMatch(arg,@"(^|[\s;])(uninstall(?:-multiple)?|clear)([\s;]|$)",RegexOptions.IgnoreCase)) {
        Console.Error.WriteLine("Preview ADB refuses uninstall/clear; existing app data is preserved.");
        return 73;
      }
    }
    try {
      var target=File.ReadAllText(Path.Combine(AppDomain.CurrentDomain.BaseDirectory,"adb-target.txt")).Trim();
      if(!Path.IsPathRooted(target) || !File.Exists(target)) return 74;
      var command=new StringBuilder(); foreach(var arg in args) { if(command.Length>0) command.Append(' '); command.Append(Quote(arg)); }
      var info=new ProcessStartInfo(target,command.ToString());
      info.UseShellExecute=false; info.CreateNoWindow=true;
      info.RedirectStandardInput=true; info.RedirectStandardOutput=true; info.RedirectStandardError=true;
      using(var child=Process.Start(info)) {
        // .NET Framework 默认句柄继承不能可靠保留匿名 stdin pipe，显式按字节转发。
        var input=new Thread(delegate() { try { Console.OpenStandardInput().CopyTo(child.StandardInput.BaseStream); child.StandardInput.Close(); } catch {} }); input.IsBackground=true; input.Start();
        var error=new Thread(delegate() { child.StandardError.BaseStream.CopyTo(Console.OpenStandardError()); }); error.IsBackground=true; error.Start();
        child.StandardOutput.BaseStream.CopyTo(Console.OpenStandardOutput());
        child.WaitForExit(); error.Join(); return child.ExitCode;
      }
    } catch { Console.Error.WriteLine("Preview ADB target is unavailable."); return 74; }
  }
}
