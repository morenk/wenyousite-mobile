"""只读聚合既有 Worker 日志；仅输出时间与数值，不输出媒体标识或请求内容。"""
import datetime
import json
import math
import re
import subprocess
import urllib.request

STAGES = ['queueWaitMs', 'downloadMs', 'inspectMs', 'normalizeMs',
          'displayMs', 'variantsMs', 'uploadMs', 'previewMs', 'databaseMs']
end = datetime.datetime.now(datetime.timezone.utc)
start = end - datetime.timedelta(days=7)
result = subprocess.run([
    'journalctl', '-u', 'wenyousite-image-worker.service',
    '--since', start.isoformat(), '--until', end.isoformat(),
    '--no-pager', '-o', 'json', '--grep', 'media_processing_complete',
], capture_output=True, text=True, check=True)
rows = []
for line in result.stdout.splitlines():
    record = json.loads(line)
    message = record.get('MESSAGE', '')
    if isinstance(message, list):
        message = bytes(message).decode('utf-8', errors='replace')
    fields = dict(re.findall(r'([A-Za-z]+)=([^\s]+)', message))
    if not all(key in fields for key in STAGES):
        continue
    row = {key: int(fields[key]) for key in STAGES}
    row['observedStagesTotalMs'] = sum(row[key] for key in STAGES)
    row.update({key: fields.get(key) for key in ['purpose', 'animated']})
    row['timestampUtc'] = datetime.datetime.fromtimestamp(
        int(record['__REALTIME_TIMESTAMP']) / 1000000,
        datetime.timezone.utc).isoformat()
    rows.append(row)

def stats(group):
    output = {'count': len(group)}
    for key in STAGES + ['observedStagesTotalMs']:
        values = sorted(row[key] for row in group)
        if values:
            output[key] = {'p50': values[math.ceil(len(values) * .50) - 1],
                           'p95': values[math.ceil(len(values) * .95) - 1],
                           'max': values[-1]}
    return output

meta = json.load(urllib.request.urlopen('http://127.0.0.1:3000/api/v1/meta'))
groups = {}
for purpose, animated in sorted({(row['purpose'], row['animated']) for row in rows}):
    groups[purpose + '/' + animated] = stats([
        row for row in rows if row['purpose'] == purpose and row['animated'] == animated])
output = {'fromUtc': start.isoformat(), 'untilUtc': end.isoformat(),
          'unit': 'wenyousite-image-worker.service',
          'buildShaAtCollection': meta.get('data', {}).get('buildSha'),
          'quantileMethod': 'nearest-rank',
          'population': 'successful completion log records; not unique uploads or all attempts',
          'batchSizeAvailable': False,
          'overall': stats(rows), 'groups': groups, 'sanitizedRows': rows}
print(json.dumps(output, ensure_ascii=False, indent=2))
