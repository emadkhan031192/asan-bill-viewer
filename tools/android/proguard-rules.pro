# Asan Bill Viewer ProGuard / R8 rules.
#
# The Flutter engine, webview_flutter, camera, ML Kit, path_provider,
# shared_preferences, share_plus, open_filex, image_picker and
# permission_handler all ship their own consumer ProGuard rules, so no
# extra -keep directives are required for release builds.
#
# The native PDF print code in MainActivity is invoked through a
# MethodChannel (no reflection), and MainActivity itself is kept because
# it is the manifest's launcher activity.

# google_mlkit_text_recognition references optional ML Kit script modules
# (chinese, devanagari, japanese, korean) that are not on the compile
# classpath. R8 treats those references as errors in release builds;
# silence them — only the latin model is bundled and used.
-dontwarn com.google.mlkit.**
