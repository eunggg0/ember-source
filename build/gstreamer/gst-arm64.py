#!/usr/bin/env python3
"""ARM64(FEX) 런타임용 제3자 dylib 묶음 만들기 — GStreamer(+플러그인)·GLib·GnuTLS·FreeType·libusb 와 그 의존.

2026-10-01 부터 Homebrew 병을 쓰지 않는다. Homebrew 병은 minos 26/27 이라 macOS 26 미만에서 로드되지 않고
(Wine 프로세스 xzone malloc 문제와도 얽힘, README "wine-macos-minos"), 일부는 GPL·X11·p11-kit 까지 끌고 왔다.
대신 .refs/arm64-deps-min11/build-deps.sh 로 minos 11.0 소스 빌드한 prefix(같은 버전·같은 소네임)를 원본으로 쓴다.
  gst-arm64.py <런타임 루트> [원본 prefix]
    예: gst-arm64.py Vendor/wine-arm64          (원본 기본값: .refs/arm64-deps-min11/out)
결과: <루트>/lib(라이브러리)·<루트>/lib/gstreamer-1.0(플러그인), 설치 이름 @rpath/<이름>, 참조 @loader_path/…,
      LC_RPATH 삭제, strip -x, ad-hoc 서명. minos 가 11.0 보다 높거나 /opt/homebrew 참조가 남으면 실패로 끝난다.
FFmpeg 는 직접 빌드한 LGPL 판(Data/source-release/build-config/ffmpeg/ffmpeg-arm64-lgpl.sh)이 <루트>/lib 에 이미 있어야 하고,
플러그인은 그 파일을 가리키게만 한다.
"""
import os, re, shutil, subprocess, sys

PLUGINS = ["applemedia", "asf", "audioconvert", "audioparsers", "audioresample", "avi", "coreelements",
           "deinterlace", "id3demux", "isomp4", "mpegpsdemux", "opengl", "playback", "typefindfunctions",
           "videoconvertscale", "videofilter", "videoparsersbad", "wavparse",
           "adpcmdec", "alaw", "mulaw",   # 옛 게임 AVI 소리: MS/IMA ADPCM(avdec_adpcm_ima_wav 는 열기 실패)·A/μ-law (2026-10-02 parity-avi)
           "libav"]   # AAC·WMA·WMV 디코더(avdec_*). applemedia 에는 atdec(AAC)이 없다
# Wine 유닉스 .so 가 직접 링크하거나 dlopen 하는 것(플러그인 의존으로는 안 잡히는 것)
#   dwrite.so·win32u.so → libfreetype.6, secur32.so·crypt32.so → libgnutls.30, wineusb.so → libusb-1.0.0,
#   winegstreamer.so → libintl.8(+gst/glib, 플러그인 의존으로 잡힘)
LIBS = ["libfreetype.6.dylib", "libgnutls.30.dylib", "libusb-1.0.0.dylib", "libintl.8.dylib"]
MINOS_MAX = (11, 0)
FFMPEG = re.compile(r"^lib(avcodec|avformat|avfilter|avutil|avdevice|swscale|swresample|postproc)\.")
SYSTEM = ("/usr/lib", "/System")

root = sys.argv[1]
SRC = os.path.realpath(sys.argv[2] if len(sys.argv) > 2 else "$WORK/arm64-deps-min11/out")
libdir = os.path.join(root, "lib"); plugdir = os.path.join(libdir, "gstreamer-1.0")
os.makedirs(plugdir, exist_ok=True)

def deps(path):
    out = subprocess.run(["otool", "-L", path], capture_output=True, text=True).stdout.splitlines()[1:]
    return [l.strip().split(" (")[0] for l in out]

def rpaths(path):
    out = subprocess.run(["otool", "-l", path], capture_output=True, text=True).stdout.splitlines()
    rp = []
    for i, l in enumerate(out):
        if "cmd LC_RPATH" in l:
            m = re.search(r"path (\S+)", out[i + 2]); rp.append(m.group(1))
    return rp

def minos(path):
    out = subprocess.run(["otool", "-l", path], capture_output=True, text=True).stdout
    m = re.search(r"minos (\d+)\.(\d+)", out)
    return (int(m.group(1)), int(m.group(2))) if m else None

def install_base(path):
    """넣을 파일 이름 = 설치 이름(LC_ID_DYLIB)의 끝 이름. 실파일이 libnettle.8.11.dylib 여도 libnettle.8.dylib 로 넣는다."""
    out = subprocess.run(["otool", "-D", path], capture_output=True, text=True).stdout.splitlines()
    return os.path.basename(out[1].strip()) if len(out) > 1 and out[1].strip() else os.path.basename(path)

def resolve(ref, owner):
    if FFMPEG.match(os.path.basename(ref)):   # LGPL FFmpeg 는 <루트>/lib 에 미리 넣어 둔 것을 가리킨다
        c = os.path.join(libdir, os.path.basename(ref))
        return os.path.realpath(c) if os.path.exists(c) else c
    if ref.startswith("/opt/homebrew") or ref.startswith("/usr/local"):
        sys.exit(f"오류: {owner} 가 {ref} 를 참조한다 — Homebrew 병을 섞지 말 것(build-deps.sh 로 다시 빌드)")
    if ref.startswith("/"):
        r = os.path.realpath(ref)
        return r if os.path.exists(r) else None
    if ref.startswith("@rpath/") or ref.startswith("@loader_path/"):
        name = ref.split("/", 1)[1]
        cands = []
        if ref.startswith("@loader_path/"): cands.append(os.path.join(os.path.dirname(owner), name))
        for rp in rpaths(owner):
            rp = rp.replace("@loader_path", os.path.dirname(owner))
            cands.append(os.path.join(rp, name))
        cands += [os.path.join(SRC, "lib", os.path.basename(name))]
        for c in cands:
            if os.path.exists(c): return os.path.realpath(c)
    return None

todo = [os.path.join(SRC, "lib/gstreamer-1.0", f"libgst{p}.dylib") for p in PLUGINS]
todo += [os.path.join(SRC, "lib", n) for n in LIBS]
for t in todo:
    if not os.path.exists(t): sys.exit(f"오류: 원본 없음 {t}")
seen = {}   # 원본 실경로 → 넣을 이름
queue = [os.path.realpath(t) for t in todo]
while queue:
    src = queue.pop()
    if src in seen: continue
    seen[src] = install_base(src)
    for ref in deps(src):
        if ref.startswith(SYSTEM): continue
        r = resolve(ref, src)
        if r and FFMPEG.match(os.path.basename(r)):
            if not os.path.exists(os.path.join(libdir, os.path.basename(r))):
                print("경고: LGPL FFmpeg 없음 —", os.path.basename(r), "(ffmpeg-arm64-lgpl.sh 먼저)")
            continue
        if r and r not in seen: queue.append(r)
        elif not r: print("미해결:", ref, "←", src)

bad = [(s, minos(s)) for s in seen if (minos(s) or (99, 0)) > MINOS_MAX]
if bad:
    for s, m in bad: print("minos 초과:", s, m)
    sys.exit("오류: minos 11.0 넘는 원본이 있다")

names = {}
for src, base in seen.items():
    plugin = "/lib/gstreamer-1.0/" in src
    dst = os.path.join(plugdir if plugin else libdir, base)
    if os.path.exists(dst): os.chmod(dst, 0o755)
    shutil.copy2(src, dst); os.chmod(dst, 0o755)
    names[src] = (dst, plugin)

# 참조 이름 → 넣은 파일 이름(버전 링크 이름도 같은 파일로 푼다)
def target_name(ref, owner_src):
    r = resolve(ref, owner_src)
    if r and FFMPEG.match(os.path.basename(r)): return os.path.basename(r)   # 미리 넣어 둔 LGPL FFmpeg
    return seen[r] if r in names else None

for src, (dst, plugin) in names.items():
    subprocess.run(["strip", "-x", dst], capture_output=True)
    args = ["install_name_tool", "-id", "@rpath/" + os.path.basename(dst)]
    for ref in deps(src):
        t = target_name(ref, src) if not ref.startswith(SYSTEM) else None
        if t: args += ["-change", ref, ("@loader_path/../" if plugin else "@loader_path/") + t]
    for rp in rpaths(src): args += ["-delete_rpath", rp]
    r = subprocess.run(args + [dst], capture_output=True, text=True)
    if r.returncode: sys.exit(f"install_name_tool 실패 {dst}: {r.stderr}")
    subprocess.run(["codesign", "-f", "-s", "-", dst], capture_output=True)

def leaks(d):
    out = subprocess.run(["otool", "-l", d], capture_output=True, text=True).stdout
    return re.findall(r"(?:name|path) (/(?:opt/homebrew|usr/local|Volumes)\S*)", out)
left = [d for d, _ in names.values() if leaks(d)]
print(f"라이브러리 {sum(1 for _, p in names.values() if not p)}개, 플러그인 {sum(1 for _, p in names.values() if p)}개, "
      f"개발 경로 참조 남음 {len(left)}, 원본 {SRC}")
for d in left[:5]: print("  남음:", d, leaks(d)[:3])
if left: sys.exit(1)
