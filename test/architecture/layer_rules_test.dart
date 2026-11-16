import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'layer_rules.dart';

List<Violation> check(String path, List<String> imports) =>
    checkFile(SourceFile(path, imports));

void main() {
  group('the rules reject', () {
    test('domain importing any package', () {
      expect(check('lib/features/stay/domain/stay.dart', ['package:any_package/any_package.dart']), isNotEmpty);
    });

    test('domain importing a platform Dart library', () {
      expect(check('lib/features/stay/domain/stay.dart', ['dart:io']), isNotEmpty);
      expect(check('lib/features/stay/domain/stay.dart', ['dart:ui']), isNotEmpty);
    });

    test('domain importing data or core', () {
      expect(check('lib/features/stay/domain/stay.dart', ['../data/stay_dao.dart']), isNotEmpty);
      expect(check('lib/features/stay/domain/stay.dart', ['package:kaiosk/core/di/locator.dart']), isNotEmpty);
    });

    test('view importing data by relative path', () {
      expect(check('lib/features/stay/view/board_page.dart', ['../data/stay_dao.dart']), isNotEmpty);
    });

    test('data importing view', () {
      expect(check('lib/features/stay/data/stay_dao.dart', ['package:kaiosk/features/stay/view/board_page.dart']), isNotEmpty);
    });

    test('a feature importing another feature\'s data or view', () {
      expect(check('lib/features/stay/data/stay_dao.dart', ['package:kaiosk/features/map/data/place_dao.dart']), isNotEmpty);
      expect(check('lib/features/stay/view/board_page.dart', ['../../map/view/map_page.dart']), isNotEmpty);
    });

    test('get_it outside lib/core/di', () {
      expect(check('lib/features/stay/view/board_page.dart', ['package:get_it/get_it.dart']), isNotEmpty);
      expect(check('lib/core/router/router.dart', ['package:get_it/get_it.dart']), isNotEmpty);
    });

    test('a file outside every layer', () {
      expect(check('lib/utils/format.dart', const []), isNotEmpty);
    });
  });

  group('the rules allow', () {
    test('domain depending on pure Dart and any feature\'s domain', () {
      expect(check('lib/features/stay/domain/stay.dart', ['dart:async', 'dart:math', '../../map/domain/place.dart', 'package:kaiosk/features/stay/domain/guest.dart']), isEmpty);
    });

    test('view and data depending on any feature\'s domain', () {
      expect(check('lib/features/stay/view/board_cubit.dart', ['package:any_package/any_package.dart', '../../map/domain/place.dart']), isEmpty);
      expect(check('lib/features/stay/data/stay_dao.dart', ['package:any_package/any_package.dart', '../domain/stay.dart']), isEmpty);
    });

    test('data and view depending on core', () {
      expect(check('lib/features/stay/data/stay_dao.dart', ['package:kaiosk/core/database/app_database.dart']), isEmpty);
      expect(check('lib/features/stay/view/board_page.dart', ['../../../core/router/routes.dart']), isEmpty);
    });

    test('core and main wiring everything', () {
      expect(check('lib/core/di/locator.dart', ['package:get_it/get_it.dart', 'package:kaiosk/features/stay/data/stay_dao.dart']), isEmpty);
      expect(check('lib/main.dart', ['package:get_it/get_it.dart', 'core/router/router.dart']), isEmpty);
    });
  });

  test('lib/ follows the layer rules', () {
    expect(checkLibrary(Directory('lib')), isEmpty);
  });
}
