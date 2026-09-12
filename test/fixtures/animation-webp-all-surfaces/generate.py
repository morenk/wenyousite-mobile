"""生成自制动画资源测试素材，不依赖业务模型或用户内容。"""

import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw, __version__


ROOT = Path(__file__).resolve().parent
frames = []
for background, foreground in [("#ef3340", "#102080"), ("#235fe5", "#ffd200")]:
    frame = Image.new("RGB", (320, 180), background)
    draw = ImageDraw.Draw(frame)
    draw.rectangle((80, 45, 239, 134), fill=foreground)
    frames.append(frame)

durations = [120, 240]
frames[0].save(
    ROOT / "original.gif",
    save_all=True,
    append_images=frames[1:],
    duration=durations,
    loop=1,
    disposal=2,
    optimize=False,
)
frames[0].save(
    ROOT / "full.webp",
    save_all=True,
    append_images=frames[1:],
    duration=durations,
    loop=2,
    lossless=True,
    method=6,
)
preview = [frame.resize((80, 45), Image.Resampling.NEAREST) for frame in frames]
preview[0].save(
    ROOT / "preview.webp",
    save_all=True,
    append_images=preview[1:],
    duration=durations,
    loop=2,
    lossless=True,
    method=6,
)
frames[0].save(ROOT / "poster.png")

assets = []
for name in ["original.gif", "full.webp", "preview.webp", "poster.png"]:
    path = ROOT / name
    with Image.open(path) as decoded:
        widths = decoded.size
        count = decoded.n_frames
        loop = decoded.info.get("loop")
        decoded_durations = []
        for index in range(count):
            decoded.seek(index)
            decoded.load()
            decoded_durations.append(decoded.info.get("duration", 0))
    assets.append(
        {
            "file": name,
            "width": widths[0],
            "height": widths[1],
            "frames": count,
            "durationsMs": decoded_durations,
            "encodedLoopValue": loop,
            "bytes": path.stat().st_size,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
        }
    )

(ROOT / "manifest.json").write_text(
    json.dumps({"generator": f"Pillow {__version__}", "assets": assets}, indent=2)
    + "\n",
    encoding="utf-8",
)
