#!/usr/bin/env python3
"""Read-only heuristic release gate, not a legal certification or license census.
Checks native/PE file names, native load dependencies, embedded FFmpeg configure
flags, and GStreamer plugin license strings. Does not execute bundled binaries.
"""
import argparse, concurrent.futures, json, os, re, shutil, subprocess, sys
from pathlib import Path
MACHO={bytes.fromhex(s) for s in ('feedface','cefaedfe','feedfacf','cffaedfe','cafebabe','bebafeca','cafebabf','bfbafeca')}
GPL_NAME=re.compile(r'(?:^|[/\\])(?:lib)?(?:x264|x265|xvidcore|postproc|faad|mad|a52|mpeg2|dvdcss|vidstab|rubberband|fftw\w*|readline|wbclient|smbclient)(?:[-.\d]|$)',re.I)
BAD_FLAGS=re.compile(rb'--enable-(?:gpl|nonfree)(?=[\s\x00]|$)')
FFMPEG=re.compile(r'^(?:lib)?(?:avcodec|avformat|avutil|avfilter|avdevice|swresample|swscale)(?:[-.\d]|$)|^ffmpeg(?:[.\d]|$)',re.I)
def projected_out(path,rel,data):
    if rel.startswith('Contents/Resources/d3dmetal/'): return 'build.sh forces no d3dmetal directory'
    if path.suffix.lower()=='.dll' and any(rel.startswith('Contents/Resources/'+t+'/lib/wine/x86_64-windows/') for t in ('Wine','WineCX','WineARM64')) and b'D3DMetalDLLsBase' in data: return 'build.sh removes Apple D3DMetalDLLsBase DLL'
def inspect(item):
    path,rel,magic=item; data=path.read_bytes(); issues=[]; evidence={'path':rel}
    if GPL_NAME.search(path.name): issues.append({'path':rel,'check':'known-gpl-name','evidence':path.name})
    if magic in MACHO:
        result=subprocess.run(['otool','-L',str(path)],capture_output=True,text=True)
        if result.returncode: issues.append({'path':rel,'check':'dependency-inspection-failed','evidence':result.stderr.strip()})
        else:
            deps=[line.strip().split(' (compatibility version',1)[0] for line in result.stdout.splitlines()[1:]]
            for dep in deps:
                if GPL_NAME.search(dep): issues.append({'path':rel,'check':'known-gpl-dependency','evidence':dep})
            evidence['dependencies']=deps
    if FFMPEG.search(path.name):
        strings=[s for s in data.split(b'\0') if b'--' in s and (b'--prefix=' in s or b'--disable-' in s or b'--enable-' in s)]
        configs=[s.decode('utf-8','replace') for s in strings if len(s)<32768]
        evidence['ffmpeg_configurations']=configs
        bad=BAD_FLAGS.findall(data)
        if bad: issues.append({'path':rel,'check':'ffmpeg-gpl-nonfree-flag','evidence':[s.decode() for s in bad]})
        if re.match(r'libavcodec[.\d-]',path.name) and not configs: issues.append({'path':rel,'check':'ffmpeg-configuration-unverified','evidence':'No embedded configure flags found in avcodec; inspect build record manually'})
    if 'gstreamer-1.0' in rel:
        licenses=sorted(set(s.decode() for s in re.findall(rb'(?:^|\x00)(GPL(?: v[23])?|LGPL(?: v[23])?|BSD|MIT/X11|Proprietary|unknown)\x00',data)))
        evidence['gstreamer_license_strings']=licenses
        if any(s=='GPL' or s.startswith('GPL ') for s in licenses): issues.append({'path':rel,'check':'gstreamer-gpl-license','evidence':licenses})
    return issues,evidence

def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('app',type=Path);ap.add_argument('--project-release',action='store_true',help='Exclude ONLY build.sh documented GPTK development artifacts; still not an actual release build');ap.add_argument('--json',type=Path);ap.add_argument('--jobs',type=int,default=6);a=ap.parse_args()
    if not shutil.which('otool'): ap.error('otool is required: dependency inspection may not be silently skipped')
    if not (a.app/'Contents').is_dir(): ap.error('expected a macOS .app with Contents/')
    items=[]; excluded=[];links=[]
    for root,dirs,files in os.walk(a.app/'Contents',followlinks=False):
        dirs.sort(); files.sort()
        for name in files:
            p=Path(root)/name;rel=str(p.relative_to(a.app))
            if p.is_symlink():
                if not p.resolve().is_relative_to(a.app.resolve()): links.append({'path':rel,'check':'external-symlink-uninspected','evidence':os.readlink(p)})
                continue
            with p.open('rb') as f: magic=f.read(4)
            if magic not in MACHO and magic[:2]!=b'MZ' and magic!=b'\x7fELF': continue
            reason=projected_out(p,rel,p.read_bytes()) if a.project_release and (rel.startswith('Contents/Resources/d3dmetal/') or p.suffix.lower()=='.dll') else None
            if reason: excluded.append({'path':rel,'reason':reason});continue
            items.append((p,rel,magic))
    # Avoid retaining the full app in memory when processing real, large bundles.
    issues=links; evidence=[]
    with concurrent.futures.ThreadPoolExecutor(max_workers=a.jobs) as pool:
        for found,record in pool.map(inspect,items): issues.extend(found);evidence.append(record)
    result={'schema':1,'app':str(a.app.resolve()),'mode':'installed-app-release-projection' if a.project_release else 'actual-bundle','scope':'Heuristic evidence only. Does not prove absence of all GPL code or licensing compliance. Dependencies must be inspected; no bundled code is run.','binary_files_scanned':len(items),'projected_exclusions':excluded,'issues':issues,'evidence':evidence,'pass':not issues}
    if a.json: a.json.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ('mode','binary_files_scanned','pass')})); print('issues='+str(len(issues))+' exclusions='+str(len(excluded)))
    for issue in issues: print('FAIL '+json.dumps(issue,ensure_ascii=False))
    return 0 if not issues else 1
if __name__=='__main__':sys.exit(main())
