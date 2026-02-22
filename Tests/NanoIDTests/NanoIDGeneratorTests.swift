//
//  NanoIDGeneratorTests.swift
//  NanoID
//
//  Created by Shiva Huang on 2026/1/15.
//

import Foundation
import Testing

@testable import NanoID
@testable import NanoIDDependency

@Suite("NanoIDGenerator Tests")
struct NanoIDGeneratorTests {
  @Test("IncrementingNanoIDGenerator")
  func incrementingNanoIDGenerator() {
    let generator = NanoIDGenerator.incrementing(size: 3)

    #expect(generator() == NanoID(rawValue: "000"))
    #expect(generator() == NanoID(rawValue: "001"))
    #expect(generator() == NanoID(rawValue: "002"))
  }

  @Test("IncrementingNanoIDGenerator 2")
  func incrementingNanoIDGenerator_2() {
    let generator = NanoIDGenerator.incrementing(size: 1)

    #expect(generator() == NanoID(rawValue: "0"))
    #expect(generator() == NanoID(rawValue: "1"))
    #expect(generator() == NanoID(rawValue: "2"))
    #expect(generator() == NanoID(rawValue: "3"))
    #expect(generator() == NanoID(rawValue: "4"))
    #expect(generator() == NanoID(rawValue: "5"))
    #expect(generator() == NanoID(rawValue: "6"))
    #expect(generator() == NanoID(rawValue: "7"))
    #expect(generator() == NanoID(rawValue: "8"))
    #expect(generator() == NanoID(rawValue: "9"))
    #expect(generator() == NanoID(rawValue: "0"))
    #expect(generator() == NanoID(rawValue: "1"))
  }

  @Test("ConstantNanoIDGenerator")
  func constantNanoIDGenerator() {
    let generator = NanoIDGenerator.constant(NanoID(rawValue: "test")!)

    #expect(generator() == NanoID(rawValue: "test"))
  }
}
