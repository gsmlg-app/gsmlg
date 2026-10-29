import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flex_tabs/flex_tabs.dart';

class TestTabItem extends TabItem {
  final String testId;
  bool wasActivated = false;
  bool wasDeactivated = false;
  bool wasMounted = false;
  bool wasUnmounted = false;
  bool wasDisposed = false;

  TestTabItem(this.testId, {super.title, super.content});

  @override
  void didActivate() {
    wasActivated = true;
    super.didActivate();
  }

  @override
  void didDeactivate() {
    wasDeactivated = true;
    super.didDeactivate();
  }

  @override
  void didMount() {
    wasMounted = true;
    super.didMount();
  }

  @override
  void didUnmount() {
    wasUnmounted = true;
    super.didUnmount();
  }

  @override
  void didDispose() {
    wasDisposed = true;
    super.didDispose();
  }
}

void main() {
  group('TabItem', () {
    test('can be instantiated without parameters', () {
      final tab = TabItem();
      expect(tab, isNotNull);
      expect(tab.title.value, isNull);
      expect(tab.content.value, isNull);
    });

    test('can be instantiated with title', () {
      final tab = TabItem(title: const Text('Test'));
      expect(tab.title.value, isA<Text>());
    });

    test('can be instantiated with content', () {
      final tab = TabItem(content: const Text('Content'));
      expect(tab.content.value, isA<Text>());
    });

    test('title is a ValueNotifier', () {
      final tab = TabItem();
      expect(tab.title, isA<ValueNotifier<Widget?>>());
    });

    test('content is a ValueNotifier', () {
      final tab = TabItem();
      expect(tab.content, isA<ValueNotifier<Widget?>>());
    });

    test('isActivated returns false when no parent', () {
      final tab = TabItem();
      expect(tab.isActivated, isFalse);
    });

    test('parent is null initially', () {
      final tab = TabItem();
      expect(tab.parent, isNull);
    });

    test('disposed is false initially', () {
      final tab = TabItem();
      expect(tab.disposed, isFalse);
    });

    test('toString includes title', () {
      final tab = TabItem(title: const Text('My Tab'));
      expect(tab.toString(), contains('Tab<'));
    });

    test('dispose sets disposed to true', () {
      final tab = TabItem();
      tab.dispose();
      expect(tab.disposed, isTrue);
    });
  });

  group('Tabs container', () {
    test('can be instantiated without children', () {
      final tabs = Tabs();
      expect(tabs, isNotNull);
      expect(tabs.children, isEmpty);
    });

    test('can be instantiated with children', () {
      final tab1 = TabItem();
      final tab2 = TabItem();
      final tabs = Tabs(children: [tab1, tab2]);
      expect(tabs.children.length, 2);
    });

    test('activeTab is null when no tabs', () {
      final tabs = Tabs();
      expect(tabs.activeTab, isNull);
    });

    test('first tab is auto-activated when added', () {
      final tabs = Tabs();
      final tab = TestTabItem('tab-1');
      tabs.add(tab);
      expect(tabs.activeTab, tab);
      expect(tab.isActivated, isTrue);
      expect(tab.wasActivated, isTrue);
    });

    test('add sets tab parent', () {
      final tabs = Tabs();
      final tab = TabItem();
      tabs.add(tab);
      expect(tab.parent, tabs);
    });

    test('add calls didMount', () {
      final tabs = Tabs();
      final tab = TestTabItem('tab-1');
      tabs.add(tab);
      expect(tab.wasMounted, isTrue);
    });

    test('cannot add disposed tab', () {
      final tabs = Tabs();
      final tab = TabItem();
      tab.dispose();
      expect(() => tabs.add(tab), throwsStateError);
    });

    test('activate changes active tab', () {
      final tabs = Tabs();
      final tab1 = TestTabItem('tab-1');
      final tab2 = TestTabItem('tab-2');
      tabs.add(tab1);
      tabs.add(tab2);

      tabs.activate(tab2);
      expect(tabs.activeTab, tab2);
    });

    test('activate calls didDeactivate on previous tab', () {
      final tabs = Tabs();
      final tab1 = TestTabItem('tab-1');
      final tab2 = TestTabItem('tab-2');
      tabs.add(tab1);
      tabs.add(tab2);

      tabs.activate(tab2);
      expect(tab1.wasDeactivated, isTrue);
    });

    test('activate does nothing for tab not in children', () {
      final tabs = Tabs();
      final tab1 = TabItem();
      final tab2 = TabItem();
      tabs.add(tab1);
      // tab2 is not added

      tabs.activate(tab2);
      expect(tabs.activeTab, tab1); // Still the first tab
    });

    test('remove returns true for existing tab', () {
      final tabs = Tabs();
      final tab = TabItem();
      tabs.add(tab);
      expect(tabs.remove(tab), isTrue);
    });

    test('remove returns false for non-existing tab', () {
      final tabs = Tabs();
      final tab1 = TabItem();
      final tab2 = TabItem();
      tabs.add(tab1);
      expect(tabs.remove(tab2), isFalse);
    });

    test('remove calls didUnmount', () {
      final tabs = Tabs();
      final tab = TestTabItem('tab-1');
      tabs.add(tab);
      tabs.remove(tab);
      expect(tab.wasUnmounted, isTrue);
    });

    test('remove activates next tab when removing active tab', () {
      final tabs = Tabs();
      final tab1 = TabItem();
      final tab2 = TabItem();
      tabs.add(tab1);
      tabs.add(tab2);

      expect(tabs.activeTab, tab1);
      tabs.remove(tab1);
      expect(tabs.activeTab, tab2);
    });

    test('replace replaces tab in children', () {
      final tabs = Tabs();
      final tab1 = TabItem();
      final tab2 = TabItem();
      tabs.add(tab1);

      tabs.replace(tab1, tab2);
      expect(tabs.children, contains(tab2));
      expect(tabs.children, isNot(contains(tab1)));
    });

    test('replace activates new tab if old was active', () {
      final tabs = Tabs();
      final tab1 = TabItem();
      final tab2 = TabItem();
      tabs.add(tab1);

      tabs.replace(tab1, tab2);
      expect(tabs.activeTab, tab2);
    });

    test('children count after multiple operations', () {
      final tabs = Tabs();
      expect(tabs.children.length, 0);

      tabs.add(TabItem());
      expect(tabs.children.length, 1);

      tabs.add(TabItem());
      expect(tabs.children.length, 2);

      tabs.remove(tabs.children.first);
      expect(tabs.children.length, 1);
    });

    test('toString contains children', () {
      final tabs = Tabs();
      tabs.add(TabItem(title: const Text('Tab 1')));
      expect(tabs.toString(), contains('Tabs['));
    });
  });

  group('TabItem callbacks', () {
    test('activate calls activate on parent', () {
      final tabs = Tabs();
      final tab1 = TabItem();
      final tab2 = TabItem();
      tabs.add(tab1);
      tabs.add(tab2);

      tab2.activate();
      expect(tabs.activeTab, tab2);
    });

    test('detach removes tab from parent', () {
      final tabs = Tabs();
      final tab = TabItem();
      tabs.add(tab);

      tab.detach();
      expect(tabs.children, isEmpty);
    });

    test('dispose detaches and marks disposed', () {
      final tabs = Tabs();
      final tab = TestTabItem('tab-1');
      tabs.add(tab);

      tab.dispose();
      expect(tabs.children, isEmpty);
      expect(tab.disposed, isTrue);
      expect(tab.wasDisposed, isTrue);
    });

    test('replace on tab replaces it in parent', () {
      final tabs = Tabs();
      final tab1 = TabItem();
      final tab2 = TabItem();
      tabs.add(tab1);

      tab1.replace(tab2);
      expect(tabs.children, contains(tab2));
    });
  });

  group('TabsDocument', () {
    test('can be instantiated', () {
      final doc = TabsDocument();
      expect(doc, isNotNull);
    });

    test('root is null initially', () {
      final doc = TabsDocument();
      expect(doc.root, isNull);
    });

    test('setRoot sets the root container', () {
      final doc = TabsDocument();
      final tabs = Tabs();
      doc.setRoot(tabs);
      expect(doc.root, tabs);
    });

    test('setRoot with null clears root', () {
      final doc = TabsDocument();
      final tabs = Tabs();
      doc.setRoot(tabs);
      doc.setRoot(null);
      expect(doc.root, isNull);
    });

    test('activeTab is a ValueNotifier', () {
      final doc = TabsDocument();
      expect(doc.activeTab, isA<ValueNotifier<TabItem?>>());
    });

    test('activeTab is null initially', () {
      final doc = TabsDocument();
      expect(doc.activeTab.value, isNull);
    });
  });
}
