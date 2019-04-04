@JS()
library react.lifecycle_test.component2;

import "package:js/js.dart";
import 'package:react/react.dart' as react;
import 'package:react/react_client.dart';

import 'util.dart';

ReactDartComponentFactoryProxy2 SetStateTest = react.registerComponent(() => new _SetStateTest());

class _SetStateTest extends react.Component2 with LifecycleTestHelper {
  @override
  Map getDefaultProps() => {'shouldUpdate': true};

  @override
  getInitialState() => {"counter": 1};

  @override
  Map getDerivedStateFromProps(_, __) {
    recordLifecyleCall('getDerivedStateFromProps');
    return new Map();
  }

  @override
  getSnapshotBeforeUpdate(_, __) {
    recordLifecyleCall('getSnapshotBeforeUpdate');
  }

  @override
  componentDidUpdate(_, __, [___]) {
    recordLifecyleCall('componentDidUpdate');
  }

  @override
  shouldComponentUpdate(_, __, [___]) {
    recordLifecyleCall('shouldComponentUpdate');
    return props['shouldUpdate'] as bool;
  }

  Map outerTransactionalSetStateCallback(Map previousState, __) {
    recordLifecyleCall('outerTransactionalSetStateCallback');
    return {'counter': previousState['counter'] + 1};
  }

  Map innerTransactionalSetStateCallback(Map previousState, __) {
    recordLifecyleCall('innerTransactionalSetStateCallback');
    return {'counter': previousState['counter'] + 1};
  }

  void recordLifecyleCall(String name) {
    // TODO update this class to use lifecycleCall instead
    lifecycleCalls.add(name);
  }

  render() {
    recordLifecyleCall('render');

    return react.div(
      {
        'onClick': (_) {
          setStateWithUpdater(outerTransactionalSetStateCallback, () {
            recordLifecyleCall('outerSetStateCallback');
          });
        }
      },
      react.div({
        'onClick': (_) {
          setStateWithUpdater(innerTransactionalSetStateCallback, () {
            recordLifecyleCall('innerSetStateCallback');
          });
        }
      }, state['counter']),
    );
  }
}

_DefaultPropsCachingTest defaultPropsCachingTestComponentFactory() => new _DefaultPropsCachingTest();

class _DefaultPropsCachingTest extends react.Component2 implements DefaultPropsCachingTestHelper {
  static int getDefaultPropsCallCount = 0;

  int get staticGetDefaultPropsCallCount => getDefaultPropsCallCount;

  @override
  set staticGetDefaultPropsCallCount(int value) => getDefaultPropsCallCount = value;

  Map getDefaultProps() {
    getDefaultPropsCallCount++;
    return {'getDefaultPropsCallCount': getDefaultPropsCallCount};
  }

  render() => false;
}

ReactDartComponentFactoryProxy2 DefaultPropsTest = react.registerComponent(() => new _DefaultPropsTest());

class _DefaultPropsTest extends react.Component2 {
  static int getDefaultPropsCallCount = 0;

  Map getDefaultProps() => {'defaultProp': 'default'};

  render() => false;
}

ReactDartContext LifecycleTestContext = createContext();

ReactDartComponentFactoryProxy2 ContextConsumerWrapper = react.registerComponent(() => new _ContextConsumerWrapper());

class _ContextConsumerWrapper extends react.Component2 with LifecycleTestHelper {
  dynamic render() {
    return LifecycleTestContext.Consumer({}, props['children'].first);
  }
}

ReactDartComponentFactoryProxy2 ContextWrapper = react.registerComponent(() => new _ContextWrapper());

class _ContextWrapper extends react.Component2 with LifecycleTestHelper {
  dynamic render() {
    return LifecycleTestContext.Provider(
      {
        'value': {'foo': props['foo']}
      },
      props['children'],
    );
  }
}

ReactDartComponentFactoryProxy2 LifecycleTestWithContext =
    react.registerComponent(() => new _LifecycleTestWithContext());

class _LifecycleTestWithContext extends _LifecycleTest {
  @override
  get contextType => LifecycleTestContext;
}

ReactDartComponentFactoryProxy2 LifecycleTest = react.registerComponent(() => new _LifecycleTest());

class _LifecycleTest extends react.Component2 with LifecycleTestHelper {
  void componentWillMount() => lifecycleCall('componentWillMount');
  void componentDidMount() => lifecycleCall('componentDidMount');
  void componentWillUnmount() => lifecycleCall('componentWillUnmount');

  Map getDerivedStateFromProps(nextProps, prevState) => lifecycleCall('getDerivedStateFromProps',
      arguments: [new Map.from(nextProps), new Map.from(prevState)], staticProps: nextProps);

  void componentWillUpdate(nextProps, nextState) =>
      lifecycleCall('componentWillUpdate', arguments: [new Map.from(nextProps), new Map.from(nextState)]);

  dynamic getSnapshotBeforeUpdate(prevProps, prevState) =>
      lifecycleCall('getSnapshotBeforeUpdate', arguments: [new Map.from(prevProps), new Map.from(prevState)]);

  void componentDidUpdate(prevProps, prevState, [snapshot]) =>
      lifecycleCall('componentDidUpdate', arguments: [new Map.from(prevProps), new Map.from(prevState), snapshot]);

  bool shouldComponentUpdate(nextProps, nextState, [nextContext]) => lifecycleCall('shouldComponentUpdate',
      arguments: [new Map.from(nextProps), new Map.from(nextState), nextContext], defaultReturnValue: () => true);

  dynamic render() => lifecycleCall('render', defaultReturnValue: () => react.div({}));

  Map getInitialState() => lifecycleCall('getInitialState', defaultReturnValue: () => {});

  Map getDefaultProps() {
    lifecycleCall('getDefaultProps');

    return {'defaultProp': 'default'};
  }
}
