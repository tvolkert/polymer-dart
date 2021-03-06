@TestOn('browser')
library polymer.test.src.template.dom_repeat_test;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:test/test.dart';

main() async {
  await initPolymer();

  UserList element;

  group('dom-repeat', () {
    setUp(() {
      element = new UserList();
    });

    test('basic', () {
      expectUsers(element, ['A', 'B']);
    });

    test('add and remove items', () {
      element.addAll('users', [new User('C'), new User('D'),]);
      expectUsers(element, ['A', 'B', 'C', 'D']);
      element.removeRange('users', 1, 3);
      expectUsers(element, ['A', 'D']);
    });

    test('modify items from model', () {
      element.userList.render();
      var model = element.userList
          .modelForElement(Polymer.dom(element.root).querySelector('.user'));
      model.set('user.name', 'C');
      expectUsers(element, ['C', 'B']);
    });

    test('sort items by method name', () {
      element.set('users',
          [new User('B'), new User('A'), new User('E'), new User('D'),]);
      element.userList.sort = 'sortUsers';
      expectUsers(element, ['A', 'B', 'D', 'E']);
    });

    test('sort items by function tearoff', () {
      element.set('users',
          [new User('B'), new User('A'), new User('E'), new User('D'),]);

      element.userList.sort = reverseSort;
      expectUsers(element, ['E', 'D', 'B', 'A']);
    });

    test('filter items by method name', () {
      element.set('users',
          [new User('B'), new User('A'), new User('E'), new User('D'),]);
      element.userList.filter = 'removeAAndE';
      expectUsers(element, ['B', 'D']);
    });

    test('filter items by function tearoff', () {
      element.set('users',
          [new User('B'), new User('A'), new User('E'), new User('D'),]);

      element.userList.filter = keepAAndE;
      expectUsers(element, ['A', 'E']);
    });

    test("chuncked mode and rendered item count",() async {
      const int count = 6;
      int initial = element.chunkedUserList.initialCount;
      element.set('users',new List.generate(count, (int i)=> new User("User ${i}") ) );
      expect(element.chunkedUserList.renderedItemCount,isNull);

      await element.chunkedUserList.on["dom-change"].first;
      expect(element.chunkedUserList.renderedItemCount,count);
      int userCount = new PolymerDom(element.root).querySelectorAll(".chunckedUser").length;
      expect(userCount,initial);

      await element.chunkedUserList.on["dom-change"].first;
      expect(element.chunkedUserList.renderedItemCount,count);
      userCount = new PolymerDom(element.root).querySelectorAll(".chunckedUser").length;
      expect(userCount,count);
    });
  });
}


int reverseSort(User a, User b) => b.name.compareTo(a.name);

bool keepAAndE(User user, [_, __]) {
  const keep = const ['A', 'E'];
  return keep.contains(user.name);
}

void expectUsers(UserList element, List<String> names) {
  element.userList.render();
  var userDivs = Polymer.dom(element.root).querySelectorAll('.user');
  expect(userDivs.length, names.length);

  for (int i = 0; i < names.length; i++) {
    expect(userDivs[i].text, names[i]);
    expect(element.userList.itemForElement(userDivs[i]).name, names[i]);
    var model = element.userList.modelForElement(userDivs[i]);
    expect(model.index, i);
    // Check both the deprecated `item` getter and the new index operator.
    expect(model.item.name, names[i]);
    expect(model['user'].name, names[i]);
  }
}

@PolymerRegister('user-list')
class UserList extends PolymerElement {
  UserList.created() : super.created();
  factory UserList() => document.createElement('user-list');

  @property
  List<User> users;

  DomRepeat get userList => $['userList'];

  DomRepeat get chunkedUserList => $['chunkedUserList'];

  ready() {
    set('users', [new User('A'), new User('B'),]);
  }

  @reflectable
  bool fakeFilter(x) => true;

  @reflectable
  int sortUsers(User a, User b) {
    return a.name.compareTo(b.name);
  }

  @reflectable
  bool removeAAndE(User user, [_, __]) {
    const skip = const ['A', 'E'];
    return !skip.contains(user.name);
  }
}

class User extends JsProxy {
  @reflectable
  String name;

  User(this.name);
}
