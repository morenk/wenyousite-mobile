// 环境暂不可用时保留 Flutter 页面；设备或本任务传输失联才结束会话。
export async function inspectSessionHealth({ verifyDevice, verifyOwnedTunnel, verifyEnvironment }) {
  try { await verifyDevice(); await verifyOwnedTunnel(); }
  catch { return 'disconnected'; }
  try { await verifyEnvironment(); return 'available'; }
  catch { return 'unavailable'; }
}

export function applyAvailability(state, available, machineReady) {
  const status = available ? (machineReady ? 'ready' : 'starting') : 'unavailable';
  const changed = state.status !== status;
  state.status = status;
  state.failure = available ? undefined : '预览资源暂不可用；已阻止请求，保留当前页面，等待身份重新核验。';
  return changed;
}
