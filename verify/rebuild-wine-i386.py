#!/usr/bin/env python3
"""Wine 11.18의 i386 DLL 세 개를 다시 컴파일하고 출시 파일과 바이트 단위로 비교한다."""
import argparse
import hashlib
import os
import re
import shlex
import shutil
import struct
import subprocess
import tempfile
from pathlib import Path


RELEASE = {
    "kernelbase": "6551612b1bf79bd60793aa3af08202072a70176e012c0f1fad43b466821583c1",
    "ntdll": "2ecbb61d5597b0910026ece3c834411c909b3482a36feb63587f9eb5f0fde69d",
    "wmp": "fb906edc0b0a876967d2856de16e0de260474ea77db1f73548424bce1df96feb",
}


def recipe(makefile, variables, target):
    rule = re.search(r"^" + re.escape(target) + r":[^\n]*\n\t([^\n]+)", makefile, re.M)
    if not rule:
        raise ValueError(f"빌드 규칙 없음 {target}")
    command = rule[1].replace("$@", target)
    for _ in range(12):
        if "$" not in command:
            return shlex.split(command)
        command = re.sub(r"\$[({](\w+)[)}]", lambda m: variables[m[1]], command)
    raise ValueError(f"make 변수 전개 실패 {target}")


def compiler_units(reference):
    output = subprocess.check_output(
        ["dwarfdump", "--debug-info", "--recurse-depth=0", reference], text=True
    )
    units = {}
    for block in output.split("DW_TAG_compile_unit")[1:]:
        name = re.search(r'DW_AT_name\s+\("(.*?)"\)', block)
        version = re.search(r'DW_AT_producer\s+\("clang version (\d+)\.', block)
        directory = re.search(r'DW_AT_comp_dir\s+\("(.*?)"\)', block)
        if name and version and directory:
            units[name[1]] = (version[1], directory[1])
    return units


def copy_input(prepared, build, name):
    src, dst = prepared / name, build / name
    if dst.exists():
        return
    dst.parent.mkdir(parents=True, exist_ok=True)
    if src.is_dir():
        shutil.copytree(src, dst)
    else:
        shutil.copy2(src, dst)


def rebuild(args, work):
    build = work / "b"
    build.mkdir()
    temporary = work / "tmp"
    temporary.mkdir()
    for name in ("dlls", "include", "libs"):
        (work / name).symlink_to(args.source / name, target_is_directory=True)
    for name in ("tools/winegcc/winegcc", "tools/winebuild/winebuild", "include"):
        copy_input(args.prepared_build, build, name)

    makefile = (args.prepared_build / "Makefile").read_text().replace("\\\n", " ")
    variables = dict(re.findall(r"^(\w+) = (.*)$", makefile, re.M))
    toolchains = {"21": args.clang21_bin, "23": args.clang23_bin}

    def run(command, version):
        env = dict(os.environ, TMPDIR=str(temporary),
                   PATH=os.pathsep.join([str(toolchains[version]), os.environ["PATH"]]))
        subprocess.run(command, env=env, cwd=build, check=True)

    for name, expected in RELEASE.items():
        filename = name + ".dll"
        reference = args.release_dir / filename
        data = reference.read_bytes()
        if hashlib.sha256(data).hexdigest() != expected:
            raise ValueError(f"출시 SHA-256 불일치 {reference}")
        units = compiler_units(reference)
        target = f"dlls/{name}/i386-windows/{filename}"
        link = recipe(makefile, variables, target)
        objects = [arg for arg in link if arg.endswith(".o")]
        for arg in link:
            if arg.endswith((".a", ".res")):
                copy_input(args.prepared_build, build, arg)
        for obj in objects:
            (build / obj).parent.mkdir(parents=True, exist_ok=True)
            compile_command = recipe(makefile, variables, obj)
            source = next(arg for arg in compile_command if arg.endswith((".c", ".S")))
            # i386에서 빈 번역 단위인 ARM 등 타 아키텍처 파일에는 DWARF CU가 없다.
            if source not in units and not Path(source).stem.startswith(("signal_", "unwind")):
                raise ValueError(f"출시 DLL에 컴파일러 기록 없음 {source}")
            version, directory = units.get(source, ("21", "."))
            run(compile_command + ["-fdebug-compilation-dir=" + directory], version)
        # LLD가 PE COFF 및 디버그 디렉터리에 쓰는 링크 시각을 원래 값으로 지정한다.
        pe_offset = struct.unpack_from("<I", data, 60)[0]
        timestamp = struct.unpack_from("<I", data, pe_offset + 8)[0]
        run(link + [f"-Wl,-Xlink=/timestamp:{timestamp}"], "21")
        actual = hashlib.sha256((build / target).read_bytes()).hexdigest()
        if actual != expected:
            raise ValueError(f"재빌드 SHA-256 불일치 {filename} {actual}")
        print(f"PASS\t{filename}\t{len(objects)}개 오브젝트 재컴파일\t{actual}", flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", required=True, type=Path, help="공개 series 두 개를 적용한 소스")
    parser.add_argument("--prepared-build", required=True, type=Path, help="동일 구성의 Wine 11.18 기존 빌드")
    parser.add_argument("--release-dir", required=True, type=Path, help="출시 i386-windows DLL 디렉터리")
    parser.add_argument("--clang21-bin", required=True, type=Path, help="llvm-mingw 20250920 bin")
    parser.add_argument("--clang23-bin", required=True, type=Path, help="llvm-mingw 20260908 bin")
    parser.add_argument("--work-dir", required=True, type=Path, help="임시 파일을 만들 디렉터리")
    args = parser.parse_args()
    for name, path in vars(args).items():
        setattr(args, name, path.resolve(strict=True))
    with tempfile.TemporaryDirectory(prefix="wine-i386-", dir=args.work_dir) as directory:
        rebuild(args, Path(directory))


if __name__ == "__main__":
    main()
