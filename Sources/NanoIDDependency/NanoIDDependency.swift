//
//  NanoIDDependency.swift
//  NanoID
//
//  Created by Shiva Huang on 2026/1/23.
//

import Dependencies
import NanoID

extension DependencyValues {
  /// A dependency that generates NanoIDs.
  ///
  /// Introduce controllable NanoID generation to your features by using the ``Dependency``
  /// property wrapper with a key path to this property. The wrapped value is an instance of
  /// ``NanoIDGenerator``, which can be called directly because it defines
  /// ``NanoIDGenerator/callAsFunction()``.
  ///
  /// For example, you could introduce controllable NanoID generation to an observable object
  /// model that creates items with unique identifiers:
  ///
  /// ```swift
  /// @Observable
  /// final class ItemsModel {
  ///   var items: [Item] = []
  ///
  ///   @ObservationIgnored
  ///   @Dependency(\.nanoID) var nanoID
  ///
  ///   func addButtonTapped() {
  ///     items.append(Item(id: nanoID()))
  ///   }
  /// }
  /// ```
  ///
  /// Unlike ``DependencyValues/uuid``, there is no default live value because `NanoID` is
  /// configurable (alphabet, size). You must explicitly register a generator in your app's
  /// composition root:
  ///
  /// ```swift
  /// let model = withDependencies {
  ///   $0.nanoID = NanoIDGenerator { NanoID() }
  /// } operation: {
  ///   ItemsModel()
  /// }
  /// ```
  ///
  /// To test a feature that depends on NanoID generation, override the generator using
  /// ``withDependencies(_:operation:)-4uz6m``:
  ///
  ///   * ``NanoIDGenerator/incrementing(size:)`` for reproducible IDs that count up numerically.
  ///   * ``NanoIDGenerator/constant(_:)`` for a generator that always returns the same NanoID.
  ///
  /// ```swift
  /// @Test
  /// func addItem() {
  ///   let model = withDependencies {
  ///     $0.nanoID = .incrementing(size: 21)
  ///   } operation: {
  ///     ItemsModel()
  ///   }
  ///
  ///   model.addButtonTapped()
  ///   #expect(model.items == [Item(id: NanoID(rawValue: "000000000000000000000")!)])
  /// }
  /// ```
  public var nanoID: NanoIDGenerator {
    get { self[NanoIDGeneratorKey.self] }
    set { self[NanoIDGeneratorKey.self] = newValue }
  }

  private enum NanoIDGeneratorKey: TestDependencyKey {
    static let testValue = NanoIDGenerator {
      unimplemented(#"@Dependency(\.nanoID)"#, placeholder: NanoID())
    }
  }
}
