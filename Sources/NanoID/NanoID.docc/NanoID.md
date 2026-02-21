# ``NanoID``

A Swift implementation of the NanoID unique ID generator.

## Overview

The `NanoID` module is a Swift port of the official [ai/nanoid](https://github.com/ai/nanoid)
JavaScript library. It generates URL-safe, cryptographically secure, unique string identifiers
with a customizable alphabet and length.

The default configuration produces 21-character IDs from a 64-character alphabet, providing
collision resistance suitable for distributed systems.

```swift
let id = NanoID()
print(id)  // Example: "V1StGXR8_Z5jdHi6B-myT"
```

### Customizing Generation

Use a predefined ``NanoID/Alphabets`` preset or compose your own with the `+` operator:

```swift
// Hexadecimal ID
let hexID = NanoID(from: .hexadecimalLowercase, size: 16)

// Custom composed alphabet
let customID = NanoID(from: .numbers + "-", size: 10)
```

### Deterministic Generation

For testing, pass any `RandomNumberGenerator` to produce reproducible IDs:

```swift
var generator = SeededRandomNumberGenerator(seed: 42)
let id1 = NanoID(using: &generator)
// id1 is always the same for seed 42
```

### Controllable Generation via NanoIDGenerator

For dependency-injected architectures, use ``NanoIDGenerator`` to abstract ID creation:

```swift
let generator = NanoIDGenerator { NanoID() }
let id = generator()
```

Use ``NanoIDGenerator/incrementing(size:)`` in tests for predictable sequences:

```swift
let testGenerator = NanoIDGenerator.incrementing(size: 21)
testGenerator()  // NanoID("000000000000000000000")
testGenerator()  // NanoID("000000000000000000001")
```

## Topics

### Identifier

- ``NanoID``

### Creating IDs

- ``NanoID/init()``
- ``NanoID/init(from:size:)``
- ``NanoID/init(from:size:using:)``
- ``NanoID/init(rawValue:)``

### Alphabets

- ``NanoID/Alphabets``

### Controllable Generation

- ``NanoIDGenerator``
