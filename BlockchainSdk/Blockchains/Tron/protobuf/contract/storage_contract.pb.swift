// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: core/contract/storage_contract.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
@preconcurrency import SwiftProtobuf    // TODO: Andrey Fedorov - Remove after migration to Swift 6 structured concurrency (IOS-8369)

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

struct Protocol_BuyStorageBytesContract: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var ownerAddress: Data = Data()

  /// storage bytes for buy
  var bytes: Int64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Protocol_BuyStorageContract: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var ownerAddress: Data = Data()

  /// trx quantity for buy storage (sun)
  var quant: Int64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Protocol_SellStorageContract: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var ownerAddress: Data = Data()

  var storageBytes: Int64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Protocol_UpdateBrokerageContract: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var ownerAddress: Data = Data()

  /// 1 mean 1%
  var brokerage: Int32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "protocol"

extension Protocol_BuyStorageBytesContract: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".BuyStorageBytesContract"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "owner_address"),
    2: .same(proto: "bytes"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.ownerAddress) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self.bytes) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.ownerAddress.isEmpty {
      try visitor.visitSingularBytesField(value: self.ownerAddress, fieldNumber: 1)
    }
    if self.bytes != 0 {
      try visitor.visitSingularInt64Field(value: self.bytes, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Protocol_BuyStorageBytesContract, rhs: Protocol_BuyStorageBytesContract) -> Bool {
    if lhs.ownerAddress != rhs.ownerAddress {return false}
    if lhs.bytes != rhs.bytes {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Protocol_BuyStorageContract: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".BuyStorageContract"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "owner_address"),
    2: .same(proto: "quant"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.ownerAddress) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self.quant) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.ownerAddress.isEmpty {
      try visitor.visitSingularBytesField(value: self.ownerAddress, fieldNumber: 1)
    }
    if self.quant != 0 {
      try visitor.visitSingularInt64Field(value: self.quant, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Protocol_BuyStorageContract, rhs: Protocol_BuyStorageContract) -> Bool {
    if lhs.ownerAddress != rhs.ownerAddress {return false}
    if lhs.quant != rhs.quant {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Protocol_SellStorageContract: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".SellStorageContract"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "owner_address"),
    2: .standard(proto: "storage_bytes"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.ownerAddress) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self.storageBytes) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.ownerAddress.isEmpty {
      try visitor.visitSingularBytesField(value: self.ownerAddress, fieldNumber: 1)
    }
    if self.storageBytes != 0 {
      try visitor.visitSingularInt64Field(value: self.storageBytes, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Protocol_SellStorageContract, rhs: Protocol_SellStorageContract) -> Bool {
    if lhs.ownerAddress != rhs.ownerAddress {return false}
    if lhs.storageBytes != rhs.storageBytes {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Protocol_UpdateBrokerageContract: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".UpdateBrokerageContract"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "owner_address"),
    2: .same(proto: "brokerage"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.ownerAddress) }()
      case 2: try { try decoder.decodeSingularInt32Field(value: &self.brokerage) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.ownerAddress.isEmpty {
      try visitor.visitSingularBytesField(value: self.ownerAddress, fieldNumber: 1)
    }
    if self.brokerage != 0 {
      try visitor.visitSingularInt32Field(value: self.brokerage, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Protocol_UpdateBrokerageContract, rhs: Protocol_UpdateBrokerageContract) -> Bool {
    if lhs.ownerAddress != rhs.ownerAddress {return false}
    if lhs.brokerage != rhs.brokerage {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
