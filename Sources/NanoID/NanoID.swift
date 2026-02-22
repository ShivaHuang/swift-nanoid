//
//  NanoID.swift
//  NanoID
//
//  Created by Shiva Huang on 2026/1/9.
//

/// A cryptographically secure unique string identifier.
///
/// `NanoID` generates URL-safe random identifiers with customizable alphabet and length.
/// The default configuration produces 21-character IDs using a 64-character alphabet,
/// providing collision resistance suitable for distributed systems.
///
/// ## Overview
///
/// Use `NanoID` when you need unique identifiers that are:
/// - **URL-safe**: Contains only alphanumeric characters, underscore, and hyphen
/// - **Compact**: Shorter than UUID while maintaining collision resistance
/// - **Readable**: Human-readable format without special encoding
///
/// ## Collision Probability
///
/// With default settings (21 characters, 64-character alphabet):
/// - ~149 years needed for 1% collision probability at 1000 IDs/hour
/// - ~62 billion years for 1% collision probability at 1 ID/second
///
/// Calculate collision probability for custom configurations at:
/// [Nano ID Collision Calculator](https://zelark.github.io/nano-id-cc/)
///
/// ## Usage
///
/// ### Basic Usage
///
/// ```swift
/// // Generate a new ID
/// let id = NanoID()
/// print(id)  // Example: "V1StGXR8_Z5jdHi6B-myT"
///
/// // String interpolation
/// let urlPath = "/items/\(id)"
/// ```
///
/// ### Custom Alphabet
///
/// ```swift
/// // Numeric IDs only
/// let numericID = NanoID(from: "0123456789", size: 10)
///
/// // Lowercase alphanumeric
/// let simpleID = NanoID(from: "abcdefghijklmnopqrstuvwxyz0123456789", size: 16)
/// ```
///
/// ### Deterministic Generation (Testing)
///
/// ```swift
/// var generator = SeededRandomNumberGenerator(seed: 42)
/// let testID = NanoID(using: &generator)
/// ```
///
/// ### Using as Dictionary Keys
///
/// ```swift
/// struct Item: Codable {
///     let metadata: [NanoID: String]
/// }
/// ```
///
/// ## Important Notes
///
/// - Alphabet must contain 256 or fewer unique characters
/// - Duplicate characters in the alphabet increase their selection probability
/// - Empty strings are valid IDs; `NanoID(rawValue: "")` succeeds and mirrors `nanoid(0)` in JS
/// - IDs are case-sensitive
///
/// ## Topics
///
/// ### Creating IDs
///
/// - ``init()``
/// - ``init(from:size:)``
/// - ``init(from:size:using:)``
/// - ``init(rawValue:)``
///
/// ### Inspecting IDs
///
/// - ``rawValue``
public struct NanoID: Equatable, Hashable, Sendable, RawRepresentable {
  /// The string value of the identifier.
  ///
  /// This property is exposed as part of the `RawRepresentable` protocol conformance.
  /// In most cases, you should work with `NanoID` values directly rather than accessing
  /// the raw string. The type provides `CustomStringConvertible` for printing and
  /// string interpolation, and `Codable` for serialization.
  ///
  /// Access `rawValue` directly only when you need the underlying string for specific
  /// operations that require a concrete `String` type, such as:
  /// - Sorting by string value: `ids.sorted(by: \.rawValue)`
  /// - Passing to APIs that require `String` parameters
  /// - Custom comparison operations
  ///
  /// ```swift
  /// let ids = [NanoID(), NanoID(), NanoID()]
  ///
  /// // Sort by string value (NanoID itself is not Comparable)
  /// let sorted = ids.sorted { $0.rawValue < $1.rawValue }
  ///
  /// // For most use cases, work with the ID directly:
  /// print(id)              // ✅ Uses CustomStringConvertible
  /// let url = "/items/\(id)"  // ✅ String interpolation
  /// let json = try encode(id) // ✅ Uses Codable
  /// ```
  public let rawValue: String

  /// Creates a NanoID from an existing string value.
  ///
  /// Use this initializer to reconstruct a NanoID from a previously generated
  /// string, such as when decoding from a database or API response.
  ///
  /// - Parameter rawValue: The string value to wrap as a NanoID.
  ///
  /// - Returns: A NanoID wrapping the provided string.
  ///
  /// ```swift
  /// // Valid ID
  /// let id = NanoID(rawValue: "V1StGXR8_Z5jdHi6B-myT")
  ///
  /// // Zero-length ID (mirrors nanoid(0) in the JS reference implementation)
  /// let empty = NanoID(rawValue: "")
  /// ```
  public init?(rawValue: String) {
    self.rawValue = rawValue
  }

  /// Generates a new random NanoID with custom alphabet and length.
  ///
  /// Use this initializer when you need IDs with specific character sets or lengths.
  /// The method uses the system's cryptographically secure random number generator.
  ///
  /// - Parameters:
  ///   - alphabets: The alphabet string to use for generating the ID.
  ///     Each character position has equal probability of selection.
  ///     Duplicate characters increase their selection probability proportionally.
  ///     Must contain 256 or fewer characters.
  ///     Default is URL-safe 64-character alphabet: digits, lowercase, uppercase, underscore, hyphen.
  ///   - size: The length of the generated ID in characters.
  ///     Must be greater than or equal to 0. Default is 21 characters.
  ///
  /// - Precondition: `size >= 0`
  /// - Precondition: `!alphabets.isEmpty && alphabets.count <= 256`
  ///
  /// ## Examples
  ///
  /// ```swift
  /// // Numeric-only ID
  /// let numericID = NanoID(from: "0123456789", size: 10)
  ///
  /// // Short ID with default alphabet
  /// let shortID = NanoID(from: "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-", size: 12)
  ///
  /// // Custom alphabet (lowercase only)
  /// let simpleID = NanoID(from: "abcdefghijklmnopqrstuvwxyz", size: 16)
  /// ```
  ///
  /// - Note: Shorter IDs or smaller alphabets increase collision probability.
  ///   Use the [Nano ID Collision Calculator](https://zelark.github.io/nano-id-cc/)
  ///   to verify your configuration meets security requirements.
  ///
  /// - Warning: If `alphabets` contains duplicate characters, those characters
  ///   will appear more frequently in generated IDs. For example, "aab" gives
  ///   'a' a 2/3 probability versus 'b' at 1/3 probability.
  public init(
    from alphabets: Alphabets = .default,
    size: Int = 21
  ) {
    var generator = SystemRandomNumberGenerator()
    self.rawValue = Self.generate(from: alphabets, size: size, using: &generator)
  }

  /// Generates a new NanoID with custom alphabet, length, and random number generator.
  ///
  /// Use this initializer for deterministic ID generation in tests or when you need
  /// control over the random number generation process.
  ///
  /// - Parameters:
  ///   - alphabets: The alphabet string to use for generating the ID.
  ///     Each character position has equal probability of selection.
  ///     Duplicate characters increase their selection probability proportionally.
  ///     Must contain 256 or fewer characters.
  ///     Default is URL-safe 64-character alphabet: digits, lowercase, uppercase, underscore, hyphen.
  ///   - size: The length of the generated ID in characters.
  ///     Must be greater than or equal to 0. Default is 21 characters.
  ///   - generator: A random number generator to use for ID generation.
  ///     Passed as `inout` to maintain generator state across calls.
  ///
  /// - Precondition: `size >= 0`
  /// - Precondition: `!alphabets.isEmpty && alphabets.count <= 256`
  ///
  /// ## Examples
  ///
  /// ```swift
  /// // Deterministic generation for testing
  /// var testGenerator = SeededRandomNumberGenerator(seed: 42)
  /// let id1 = NanoID(using: &testGenerator)
  /// let id2 = NanoID(using: &testGenerator)
  /// // id1 and id2 are different but deterministic
  ///
  /// // Reset generator for reproducible sequence
  /// testGenerator = SeededRandomNumberGenerator(seed: 42)
  /// let id3 = NanoID(using: &testGenerator)
  /// // id3 == id1 (same seed produces same first ID)
  /// ```
  ///
  /// - Note: For production use, prefer ``init()`` or ``init(from:size:)``
  ///   which use cryptographically secure random generation.
  public init<T: RandomNumberGenerator>(
    from alphabets: Alphabets = .default,
    size: Int = 21,
    using generator: inout T
  ) {
    self.rawValue = Self.generate(from: alphabets, size: size, using: &generator)
  }

  private static func generate<T: RandomNumberGenerator>(
    from alphabets: Alphabets,
    size: Int = 21,
    using generator: inout T
  ) -> String {
    precondition(size >= 0)
    precondition(!alphabets.rawValue.isEmpty && alphabets.rawValue.count <= 256)

    // Handle zero-size ID generation
    guard size > 0 else {
      return ""
    }

    let alphabets = Array(alphabets.rawValue)
    let mask = (1 << (8 - UInt8(alphabets.count - 1).leadingZeroBitCount)) - 1

    // Ensure steps is at least size to handle edge cases like single-character alphabets
    let steps = max(size, Int((1.6 * Double(mask * size) / Double(alphabets.count)).rounded(.up)))

    var id = [Character]()
    id.reserveCapacity(size)

    @inline(__always)
    func fillRandomBytes(_ bytes: inout [UInt8], using generator: inout T) {
      var i = 0
      while i < bytes.count {
        var x = generator.next()  // UInt64
        for _ in 0..<8 {
          if i == bytes.count { return }
          bytes[i] = UInt8(truncatingIfNeeded: x)
          x >>= 8
          i += 1
        }
      }
    }

    while id.count < size {
      var bytes = [UInt8](repeating: 0, count: steps)
      fillRandomBytes(&bytes, using: &generator)

      for b in bytes {
        let idx = Int(b & UInt8(mask))
        if idx < alphabets.count {
          id.append(alphabets[idx])
          if id.count == size { break }
        }
      }
    }

    return String(id)
  }
}

// MARK: - Codable Conformance

/// Enables automatic JSON encoding and decoding.
///
/// NanoID encodes to and decodes from a plain string value:
///
/// ```swift
/// let id = NanoID()
/// let json = try JSONEncoder().encode(id)
/// // JSON: "V1StGXR8_Z5jdHi6B-myT"
///
/// let decoded = try JSONDecoder().decode(NanoID.self, from: json)
/// // decoded.rawValue == id.rawValue
/// ```
extension NanoID: Codable {}

// MARK: - CodingKeyRepresentable Conformance

/// Enables use as dictionary keys in Codable types.
///
/// This allows NanoID to be used as keys in dictionaries that are encoded/decoded:
///
/// ```swift
/// struct Metadata: Codable {
///     let items: [NanoID: String]
/// }
///
/// let metadata = Metadata(items: [
///     NanoID(): "value1",
///     NanoID(): "value2"
/// ])
///
/// let json = try JSONEncoder().encode(metadata)
/// // Dictionary keys are encoded as their string values
/// ```
extension NanoID: CodingKeyRepresentable {}

// MARK: - CustomStringConvertible Conformance

/// Provides string representation for printing and debugging.
///
/// The description returns the raw ID string:
///
/// ```swift
/// let id = NanoID()
/// print(id)           // Prints: V1StGXR8_Z5jdHi6B-myT
/// print("ID: \(id)")  // Prints: ID: V1StGXR8_Z5jdHi6B-myT
/// ```
extension NanoID: CustomStringConvertible {
  public var description: String {
    rawValue
  }
}

extension NanoID {
  public struct Alphabets: RawRepresentable, ExpressibleByStringLiteral, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
      self.rawValue = value
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
      .init(rawValue: lhs.rawValue + rhs.rawValue)
    }
  }
}

// MARK: - Predefined Alphabets

/// Predefined alphabet collections for common use cases.
///
/// These alphabet presets cover common ID generation scenarios, from standard URL-safe IDs
/// to specialized formats like hexadecimal or human-friendly strings without lookalike characters.
///
/// These alphabets are sourced from the [nanoid-dictionary](https://github.com/CyberAP/nanoid-dictionary)
/// project, which provides well-tested character sets for various use cases.
///
/// ## Usage
///
/// ```swift
/// // Use predefined alphabets
/// let hexID = NanoID(from: .hexadecimalLowercase, size: 16)
/// let readableID = NanoID(from: .nolookalikes, size: 12)
///
/// // Compose custom alphabets
/// let customAlphabet = .numbers + "-"
/// let dashSeparatedID = NanoID(from: customAlphabet, size: 10)
/// ```
extension NanoID.Alphabets {
  /// Default URL-safe alphabet: digits, lowercase, uppercase, underscore, and hyphen.
  ///
  /// Contains 64 characters: `0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-`
  public static let `default`: Self = alphanumeric + "_-"

  /// Uppercase letters A-Z (26 characters).
  public static let uppercase: Self = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

  /// Lowercase letters a-z (26 characters).
  public static let lowercase: Self = "abcdefghijklmnopqrstuvwxyz"

  /// Decimal digits 0-9 (10 characters).
  public static let numbers: Self = "0123456789"

  /// Alphanumeric characters: digits + lowercase + uppercase (62 characters).
  public static let alphanumeric: Self = numbers + lowercase + uppercase

  /// Hexadecimal uppercase: 0-9 and A-F (16 characters).
  public static let hexadecimalUppercase: Self = numbers + "ABCDEF"

  /// Hexadecimal lowercase: 0-9 and a-f (16 characters).
  public static let hexadecimalLowercase: Self = numbers + "abcdef"

  /// Human-friendly alphabet excluding lookalike characters (49 characters).
  ///
  /// Excludes: `0` (zero), `1` (one), `2`, `5`, `I` (capital i), `O` (capital o),
  /// `S`, `Z`, `l` (lowercase L), `o` (lowercase o), `s` (lowercase s), `u`, `v`
  ///
  /// Useful for IDs that will be manually typed or communicated verbally.
  public static let nolookalikes: Self = "346789ABCDEFGHJKLMNPQRTUVWXYabcdefghijkmnpqrtwxyz"

  /// Extra-safe human-friendly alphabet with aggressive lookalike exclusion (34 characters).
  ///
  /// More restrictive than ``nolookalikes``, removing additional ambiguous characters.
  /// Best for high-security contexts like temporary passwords or support tickets.
  public static let nolookalikesSafe: Self = "6789BCDFGHJKLMNPQRTWbcdfghjkmnpqrtwz"

  /// Cookie-safe characters per RFC 6265 (78 characters).
  ///
  /// Contains alphanumeric characters plus `!#$%&'*+-.^_`|~` which are allowed
  /// in HTTP cookie values without requiring encoding. Use this alphabet when
  /// generating IDs that will be stored in cookies.
  ///
  /// Reference: [RFC 6265 - HTTP State Management Mechanism](https://tools.ietf.org/html/rfc6265)
  public static let cookieSafe: Self = alphanumeric + "!#$%&'*+-.^_`|~"

  /// Extended cookie-compatible characters including more punctuation (90 characters).
  ///
  /// Contains all printable ASCII characters that are technically valid in cookies,
  /// though some may require URL encoding in certain contexts. Includes: `!#$%&'()*+-./:<=>?@[]^_`{|}~`
  ///
  /// Use ``cookieSafe`` instead if you want to avoid potential encoding issues.
  public static let cookieUnsafe: Self = alphanumeric + "!#$%&'()*+-./:<=>?@[]^_`{|}~"
}
