//
//  NanoIDGenerator.swift
//  NanoID
//
//  Created by Shiva Huang on 2026/1/15.
//

import ConcurrencyExtras
import Foundation

/// A type that generates NanoIDs.
///
/// Use `NanoIDGenerator` to abstract NanoID creation behind a controllable interface.
/// This is particularly useful for testing, where you want deterministic IDs instead of
/// random ones.
///
/// ## Predefined Generators
///
/// The library ships with two predefined generators:
///
/// - ``constant(_:)`` always returns the same NanoID.
/// - ``incrementing(size:)`` returns zero-padded numeric IDs that count up on every call.
///
/// ## Custom Generators
///
/// You can create a generator from any closure that returns a ``NanoID``:
///
/// ```swift
/// let liveGenerator = NanoIDGenerator { NanoID() }
/// let customGenerator = NanoIDGenerator { NanoID(from: .alphanumeric, size: 12) }
/// ```
///
/// ## Calling a Generator
///
/// `NanoIDGenerator` supports `callAsFunction`, so you call it like a function:
///
/// ```swift
/// let generator = NanoIDGenerator { NanoID() }
/// let id = generator()  // Calls callAsFunction() under the hood
/// ```
///
/// ## Topics
///
/// ### Creating a Generator
///
/// - ``init(_:)``
/// - ``constant(_:)``
/// - ``incrementing(size:)``
///
/// ### Generating IDs
///
/// - ``callAsFunction()``
public struct NanoIDGenerator: Sendable {
  private let generate: @Sendable () -> NanoID

  /// A generator that always returns the given NanoID.
  ///
  /// Useful in tests when you need a completely predictable, fixed identifier.
  ///
  /// ```swift
  /// let generator = NanoIDGenerator.constant(NanoID(rawValue: "test-id")!)
  /// generator()  // NanoID("test-id")
  /// generator()  // NanoID("test-id")
  /// ```
  ///
  /// - Parameter nanoid: The NanoID to return on every call.
  /// - Returns: A generator that always returns the given NanoID.
  public static func constant(_ nanoid: NanoID) -> Self {
    Self { nanoid }
  }

  /// A generator that produces zero-padded numeric NanoIDs, incrementing on every call.
  ///
  /// Each call returns the next integer formatted as a zero-padded string of the given length.
  /// When the counter overflows the size (e.g., size 1 goes from `"9"` to `"0"`), the output
  /// wraps around using only the last `size` digits.
  ///
  /// ```swift
  /// let generator = NanoIDGenerator.incrementing(size: 3)
  /// generator()  // NanoID("000")
  /// generator()  // NanoID("001")
  /// generator()  // NanoID("002")
  /// ```
  ///
  /// - Parameter size: The character length of each generated NanoID. Must be greater than or equal to 0.
  /// - Returns: A generator that yields incrementing numeric IDs of the given size.
  /// - Precondition: `size >= 0`
  public static func incrementing(size: Int) -> Self {
    precondition(size >= 0, "size must be greater than or equal to 0")
    let generator = IncrementingNanoIDGenerator(size: size)
    return Self { generator() }
  }

  /// Initializes a NanoID generator from a closure.
  ///
  /// Use this initializer when you need a custom generation strategy, such as using a
  /// specific alphabet, a fixed size, or a seeded random number generator.
  ///
  /// ```swift
  /// // Live generator using the default alphabet
  /// let live = NanoIDGenerator { NanoID() }
  ///
  /// // Generator with a custom alphabet and size
  /// let custom = NanoIDGenerator { NanoID(from: .hexadecimalLowercase, size: 16) }
  /// ```
  ///
  /// - Parameter generate: A `@Sendable` closure that returns a new `NanoID` each time it is called.
  public init(_ generate: @escaping @Sendable () -> NanoID) {
    self.generate = generate
  }

  /// Generates and returns a NanoID.
  ///
  /// This method is called automatically when you invoke the generator as a function:
  ///
  /// ```swift
  /// let generator = NanoIDGenerator { NanoID() }
  /// let id = generator()  // Equivalent to generator.callAsFunction()
  /// ```
  public func callAsFunction() -> NanoID {
    self.generate()
  }
}

private struct IncrementingNanoIDGenerator: Sendable {
  let size: Int
  private let sequence = LockIsolated(0)

  func callAsFunction() -> NanoID {
    sequence.withValue { sequence in
      defer { sequence += 1 }
      return NanoID(
        rawValue: String(
          String(format: "%0\(size)d", locale: Locale(identifier: "en_US_POSIX"), sequence).suffix(
            size)))!
    }
  }
}
