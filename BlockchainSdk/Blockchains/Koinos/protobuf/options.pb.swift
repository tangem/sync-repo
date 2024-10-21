// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: options.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

enum Koinos_bytes_type: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case base64 // = 0
  case base58 // = 1
  case hex // = 2
  case blockID // = 3
  case transactionID // = 4
  case contractID // = 5
  case address // = 6
  case UNRECOGNIZED(Int)

  init() {
    self = .base64
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .base64
    case 1: self = .base58
    case 2: self = .hex
    case 3: self = .blockID
    case 4: self = .transactionID
    case 5: self = .contractID
    case 6: self = .address
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .base64: return 0
    case .base58: return 1
    case .hex: return 2
    case .blockID: return 3
    case .transactionID: return 4
    case .contractID: return 5
    case .address: return 6
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension Koinos_bytes_type: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static let allCases: [Koinos_bytes_type] = [
    .base64,
    .base58,
    .hex,
    .blockID,
    .transactionID,
    .contractID,
    .address,
  ]
}

#endif  // swift(>=4.2)

#if swift(>=5.5) && canImport(_Concurrency)
extension Koinos_bytes_type: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Extension support defined in options.proto.

// MARK: - Extension Properties

// Swift Extensions on the exteneded Messages to add easy access to the declared
// extension fields. The names are based on the extension field name from the proto
// declaration. To avoid naming collisions, the names are prefixed with the name of
// the scope where the extend directive occurs.

extension SwiftProtobuf.Google_Protobuf_FieldOptions {

  var Koinos_btype: Koinos_bytes_type {
    get {return getExtensionValue(ext: Koinos_Extensions_btype) ?? .base64}
    set {setExtensionValue(ext: Koinos_Extensions_btype, value: newValue)}
  }
  /// Returns true if extension `Koinos_Extensions_btype`
  /// has been explicitly set.
  var hasKoinos_btype: Bool {
    return hasExtensionValue(ext: Koinos_Extensions_btype)
  }
  /// Clears the value of extension `Koinos_Extensions_btype`.
  /// Subsequent reads from it will return its default value.
  mutating func clearKoinos_btype() {
    clearExtensionValue(ext: Koinos_Extensions_btype)
  }

}

// MARK: - File's ExtensionMap: Koinos_Options_Extensions

/// A `SwiftProtobuf.SimpleExtensionMap` that includes all of the extensions defined by
/// this .proto file. It can be used any place an `SwiftProtobuf.ExtensionMap` is needed
/// in parsing, or it can be combined with other `SwiftProtobuf.SimpleExtensionMap`s to create
/// a larger `SwiftProtobuf.SimpleExtensionMap`.
let Koinos_Options_Extensions: SwiftProtobuf.SimpleExtensionMap = [
  Koinos_Extensions_btype
]

// Extension Objects - The only reason these might be needed is when manually
// constructing a `SimpleExtensionMap`, otherwise, use the above _Extension Properties_
// accessors for the extension fields on the messages directly.

let Koinos_Extensions_btype = SwiftProtobuf.MessageExtension<SwiftProtobuf.OptionalEnumExtensionField<Koinos_bytes_type>, SwiftProtobuf.Google_Protobuf_FieldOptions>(
  _protobuf_fieldNumber: 50000,
  fieldName: "koinos.btype"
)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension Koinos_bytes_type: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "BASE64"),
    1: .same(proto: "BASE58"),
    2: .same(proto: "HEX"),
    3: .same(proto: "BLOCK_ID"),
    4: .same(proto: "TRANSACTION_ID"),
    5: .same(proto: "CONTRACT_ID"),
    6: .same(proto: "ADDRESS"),
  ]
}
