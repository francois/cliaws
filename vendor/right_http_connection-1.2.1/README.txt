== INFORMATION

Patched #request to not crash if the request's body is an IO that doesn't respond_to?(:lstat) and #size.
