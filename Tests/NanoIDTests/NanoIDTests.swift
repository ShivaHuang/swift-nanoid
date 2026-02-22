//
//  NanoIDTests.swift
//  NanoID
//
//  Created by Shiva Huang on 2026/1/13.
//

import Foundation
import Testing

@testable import NanoID

@Suite("NanoID Tests")
struct NanoIDTests {
  // MARK: - Basic Generation Tests

  @Test("Default initialization generates 21-character ID")
  func defaultInitialization() {
    let id = NanoID()
    #expect(id.rawValue.count == 21)
    #expect(!id.rawValue.isEmpty)
  }

  @Test("Custom length generation")
  func customLength() {
    let id10 = NanoID(from: .default, size: 10)
    #expect(id10.rawValue.count == 10)

    let id50 = NanoID(from: .default, size: 50)
    #expect(id50.rawValue.count == 50)

    let id1 = NanoID(from: .default, size: 1)
    #expect(id1.rawValue.count == 1)
  }

  @Test("Custom alphabet generation")
  func customAlphabet() {
    let numericID = NanoID(from: "0123456789", size: 10)
    #expect(numericID.rawValue.count == 10)
    #expect(numericID.rawValue.allSatisfy { $0.isNumber })

    let lowercaseID = NanoID(from: .lowercase, size: 20)
    #expect(lowercaseID.rawValue.count == 20)
    #expect(lowercaseID.rawValue.allSatisfy { $0.isLowercase })
  }

  @Test("Generated IDs contain only alphabet characters")
  func alphabetConstraint() {
    let hexID = NanoID(from: .hexadecimalLowercase, size: 16)
    let validChars = Set("0123456789abcdef")
    #expect(hexID.rawValue.allSatisfy { validChars.contains($0) })
  }

  // MARK: - RawRepresentable Tests

  @Test("RawRepresentable initialization with valid string")
  func rawRepresentableValid() {
    let rawValue = "V1StGXR8_Z5jdHi6B-myT"
    let id = NanoID(rawValue: rawValue)
    #expect(id != nil)
    #expect(id?.rawValue == rawValue)
  }

  @Test("RawRepresentable initialization with empty string returns empty NanoID")
  func rawRepresentableEmpty() {
    let id = NanoID(rawValue: "")
    #expect(id != nil)
    #expect(id?.rawValue == "")
    #expect(id?.rawValue.isEmpty == true)
  }

  // MARK: - Codable Tests

  @Test("Encoding NanoID to JSON")
  func encoding() throws {
    let id = NanoID(rawValue: "test123")!
    let encoder = JSONEncoder()
    let data = try encoder.encode(id)
    let jsonString = String(data: data, encoding: .utf8)
    #expect(jsonString == "\"test123\"")
  }

  @Test("Decoding NanoID from JSON")
  func decoding() throws {
    let json = "\"test123\""
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    let id = try decoder.decode(NanoID.self, from: data)
    #expect(id.rawValue == "test123")
  }

  @Test("Round-trip encoding and decoding")
  func roundTrip() throws {
    let original = NanoID()
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    let data = try encoder.encode(original)
    let decoded = try decoder.decode(NanoID.self, from: data)

    #expect(decoded.rawValue == original.rawValue)
    #expect(decoded == original)
  }

  // MARK: - CodingKeyRepresentable Tests

  @Test("Using NanoID as dictionary keys in Codable types")
  func codingKeyRepresentable() throws {
    struct Metadata: Codable, Equatable {
      let items: [NanoID: String]
    }

    let id1 = NanoID(rawValue: "key1")!
    let id2 = NanoID(rawValue: "key2")!
    let metadata = Metadata(items: [id1: "value1", id2: "value2"])

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    let data = try encoder.encode(metadata)
    let decoded = try decoder.decode(Metadata.self, from: data)

    #expect(decoded == metadata)
    #expect(decoded.items[id1] == "value1")
    #expect(decoded.items[id2] == "value2")
  }

  // MARK: - CustomStringConvertible Tests

  @Test("Description returns rawValue")
  func customStringConvertible() {
    let id = NanoID(rawValue: "test123")!
    #expect(id.description == "test123")
    #expect(id.description == id.rawValue)
  }

  @Test("String interpolation works")
  func stringInterpolation() {
    let id = NanoID(rawValue: "abc123")!
    let urlPath = "/items/\(id)"
    #expect(urlPath == "/items/abc123")
  }

  // MARK: - Equatable & Hashable Tests

  @Test("Equality comparison")
  func equatable() {
    let id1 = NanoID(rawValue: "test123")!
    let id2 = NanoID(rawValue: "test123")!
    let id3 = NanoID(rawValue: "different")!

    #expect(id1 == id2)
    #expect(id1 != id3)
  }

  @Test("Hashable allows use in Set and Dictionary")
  func hashable() {
    let id1 = NanoID(rawValue: "test1")!
    let id2 = NanoID(rawValue: "test2")!
    let id3 = NanoID(rawValue: "test1")!  // duplicate

    let set = Set([id1, id2, id3])
    #expect(set.count == 2)  // id1 and id3 are duplicates

    let dict = [id1: "value1", id2: "value2"]
    #expect(dict[id1] == "value1")
    #expect(dict[id3] == "value1")  // Same key as id1
  }

  // MARK: - Deterministic Generation Tests

  @Test("Seeded generator produces consistent results")
  func deterministicGeneration() {
    var gen1 = SeededRandomNumberGenerator(seed: 42)
    let id1 = NanoID(using: &gen1)

    var gen2 = SeededRandomNumberGenerator(seed: 42)
    let id2 = NanoID(using: &gen2)

    #expect(id1 == id2)
    #expect(id1.rawValue == id2.rawValue)
  }

  @Test("Different seeds produce different IDs")
  func differentSeeds() {
    var gen1 = SeededRandomNumberGenerator(seed: 42)
    let id1 = NanoID(using: &gen1)

    var gen2 = SeededRandomNumberGenerator(seed: 100)
    let id2 = NanoID(using: &gen2)

    #expect(id1 != id2)
  }

  @Test("Sequential generation from same seed produces different IDs")
  func sequentialGeneration() {
    var gen = SeededRandomNumberGenerator(seed: 42)
    let id1 = NanoID(using: &gen)
    let id2 = NanoID(using: &gen)
    let id3 = NanoID(using: &gen)

    #expect(id1 != id2)
    #expect(id2 != id3)
    #expect(id1 != id3)
  }

  // MARK: - Alphabets Type Tests

  @Test("Predefined alphabets work correctly")
  func predefinedAlphabets() {
    let defaultID = NanoID(from: .default, size: 10)
    #expect(defaultID.rawValue.count == 10)

    let hexID = NanoID(from: .hexadecimalLowercase, size: 10)
    #expect(hexID.rawValue.count == 10)
    #expect(hexID.rawValue.allSatisfy { "0123456789abcdef".contains($0) })

    let numericID = NanoID(from: .numbers, size: 10)
    #expect(numericID.rawValue.allSatisfy { $0.isNumber })
  }

  @Test("String literal alphabet initialization")
  func stringLiteralAlphabet() {
    let customAlphabet: NanoID.Alphabets = "abc123"
    let id = NanoID(from: customAlphabet, size: 10)
    #expect(id.rawValue.count == 10)
    #expect(id.rawValue.allSatisfy { "abc123".contains($0) })
  }

  @Test("Alphabet composition with plus operator")
  func alphabetComposition() {
    let composed = NanoID.Alphabets.numbers + "-"
    #expect(composed.rawValue == "0123456789-")

    let id = NanoID(from: composed, size: 10)
    #expect(id.rawValue.allSatisfy { "0123456789-".contains($0) })
  }

  @Test("Alphabet composition with multiple predefined sets")
  func complexAlphabetComposition() {
    let custom = NanoID.Alphabets.lowercase + NanoID.Alphabets.numbers + "_"
    let id = NanoID(from: custom, size: 20)
    #expect(id.rawValue.count == 20)
    #expect(
      id.rawValue.allSatisfy {
        $0.isLowercase || $0.isNumber || $0 == "_"
      })
  }

  @Test("Alphabets RawRepresentable")
  func alphabetsRawRepresentable() {
    let alphabet = NanoID.Alphabets(rawValue: "abc123")
    #expect(alphabet.rawValue == "abc123")
  }

  // MARK: - Edge Cases Tests

  @Test("Single character ID")
  func singleCharacter() {
    let id = NanoID(from: .default, size: 1)
    #expect(id.rawValue.count == 1)
  }

  @Test("Very long ID")
  func veryLongID() {
    let id = NanoID(from: .default, size: 100)
    #expect(id.rawValue.count == 100)
  }

  @Test("Single character alphabet")
  func singleCharacterAlphabet() {
    let id = NanoID(from: "a", size: 10)
    #expect(id.rawValue.count == 10)
    #expect(id.rawValue == "aaaaaaaaaa")
  }

  @Test("Maximum alphabet size (256 characters)")
  func maximumAlphabet() {
    // Create a 256-character alphabet
    var chars = ""
    for i in 0..<256 {
      chars.append(Character(UnicodeScalar(i % 128 + 32)!))
    }
    let alphabet = NanoID.Alphabets(rawValue: String(chars.prefix(256)))

    let id = NanoID(from: alphabet, size: 10)
    #expect(id.rawValue.count == 10)
  }

  // MARK: - Uniqueness Tests

  @Test("Multiple generations produce different IDs")
  func multipleGenerations() {
    let id1 = NanoID()
    let id2 = NanoID()
    let id3 = NanoID()

    #expect(id1 != id2)
    #expect(id2 != id3)
    #expect(id1 != id3)
  }

  @Test("Large batch produces no duplicates")
  func largeBatchUniqueness() {
    let batchSize = 1000
    var ids = Set<NanoID>()

    for _ in 0..<batchSize {
      let id = NanoID()
      ids.insert(id)
    }

    #expect(
      ids.count == batchSize, "Expected all \(batchSize) IDs to be unique, but got \(ids.count)")
  }

  @Test("Short IDs with large alphabet maintain uniqueness")
  func shortIDUniqueness() {
    let batchSize = 100
    var ids = Set<NanoID>()

    for _ in 0..<batchSize {
      let id = NanoID(from: .default, size: 10)
      ids.insert(id)
    }

    // Allow some collisions for short IDs, but most should be unique
    let uniqueRatio = Double(ids.count) / Double(batchSize)
    #expect(uniqueRatio > 0.95, "Expected >95% uniqueness, got \(uniqueRatio * 100)%")
  }

  // MARK: - Predefined Alphabets Functional Tests

  @Test("All predefined alphabets generate valid IDs")
  func allPredefinedAlphabetsWork() {
    let alphabets: [(name: String, alphabet: NanoID.Alphabets)] = [
      ("default", .default),
      ("alphanumeric", .alphanumeric),
      ("numbers", .numbers),
      ("hexadecimalUppercase", .hexadecimalUppercase),
      ("hexadecimalLowercase", .hexadecimalLowercase),
      ("lowercase", .lowercase),
      ("uppercase", .uppercase),
      ("nolookalikes", .nolookalikes),
      ("nolookalikesSafe", .nolookalikesSafe),
      ("cookieSafe", .cookieSafe),
      ("cookieUnsafe", .cookieUnsafe),
    ]

    for (name, alphabet) in alphabets {
      let id = NanoID(from: alphabet, size: 10)
      #expect(id.rawValue.count == 10, "Alphabet '\(name)' should generate 10-character ID")
      #expect(!id.rawValue.isEmpty, "Alphabet '\(name)' should not produce empty ID")

      // Verify all characters come from the alphabet
      let isValid = id.rawValue.allSatisfy { alphabet.rawValue.contains($0) }
      #expect(isValid, "Alphabet '\(name)' produced invalid character in ID: \(id.rawValue)")
    }
  }

  // MARK: - Randomness Quality Tests

  @Test("Character distribution is reasonably uniform")
  func flatDistribution() {
    let count = 10000
    var charCounts: [Character: Int] = [:]

    // Generate many IDs and count character occurrences
    for _ in 0..<count {
      let id = NanoID(from: .default, size: 10)
      for char in id.rawValue {
        charCounts[char, default: 0] += 1
      }
    }

    let totalChars = count * 10
    let alphabetSize = NanoID.Alphabets.default.rawValue.count
    let expectedFrequency = Double(totalChars) / Double(alphabetSize)

    // Check that each character appears with reasonable frequency
    // Allow ±50% deviation (very lenient for statistical variation)
    for (char, actualCount) in charCounts {
      let deviation = abs(Double(actualCount) - expectedFrequency) / expectedFrequency
      #expect(
        deviation < 0.5,
        "Character '\(char)' appears \(actualCount) times (expected ~\(Int(expectedFrequency)), deviation: \(Int(deviation * 100))%)"
      )
    }
  }

  // MARK: - Zero-Size Edge Case

  @Test("Zero-size ID generation returns empty string")
  func zeroSizeID() {
    let id = NanoID(from: .default, size: 0)
    #expect(id.rawValue.isEmpty)
    #expect(id.rawValue == "")
    // RawRepresentable round-trip must hold for all generated values
    #expect(NanoID(rawValue: id.rawValue) == id)
  }

  // MARK: - Sendable Conformance Tests

  @Test("NanoID can be used across concurrency boundaries")
  func sendableConformance() async {
    let id = NanoID()

    // Can pass to async context
    await Task {
      #expect(id.rawValue.count == 21)
    }.value
  }

  @Test("Alphabets can be used across concurrency boundaries")
  func alphabetsSendable() async {
    let alphabet = NanoID.Alphabets.hexadecimalLowercase

    await Task {
      let id = NanoID(from: alphabet, size: 10)
      #expect(id.rawValue.count == 10)
    }.value
  }
}

// MARK: - SeededRandomNumberGenerator

/// A simple seeded random number generator for deterministic testing
struct SeededRandomNumberGenerator: RandomNumberGenerator {
  private var state: UInt64

  init(seed: UInt64) {
    self.state = seed
  }

  mutating func next() -> UInt64 {
    // Simple LCG (Linear Congruential Generator)
    state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
    return state
  }
}
