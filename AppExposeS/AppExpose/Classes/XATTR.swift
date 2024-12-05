//
//  XATTR.swift
//  xattr
//
//  Created by Dave Carlton on 9/4/22.
//

import Cocoa
import Foundation
enum XATTROptions: Int {
    case nofollow = 0x0001 // Don't follow symbolic links
    // Options for setxattr calls
    case create = 0x0002 // set the value, fail if attr already exists
    case replace = 0x0004 // set the value, fail if attr does not exist
    // Set this to bypass authorization checking (eg. if doing auth-related work)
    case nosecurity = 0x0008
    // Set this to bypass the default extended attribute file (dot-underscore file)
    case nodefault = 0x0010
    // option for f/getxattr() and f/listxattr() to expose the HFS Compression extended attributes
    case showcompressions = 0x0020
}

@MainActor var errorDescription: String?
// Make and return custom domain error.
// var underlyingError = NSError(domain: NSPOSIXErrorDomain, code: errno, userInfo: nil)
// var objArray = [errorDescription, underlyingError, url?.path]
// var keyArray = [NSLocalizedDescriptionKey, NSUnderlyingErrorKey, NSFilePathErrorKey]
// var eDict = NSDictionary(objects:objArray, forKeys:keyArray as [NSCopying]) as Dictionary
// let path = Int8((url?.path as NSString?).fileSystemRepresentation ?? 0)
// var bufferSize = listxattr(path, nil, 0, options.rawValue) // find out the buffer size.
/*    LISTXATTR:
 The listxattr function fills the allocated text buffer with a list of attribute names,
 seperated by the null character ('\0').
 The function returns the number of attributes.
 */

// var listBuffer = malloc(bufferSize)
// var listLength = listxattr(path, listBuffer, bufferSize, options.rawValue)
// var n = 0 // a character scanner counter.
// var nameStart = 0 // the index position of each name.
// var attributesArray = [AnyHashable](repeating: 0, count: 0)
////listLength
// var item = Int8(listBuffer?[nameStart] ?? 0) // return a pointer to the name...
// var keyName = NSNumber(value: item) as? String
////attributesArray
// var xattributes = [AnyHashable : Any](minimumCapacity: 0)
// let path = Int8((url?.path as NSString?).fileSystemRepresentation ?? 0)
// var bufferSize = listxattr(path, nil, 0, options.rawValue) // find out the buffer size.
////xattributes
////xattributes
/// *    LISTXATTR:
// The listxattr function fills the allocated text buffer with a list of attribute names,
// seperated by the null character ('\0').
// */
//
// var buffer = UnsafeMutablePointer<Int8>(mutating: Int8(malloc(size_t(bufferSize))))
////xattributes
// var listLength = listxattr(path, buffer, size_t(bufferSize), options.rawValue)
////xattributes
////xattributes
// var allKeys = String(bytes: buffer, encoding: .utf8)
// var keys = allKeys?.components(separatedBy: "\0")
// var values = [AnyHashable](repeating: 0, count: 1)
// var keyString: String?
// let item = Int8((keyString as NSString?)?.cString(using: String.Encoding.utf8.rawValue) ?? 0)
////xattributes
// var valueLength = getxattr(path, item, buffer, size_t(bufferSize), 0, options.rawValue)
// var attrData = Data(bytes: buffer, length: Int(valueLength))
////xattributes
// let aPath = Int8((url?.path as NSString?).cString(using: String.Encoding.utf8.rawValue) ?? 0)
// let aKey = Int8(aAttribute.cString(using: String.Encoding.utf8.rawValue) ?? 0)
//// double check to see that it does not exist.
// var size = getxattr(aPath, aKey, nil, 0, 0, options.rawValue)
////EPERM
////EINVAL
// let aPath = Int8((url?.path as NSString?).cString(using: String.Encoding.utf8.rawValue) ?? 0)
// let aKey = Int8(aAttribute.cString(using: String.Encoding.utf8.rawValue) ?? 0)
// let aValue = Int8(xValue.cString(using: String.Encoding.utf8.rawValue) ?? 0)
// var result = setxattr(aPath, aKey, aValue, size_t(xValue.length), 0, options.rawValue)
////EINVAL
// var result: Any?

class XATTR: NSObject {
    var url: URL
    var options: XATTROptions
    var resultError: Error?
    var attributes: [String]
    private(set) var keysValues: [AnyHashable: Any]?

    init(url: URL, options: XATTROptions) {
        self.url = url
        self.options = options
        attributes = [] // Initialize with an empty dictionary
        super.init()
        attributes = listXattrs()
    }

    required init(path: String?, options: XATTROptions) {
        url = URL(fileURLWithPath: path!)
        self.options = options
        attributes = [] // Initialize with an empty dictionary
        super.init()
        attributes = listXattrs()
    }

    let VERBOSE = 0x0020
    let SYMBOLIC = XATTR_NOFOLLOW
    let REPLACE = XATTR_REPLACE
    let CREATE = XATTR_CREATE

    func listXattrs() -> [String] {
        let pathCString = url.path.cString(using: .utf8)!
        var size = listxattr(pathCString, nil, 0, 0)

        guard size > 0 else { return [] }

        var namebuf = [CChar](repeating: 0, count: size)
        size = listxattr(pathCString, &namebuf, size, 0)

        guard size > 0 else { return [] }
        
        var xattrs: [String] = []
        var index = 0
        while index < size {
            let attr = namebuf[index...].withUnsafeBufferPointer { buffer in
                buffer.withMemoryRebound(to: UInt8.self) { (reboundBuffer: UnsafeBufferPointer<UInt8>) -> String? in
                    String(cString: reboundBuffer.baseAddress!)
                }
            }
            
            if let attr = attr {
                xattrs.append(attr)
                index += attr.utf8.count + 1 // +1 for null terminator
            } else {
                break
            }
        }
        return xattrs
    }

    func setXattr(name: String, value: Data) throws {
        let result = value.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> Int32 in
            setxattr(url.path, name, pointer.baseAddress, value.count, 0, 0)
        }
        if result == -1 {
            throw POSIXError(POSIXErrorCode(rawValue: errno)!)
        }
        attributes.append(name)
    }

    func getXattr(name: String) throws -> Data {
        let size = getxattr(url.path, name, nil, 0, 0, 0)
        if size == -1 {
            throw POSIXError(POSIXErrorCode(rawValue: errno)!)
        }

        var data = Data(count: size)
        let result = data.withUnsafeMutableBytes { (pointer: UnsafeMutableRawBufferPointer) -> Int in
            getxattr(url.path, name, pointer.baseAddress, size, 0, 0)
        }
        if result == -1 {
            throw POSIXError(POSIXErrorCode(rawValue: errno)!)
        }
        return data
    }

    func removeXattr(name: String) throws {
        let result = removexattr(url.path, name, 0)
        if result == -1 {
            throw POSIXError(POSIXErrorCode(rawValue: errno)!)
        }
        attributes.removeAll(where: { $0 == name })
    }

//    func displayXattrKeys(path: String, options: Int32) -> Int32 {
//        var result: Int32 = 0
//
//        // Get the buffer size
//        let bufferSize = listxattr(path, nil, 0, options)
//
//        if bufferSize < 0 || bufferSize == -1 {
//            perror(nil)
//            return errno
//        }
//
//        // Allocate buffer
//        var listBuffer = [Int8](repeating: 0, count: Int(bufferSize))
//
//        // Get the list of attributes
//        let listLength = listxattr(path, &listBuffer, bufferSize, options)
//
//        var nameStart = 0
//
//        for n in 0..<Int(listLength) {
//            if listBuffer[n] == 0 { // Null terminator
//                let item = String(cString: Array(listBuffer[nameStart..<n]))
//                nameStart = n + 1
//
//                if (options & Int32(VERBOSE)) != 0 {
//                    result |= Int32(displayXattrValue(path: path, item: item, options: options))
//                } else {
//                    print("\(path): \(item)")
//                }
//            }
//        }
//
//        return result
//    }
    func displayXattrValue(_ path: UnsafePointer<Int8>?, _ key: UnsafePointer<Int8>?, _ options: Int8) -> Int {
        return 0
    }

    func setXattrValue(_ path: UnsafePointer<Int8>?, _ key: UnsafePointer<Int8>?, _ value: UnsafePointer<Int8>?, _ options: Int8) -> Int {
        return 0
    }

    func deleteXattr(_ path: UnsafePointer<Int8>?, _ key: UnsafePointer<Int8>?, _ options: Int8) -> Int {
        return 0
    }

    func getKeysValues() -> [String: Any] {
        var xattributes: [String: Any] = [:]

        let cPath = FileManager.default.fileSystemRepresentation(withPath: url.path)
        var bufferSize = listxattr(cPath, nil, 0, Int32(options.rawValue))

        if bufferSize == -1 {
            if ifErrno("could not get size for keys") {
                return xattributes
            }
        }

        if bufferSize == 0 {
            return xattributes
        }

        guard let buffer = malloc(Int(bufferSize)) else {
            if ifErrno("could not allocate memory for keys") {
                return xattributes
            }
            return xattributes
        }
        defer { free(buffer) }

        let listLength = listxattr(cPath, buffer.assumingMemoryBound(to: Int8.self), Int(bufferSize), Int32(options.rawValue))
        if listLength == 0 {
            return xattributes
        }
        if listLength == -1 {
            if ifErrno("error getting keys") {
                return xattributes
            }
        }

        let allKeys = String(cString: buffer.assumingMemoryBound(to: Int8.self))
        let keys = allKeys.components(separatedBy: "\0").filter { !$0.isEmpty }

        var values: [Data] = []

        for keyString in keys {
            keyString.withCString { item in
                bufferSize = getxattr(cPath, item, nil, 0, 0, Int32(options.rawValue))
                if bufferSize > 0 {
                    guard let valueBuffer = malloc(Int(bufferSize) + 1) else {
                        if ifErrno("could not allocate memory for values") {
                            return
                        }
                        return
                    }
                    defer { free(valueBuffer) }

                    valueBuffer.assumingMemoryBound(to: Int8.self)[Int(bufferSize)] = 0

                    let valueLength = getxattr(cPath, item, valueBuffer, Int(bufferSize), 0, Int32(options.rawValue))
                    if valueLength > 0 {
                        let attrData = Data(bytes: valueBuffer, count: Int(valueLength))
                        values.append(attrData)
                    } else {
                        values.append(Data())
                    }
                } else {
                    values.append(Data())
                }
            }
        }

        xattributes = Dictionary(uniqueKeysWithValues: zip(keys, values))
        return xattributes
    }

    func ifErrno(_ description: String) -> Bool {
        if errno != 0 {
            let errorDescription = "\(description) at path: \(url.path)"

            // Make and return custom domain error.
            let underlyingError = NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: nil)
            let objArray = [errorDescription, underlyingError, url.path] as [Any]
            let keyArray = [NSLocalizedDescriptionKey, NSUnderlyingErrorKey, NSFilePathErrorKey]
            let eDict = Dictionary(uniqueKeysWithValues: zip(keyArray, objArray))

            resultError = NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: eDict)
            return true
        }
        return false
    }

    func keys() -> [String]? {
//        let path = url.path.fileSystemRepresentation
        let cPath = FileManager.default.fileSystemRepresentation(withPath: url.path)

        let bufferSize = listxattr(cPath, nil, 0, Int32(options.rawValue))
        if bufferSize == 0 || bufferSize == -1 {
            if errno != 0 {
                if ifErrno("listxattr did not return a buffer size") {
                    return nil
                }
            }
        }

        guard let listBuffer = malloc(Int(bufferSize))?.assumingMemoryBound(to: Int8.self) else {
            if errno == ENOMEM {
                if ifErrno("Cannot allocate memory") {
                    return nil
                }
            }
            return nil
        }
        defer { free(listBuffer) }

        let listLength = listxattr(cPath, listBuffer, bufferSize, Int32(options.rawValue))

        var attributesArray: [String] = []
        var nameStart = 0

        for n in 0 ..< Int(listLength) {
            if listBuffer[n] == 0 { // null terminator
                let item = listBuffer.advanced(by: nameStart)
                nameStart = n + 1
                if let keyName = String(cString: item, encoding: .utf8) {
                    attributesArray.append(keyName)
                }
            }
        }

        return attributesArray
    }

//    func deleteAttribute(_ aAttribute: String?) -> Bool {
//        guard let aAttribute = aAttribute else {
//            errno = EINVAL
//            return ifErrno("tried to remove nil key for attribute")
//        }
//
//        let cPath = FileManager.default.fileSystemRepresentation(withPath: url.path)
//        let aKey = aAttribute.fileSystemRepresentation
//
//        if removexattr(cPath, aAttribute, Int32(options.rawValue)) != 0 {
//            if ifErrno("failed to remove attribute \(aAttribute)") {
//                return false // error was created
//            }
//        }
//
//        // double check to see that it does not exist
//        let size = getxattr(cPath, aAttribute, nil, 0, 0, Int32(options.rawValue))
//        if size != -1 {
//            errno = EPERM
//            return ifErrno("attribute \(aAttribute) still exists after delete attempt")
//        }
//
//        attributes.removeValue(forKey: aAttribute)
//        return true // attribute was deleted
//    }

//    func setAttribute(_ aAttribute: String?, value xValue: String) -> Bool {
//        guard let aAttribute = aAttribute else {
//            errno = EINVAL
//            return ifErrno("tried to set nil key for attribute")
//        }
//
//        let cPath = FileManager.default.fileSystemRepresentation(withPath: url.path)
//        let aKey = aAttribute.fileSystemRepresentation
//        let aValue = xValue.fileSystemRepresentation
//
//        let result = setxattr(cPath, aAttribute, xValue, xValue.count, 0, Int32(options.rawValue))
//        if result == -1 {
//            return ifErrno("failure to set attribute \(aAttribute)")
//        }
//
//        attributes[aAttribute] = xValue
//        return true
//    }

    func hasAttribute(_ string: String) -> Bool {
        return attributes.contains(string)
    }

//
//    func getAttribute(_ aAttribute: String) -> Data? {
//        if hasAttribute(aAttribute) {
//            return attributes[aAttribute] as? Data
//        }
//        return nil
//    }

    #if DEBUG
        @inline(__always)
        func assertNotDesignatedInitializer(
            _ initName: String = "init",
            file: StaticString = #file,
            line: UInt = #line
        ) -> Never {
            fatalError(
                "\(initName) is not the designated initializer for instances of \(type(of: self)).",
                file: file,
                line: line
            )
        }
    #else
        @inline(__always)
        func assertNotDesignatedInitializer(_ initName: String = "init") -> Never {
            fatalError()
        }
    #endif
}

// Usage example:
// class SomeClass {
//    init(someParameter: Int) {
//        // Designated initializer
//    }
//
//    convenience init() {
//        assertNotDesignatedInitializer()
//    }
// }
