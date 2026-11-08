import 'dart:convert';
import 'dart:typed_data';

/// Bundled in code so a missing or stale asset manifest cannot hide the library.
final Uint8List fallbackArtwork = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAApElEQVR42u3ZsRGAIAyFYeEYxc5aJ9MpdDKX0s6jkEKSoDn/VNo8+eCSAkM/jEfnuGLnvAAA+DsgWQXP6349b8vk6wTyxd+9fxpQWqwVgiYG0GoKWU+V2vxY05jaDSnJj0/DtRHSfJoYAAAAAAAAAAAAAAAAAABYAUo3BFo3E9L8WPMR7WsVSX6S7pQVgh4A4BVgPbWanID11Mor8KceAAAAr9YJdqcy2eBn0VEAAAAASUVORK5CYII=',
);
