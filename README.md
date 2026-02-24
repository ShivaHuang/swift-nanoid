# NanoID

A Swift implementation of [NanoID](https://github.com/ai/nanoid) — a tiny, secure, URL-safe unique string ID generator.

[![CI](https://github.com/ShivaHuang/swift-nanoid/actions/workflows/ci.yml/badge.svg)](https://github.com/ShivaHuang/swift-nanoid/actions/workflows/ci.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FShivaHuang%2Fswift-nanoid%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ShivaHuang/swift-nanoid)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FShivaHuang%2Fswift-nanoid%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ShivaHuang/swift-nanoid)

---

## Overview

`NanoID` generates cryptographically secure, URL-safe unique identifiers with a configurable
alphabet and length. It is a Swift port of the official
[ai/nanoid](https://github.com/ai/nanoid) JavaScript library, providing identical behavior
including support for zero-length IDs.

The default configuration produces 21-character IDs from a 64-character alphabet — compact
enough for URLs, unique enough for distributed systems.

The package ships two libraries:

- **`NanoID`** — the core `NanoID` type and `NanoIDGenerator`, with no external dependencies.
- **`NanoIDDependency`** — optional integration with
  [swift-dependencies](https://github.com/pointfreeco/swift-dependencies) by
  [Point-Free](https://www.pointfree.co), exposing `NanoIDGenerator` as a controllable
  dependency via `@Dependency(\.nanoID)`.

## Quick Start

### 1. Generate an ID

Call `NanoID()` for a default 21-character, URL-safe ID:

```swift
let id = NanoID()
print(id)  // e.g. "V1StGXR8_Z5jdHi6B-myT"
```

Customize the alphabet and size using a predefined preset or compose your own:

```swift
let hexID    = NanoID(from: .hexadecimalLowercase, size: 16)
let shortID  = NanoID(from: .alphanumeric, size: 10)
let customID = NanoID(from: .numbers + "-", size: 12)
```

### 2. Use with swift-dependencies

Add `@Dependency(\.nanoID)` to any feature model to gain controllable NanoID generation:

```swift
import Dependencies
import NanoIDDependency

final class ItemsModel {
  @Dependency(\.nanoID) var nanoID

  var items: [Item] = []

  func addButtonTapped() {
    items.append(Item(id: nanoID()))
  }
}
```

Because `NanoID` is configurable (alphabet, size), there is no built-in live value.
Register a generator in your app's composition root:

```swift
let model = withDependencies {
  $0.nanoID = NanoIDGenerator { NanoID() }
} operation: {
  ItemsModel()
}
```

### 3. Test with Controlled IDs

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

### 4. Use with IDGenerator for Multi-Use-Case Projects

If your app generates IDs for multiple, distinct purposes (e.g. user IDs, session tokens,
log filenames), consider pairing `swift-nanoid` with
[IDGenerator](https://github.com/ShivaHuang/swift-id-generator). `IDGenerator` provides
a keyed registry that lets each component declare exactly the generator it needs, keeping
different ID schemes isolated and independently controllable in tests.

> **Note:** When using `IDGenerator`, you only need the core **`NanoID`** library —
> `NanoIDDependency` is not required, as `IDGenerator` provides its own dependency
> integration.

```swift
extension GeneratorKey where Value == NanoIDGenerator {
  static let userID   = Self("userID")
  static let sessionToken = Self("sessionToken")
}

extension IDGeneratorValues {
  var userID: NanoIDGenerator {
    get { self[.userID] }
    set { self[.userID] = newValue }
  }
  var sessionToken: NanoIDGenerator {
    get { self[.sessionToken] }
    set { self[.sessionToken] = newValue }
  }
}
```

Each component then declares only what it needs:

```swift
struct UserRepository {
  @Dependency(\.idGenerators.userID) var userID
}

struct AuthService {
  @Dependency(\.idGenerators.sessionToken) var sessionToken
}
```

## Installation

Add `swift-nanoid` to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ShivaHuang/swift-nanoid", from: "0.1.0"),
],
```

Then add the product you need to your target:

- **`NanoID`** — core type and generator, no external dependencies.
- **`NanoIDDependency`** — includes `NanoID` and integrates with swift-dependencies.

```swift
.target(
    name: "MyApp",
    dependencies: [
        // Core only:
        .product(name: "NanoID", package: "swift-nanoid"),

        // Or with swift-dependencies integration:
        .product(name: "NanoIDDependency", package: "swift-nanoid"),
    ]
),
```

## Alternatives

There are other Swift implementations of NanoID in the community:

* [antiflasher/NanoID](https://github.com/antiflasher/NanoID)

## Credits

The `NanoIDDependency` module is designed to work with
[swift-dependencies](https://github.com/pointfreeco/swift-dependencies) by
[Point-Free](https://www.pointfree.co). Their library provides the dependency management
infrastructure that `NanoIDDependency` builds upon. `NanoIDGenerator` is also directly
inspired by `UUIDGenerator` from the same library.

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
