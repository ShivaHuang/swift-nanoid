# ``NanoIDDependency``

Integrate NanoID generation into [swift-dependencies](https://github.com/pointfreeco/swift-dependencies).

## Overview

The `NanoIDDependency` module exposes ``NanoID/NanoIDGenerator`` as a
[swift-dependencies](https://github.com/pointfreeco/swift-dependencies) dependency via
`DependencyValues.nanoID`.

Add `@Dependency(\.nanoID)` to any feature model to gain controllable, testable NanoID generation:

```swift
@Observable
final class ItemsModel {
  var items: [Item] = []

  @ObservationIgnored
  @Dependency(\.nanoID) var nanoID

  func addButtonTapped() {
    items.append(Item(id: nanoID()))
  }
}
```

### Registering a Live Generator

Unlike `DependencyValues.uuid`, there is no built-in live value because `NanoID` is configurable
(alphabet, size). Register a generator in your app's composition root:

```swift
let model = withDependencies {
  $0.nanoID = NanoIDGenerator { NanoID() }
} operation: {
  ItemsModel()
}
```

### Testing with Controlled IDs

Override the dependency in tests for predictable, reproducible output:

```swift
@Test
func addItem() {
  let model = withDependencies {
    $0.nanoID = .incrementing(size: 21)
  } operation: {
    ItemsModel()
  }

  model.addButtonTapped()
  #expect(model.items == [Item(id: NanoID(rawValue: "000000000000000000000")!)])
}
```

## Topics

### Dependency Value

- ``NanoID/NanoIDGenerator``
- ``Dependencies/DependencyValues/nanoID``
