// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myRepositoryHash() => r'f60f56f53e1042b2719118d50e02a2134f095fd5';

/// See also [myRepository].
@ProviderFor(myRepository)
final myRepositoryProvider = AutoDisposeProvider<MyRepository>.internal(
  myRepository,
  name: r'myRepositoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyRepositoryRef = AutoDisposeProviderRef<MyRepository>;
String _$counterHash() => r'f915d09ac88f54b0ee6665ded639a2958c7461b4';

/// See also [counter].
@ProviderFor(counter)
final counterProvider = AutoDisposeFutureProvider<int>.internal(
  counter,
  name: r'counterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$counterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CounterRef = AutoDisposeFutureProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
