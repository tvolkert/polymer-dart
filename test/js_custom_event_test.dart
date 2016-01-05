// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')
library polymer.test.web.events_test;

import 'dart:html';
import 'dart:js';
import 'package:polymer/polymer.dart';
import 'common.dart';

@CustomTag('x-test')
class XTest extends PolymerElement {
  bool called = false;
  XTest.created() : super.created();

  void myEventHandler(e, detail, t) {
    called = true;
    expect(detail['value'], 42);
  }
}

main() => initPolymer().then((zone) => zone.run(() {
  setUp(() => Polymer.onReady);

  test('detail on JS custom events are proxied', () {
    var element = querySelector('x-test');
    expect(element.called, isFalse);
    context.callMethod('fireEvent');
    expect(element.called, isTrue);
  });
}));
