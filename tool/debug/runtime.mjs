import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

export const hash = value => createHash('sha256').update(value).digest('hex');
export function run(file, args, options = {}) {
  return execFileSync(file, args, { encoding: 'utf8', windowsHide: true, timeout: 30_000, stdio: ['ignore', 'pipe', 'pipe'], ...options }).trim();
}
export function privateDirectory(directory) {
  fs.mkdirSync(directory, { recursive: true, mode: 0o700 });
  if (process.platform === 'win32') {
    // 已符合完整私有 ACL 时不重复 Set-Acl，避免重复启动触发 SeSecurityPrivilege。
    // 所有权、规则身份、权限和继承必须逐项相等；不能仅凭规则条数复用。
    const literal = `'${directory.replaceAll("'", "''")}'`;
    run('pwsh.exe', ['-NoProfile', '-NonInteractive', '-Command', `$ErrorActionPreference='Stop'; $sid=[System.Security.Principal.WindowsIdentity]::GetCurrent().User; $current=Get-Acl -LiteralPath ${literal}; $rules=@($current.GetAccessRules($true,$true,[System.Security.Principal.SecurityIdentifier])); $valid=$current.AreAccessRulesProtected -and $current.GetOwner([System.Security.Principal.SecurityIdentifier]).Value -eq $sid.Value -and $rules.Count -eq 2; foreach($rule in $rules) { $valid=$valid -and $rule.IdentityReference.Value -in @($sid.Value,'S-1-5-18') -and $rule.AccessControlType -eq 'Allow' -and $rule.FileSystemRights -eq 'FullControl' -and $rule.InheritanceFlags -eq 'ContainerInherit, ObjectInherit' -and $rule.PropagationFlags -eq 'None' -and !$rule.IsInherited }; if($valid -and @($rules.IdentityReference.Value | Select-Object -Unique).Count -eq 2) { exit 0 }; $acl=New-Object System.Security.AccessControl.DirectorySecurity; $acl.SetOwner($sid); $acl.SetAccessRuleProtection($true,$false); foreach($identity in @($sid,(New-Object System.Security.Principal.SecurityIdentifier('S-1-5-18')))) { $rule=New-Object System.Security.AccessControl.FileSystemAccessRule($identity,'FullControl','ContainerInherit,ObjectInherit','None','Allow'); $acl.AddAccessRule($rule) }; Set-Acl -LiteralPath ${literal} -AclObject $acl`]);
  } else fs.chmodSync(directory, 0o700);
}
export function flutterCommand() {
  let discovered;
  try { discovered = path.dirname(path.dirname(run('pwsh.exe', ['-NoProfile', '-NonInteractive', '-Command', '(Get-Command flutter -CommandType Application -ErrorAction Stop).Source']))); } catch {}
  const roots = [process.env.FLUTTER_ROOT, discovered, 'D:\\sdk\\flutter'].filter(Boolean);
  const root = roots.find(value => fs.existsSync(path.join(value, 'bin', 'cache', 'flutter_tools.snapshot')));
  if (!root) throw new Error('找不到 Flutter SDK；请设置 FLUTTER_ROOT 并先运行 flutter doctor。');
  // 直接启动 SDK dart 可可靠保存 PID，避免 .bat/cmd 子进程遗留。
  return { file: path.join(root, 'bin', 'cache', 'dart-sdk', 'bin', 'dart.exe'), prefix: [path.join(root, 'bin', 'cache', 'flutter_tools.snapshot')] };
}
