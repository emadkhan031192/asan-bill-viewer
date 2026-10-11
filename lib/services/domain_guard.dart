/// Allowlist check for the Bill Viewer's NavigationDelegate.
///
/// Only the provider's [allowedDomains] — and their subdomains — may load.
/// Everything else (ads, trackers, phishing lookalikes) is blocked.
bool isAllowedUrl(String url, List<String> allowedDomains) {
  Uri? uri;
  try {
    uri = Uri.parse(url);
  } catch (_) {
    return false;
  }
  // Only http(s) pages may load inside the viewer.
  if (uri.scheme != 'http' && uri.scheme != 'https') return false;
  final host = uri.host.toLowerCase();
  if (host.isEmpty) return false;
  return allowedDomains.any((domain) {
    final d = domain.toLowerCase();
    return host == d || host.endsWith('.$d');
  });
}
