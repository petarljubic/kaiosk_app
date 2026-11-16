import 'dart:io';

const packageName = 'kaiosk';

enum Layer { domain, data, view, core, entry, outside }

class SourceFile {
  const SourceFile(this.path, this.imports);

  final String path;
  final List<String> imports;
}

class Violation {
  const Violation(this.path, this.message);

  final String path;
  final String message;

  @override
  String toString() => '$path: $message';
}

const _diRoots = ['lib/core/di/', 'lib/main.dart'];

const _pureDartLibraries = {
  'dart:async',
  'dart:collection',
  'dart:convert',
  'dart:core',
  'dart:math',
  'dart:typed_data',
};

const _allowedLayers = {
  Layer.domain: {Layer.domain},
  Layer.data: {Layer.domain, Layer.data, Layer.core},
  Layer.view: {Layer.domain, Layer.view, Layer.core},
};

final _featureLayer = RegExp(r'^lib/features/([^/]+)/(domain|data|view)/');
final _directive = RegExp(
  r'''^\s*(?:import|export|part)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

Layer layerOf(String path) {
  if (path == 'lib/main.dart') return Layer.entry;
  if (path.startsWith('lib/core/')) return Layer.core;
  final match = _featureLayer.firstMatch(path);
  if (match == null) return Layer.outside;
  return Layer.values.byName(match.group(2)!);
}

String? featureOf(String path) => _featureLayer.firstMatch(path)?.group(1);

String resolveImport(String fromPath, String target) {
  final prefix = 'package:$packageName/';
  if (target.startsWith(prefix)) return 'lib/${target.substring(prefix.length)}';
  if (target.contains(':')) return target;
  return Uri.parse('file:///$fromPath').resolve(target).path.substring(1);
}

List<Violation> checkFile(SourceFile file) {
  final layer = layerOf(file.path);
  if (layer == Layer.outside) {
    return [Violation(file.path, 'outside lib/core, lib/main.dart and lib/features/<feature>/{domain,data,view}')];
  }
  return [
    for (final target in file.imports)
      ...checkImport(file.path, layer, resolveImport(file.path, target)),
  ];
}

List<Violation> checkImport(String path, Layer layer, String target) {
  if (target.startsWith('package:get_it/') && !_diRoots.any(path.startsWith)) {
    return [Violation(path, 'get_it is used only in lib/core/di/ and lib/main.dart')];
  }
  if (target.startsWith('lib/')) return _checkInternal(path, layer, target);
  if (layer == Layer.domain && !_pureDartLibraries.contains(target)) {
    return [Violation(path, 'domain may import only pure Dart libraries and domain files, not $target')];
  }
  return const [];
}

List<Violation> _checkInternal(String path, Layer layer, String target) {
  final allowed = _allowedLayers[layer];
  if (allowed == null) return const [];
  final targetLayer = layerOf(target);
  if (!allowed.contains(targetLayer)) {
    return [Violation(path, '${layer.name} must not depend on ${targetLayer.name} ($target)')];
  }
  final featureScoped = targetLayer == Layer.data || targetLayer == Layer.view;
  if (featureScoped && featureOf(target) != featureOf(path)) {
    return [Violation(path, 'must not import another feature\'s ${targetLayer.name} ($target)')];
  }
  return const [];
}

List<String> directivesIn(String source) =>
    [for (final match in _directive.allMatches(source)) match.group(1)!];

List<SourceFile> readLibrary(Directory root) {
  final files = root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
  return [
    for (final file in files)
      SourceFile(
        file.path.replaceAll('\\', '/'),
        directivesIn(file.readAsStringSync()),
      ),
  ];
}

List<Violation> checkLibrary(Directory root) =>
    [for (final file in readLibrary(root)) ...checkFile(file)];
