String sanitizeReturnLocation(String? value) {
  if (value == null ||
      !value.startsWith('/') ||
      value.startsWith('//') ||
      value.startsWith('/auth/')) {
    return '/home';
  }
  return value;
}
