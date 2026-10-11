#!/usr/bin/env python3
"""Patch the flutter-generated android/ folder for Asan Bill Viewer.

Run after `flutter create --platforms=android .` (the CI workflow does this
automatically). Idempotent: safe to run more than once.

Does:
  1. AndroidManifest.xml: ensures INTERNET + CAMERA permissions (no storage
     permission — the Vault uses app-private storage).
  2. Installs the app's MainActivity (native WebView -> PDF print channel).
  3. app/build.gradle: minSdk 24, R8 + resource shrinking for release.
  4. Installs proguard-rules.pro.
  5. Installs launcher icon resources from tools/android/res/.

Usage: python3 tools/patch_android.py   (from the project root)
"""
import os
import re
import shutil
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APP = os.path.join(ROOT, "android", "app")
MAIN = os.path.join(APP, "src", "main")


def fail(msg: str) -> None:
    print(f"patch_android: ERROR: {msg}", file=sys.stderr)
    sys.exit(1)


def patch_manifest() -> None:
    path = os.path.join(MAIN, "AndroidManifest.xml")
    if not os.path.exists(path):
        fail(f"missing {path} — run `flutter create --platforms=android .` first")
    with open(path) as f:
        src = f.read()
    additions = []
    if "android.permission.INTERNET" not in src:
        additions.append(
            '    <uses-permission android:name="android.permission.INTERNET" />')
    if "android.permission.CAMERA" not in src:
        additions.append(
            '    <uses-permission android:name="android.permission.CAMERA" />')
    if additions:
        # Permissions live at the manifest top level, before <application.
        src = src.replace(
            "<application",
            "\n".join(additions) + "\n    <application",
            1,
        )
        with open(path, "w") as f:
            f.write(src)
        print("patch_android: manifest permissions added")
    else:
        print("patch_android: manifest permissions already present")


def patch_main_activity() -> None:
    kotlin_root = os.path.join(MAIN, "kotlin")
    found = None
    for dirpath, _, filenames in os.walk(kotlin_root):
        if "MainActivity.kt" in filenames:
            found = os.path.join(dirpath, "MainActivity.kt")
            break
    if found is None:
        fail("MainActivity.kt not found under android/app/src/main/kotlin")
    with open(found) as f:
        old = f.read()
    m = re.search(r"^package\s+([\w.]+)", old, re.M)
    if not m:
        fail("could not read package from MainActivity.kt")
    package = m.group(1)
    with open(os.path.join(ROOT, "tools", "android",
                           "MainActivity.kt.template")) as f:
        template = f.read()
    new = template.replace("__PACKAGE__", package)
    with open(found, "w") as f:
        f.write(new)
    print(f"patch_android: MainActivity installed (package {package})")


def patch_build_gradle() -> None:
    groovy = os.path.join(APP, "build.gradle")
    kts = os.path.join(APP, "build.gradle.kts")
    path = groovy if os.path.exists(groovy) else kts
    if not os.path.exists(path):
        fail("app/build.gradle(.kts) not found")
    with open(path) as f:
        src = f.read()
    is_kts = path.endswith(".kts")

    # --- minSdk 24 ---
    if is_kts:
        src = re.sub(r"minSdk\s*=\s*flutter\.minSdkVersion", "minSdk = 24", src)
        src = re.sub(r"minSdk\s*=\s*\d+", "minSdk = 24", src)
    else:
        src = re.sub(r"minSdk\s*=\s*flutter\.minSdkVersion", "minSdk = 24", src)
        src = re.sub(r"minSdkVersion\s+\d+", "minSdkVersion 24", src)

    # --- R8 + resource shrinking on release ---
    if "proguard-rules.pro" not in src:
        if is_kts:
            anchor = 'signingConfig = signingConfigs.getByName("debug")'
            addition = (
                '\n            isMinifyEnabled = true'
                '\n            isShrinkResources = true'
                '\n            proguardFiles('
                'getDefaultProguardFile("proguard-android-optimize.txt"), '
                '"proguard-rules.pro")'
            )
        else:
            anchor = "signingConfig = signingConfigs.debug"
            addition = (
                "\n            minifyEnabled = true"
                "\n            shrinkResources = true"
                "\n            proguardFiles "
                "getDefaultProguardFile('proguard-android-optimize.txt'), "
                "'proguard-rules.pro'"
            )
        if anchor not in src:
            fail("could not find release signingConfig block in build.gradle")
        src = src.replace(anchor, anchor + addition, 1)
        print("patch_android: R8 + resource shrinking enabled for release")
    else:
        print("patch_android: R8 config already present")

    with open(path, "w") as f:
        f.write(src)

    # --- proguard rules file ---
    shutil.copy(
        os.path.join(ROOT, "tools", "android", "proguard-rules.pro"),
        os.path.join(APP, "proguard-rules.pro"),
    )
    print("patch_android: proguard-rules.pro installed")


def install_icons() -> None:
    src_res = os.path.join(ROOT, "tools", "android", "res")
    dst_res = os.path.join(MAIN, "res")
    for dirpath, _, filenames in os.walk(src_res):
        rel = os.path.relpath(dirpath, src_res)
        dst_dir = os.path.join(dst_res, rel)
        os.makedirs(dst_dir, exist_ok=True)
        for name in filenames:
            shutil.copy(os.path.join(dirpath, name),
                        os.path.join(dst_dir, name))
    print("patch_android: launcher icons installed")


def main() -> None:
    if not os.path.isdir(os.path.join(ROOT, "android")):
        fail("android/ not found — run `flutter create --platforms=android .` first")
    patch_manifest()
    patch_main_activity()
    patch_build_gradle()
    install_icons()
    print("patch_android: done")


if __name__ == "__main__":
    main()
