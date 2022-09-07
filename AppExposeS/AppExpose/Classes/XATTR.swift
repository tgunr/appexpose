//
//  XATTR.swift
//  xattr
//
//  Created by Dave Carlton on 9/4/22.
//

import Foundation
import Cocoa
enum XATTROptions : Int {
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

var errorDescription: String? = nil
// Make and return custom domain error.
//var underlyingError = NSError(domain: NSPOSIXErrorDomain, code: errno, userInfo: nil)
//var objArray = [errorDescription, underlyingError, url?.path]
//var keyArray = [NSLocalizedDescriptionKey, NSUnderlyingErrorKey, NSFilePathErrorKey]
//var eDict = NSDictionary(objects:objArray, forKeys:keyArray as [NSCopying]) as Dictionary
//let path = Int8((url?.path as NSString?).fileSystemRepresentation ?? 0)
//var bufferSize = listxattr(path, nil, 0, options.rawValue) // find out the buffer size.
/*    LISTXATTR:
     The listxattr function fills the allocated text buffer with a list of attribute names,
     seperated by the null character ('\0').
     The function returns the number of attributes.
     */

//var listBuffer = malloc(bufferSize)
//var listLength = listxattr(path, listBuffer, bufferSize, options.rawValue)
//var n = 0 // a character scanner counter.
//var nameStart = 0 // the index position of each name.
//var attributesArray = [AnyHashable](repeating: 0, count: 0)
////listLength
//var item = Int8(listBuffer?[nameStart] ?? 0) // return a pointer to the name...
//var keyName = NSNumber(value: item) as? String
////attributesArray
//var xattributes = [AnyHashable : Any](minimumCapacity: 0)
//let path = Int8((url?.path as NSString?).fileSystemRepresentation ?? 0)
//var bufferSize = listxattr(path, nil, 0, options.rawValue) // find out the buffer size.
////xattributes
////xattributes
///*    LISTXATTR:
//The listxattr function fills the allocated text buffer with a list of attribute names,
//seperated by the null character ('\0').
//*/
//
//var buffer = UnsafeMutablePointer<Int8>(mutating: Int8(malloc(size_t(bufferSize))))
////xattributes
//var listLength = listxattr(path, buffer, size_t(bufferSize), options.rawValue)
////xattributes
////xattributes
//var allKeys = String(bytes: buffer, encoding: .utf8)
//var keys = allKeys?.components(separatedBy: "\0")
//var values = [AnyHashable](repeating: 0, count: 1)
//var keyString: String?
//let item = Int8((keyString as NSString?)?.cString(using: String.Encoding.utf8.rawValue) ?? 0)
////xattributes
//var valueLength = getxattr(path, item, buffer, size_t(bufferSize), 0, options.rawValue)
//var attrData = Data(bytes: buffer, length: Int(valueLength))
////xattributes
//let aPath = Int8((url?.path as NSString?).cString(using: String.Encoding.utf8.rawValue) ?? 0)
//let aKey = Int8(aAttribute.cString(using: String.Encoding.utf8.rawValue) ?? 0)
//// double check to see that it does not exist.
//var size = getxattr(aPath, aKey, nil, 0, 0, options.rawValue)
////EPERM
////EINVAL
//let aPath = Int8((url?.path as NSString?).cString(using: String.Encoding.utf8.rawValue) ?? 0)
//let aKey = Int8(aAttribute.cString(using: String.Encoding.utf8.rawValue) ?? 0)
//let aValue = Int8(xValue.cString(using: String.Encoding.utf8.rawValue) ?? 0)
//var result = setxattr(aPath, aKey, aValue, size_t(xValue.length), 0, options.rawValue)
////EINVAL
//var result: Any?

class XATTR: NSObject {
    var url: URL?
    var options: XATTROptions?
    var resultError: Error?
    var attributes: [AnyHashable : Any]?
    private(set) var keysValues: [AnyHashable : Any]?
    
    required init(url aURL: URL?, options theOptions: XATTROptions) {
    }
    
    required init(path thePath: String?, options theOptions: XATTROptions) {
    }
    
    func ifErrno(_ description: String?) -> Bool {
        return false
    }
    
    func deleteAttribute(_ aAttribute: String?) -> Bool {
        return false
    }
    
    func setAttribute(_ aAttribute: String!, value xValue: String!) {
    }
    
    func hasAttribute(_ string: String?) -> Bool {
        return false
    }
    
    func getAttribute(_ aAttribute: String?) -> Data? {
        return Data()
    }
    
    let VERBOSE = 0x0020
    let SYMBOLIC = XATTR_NOFOLLOW
    let REPLACE = XATTR_REPLACE
    let CREATE = XATTR_CREATE

    func displayXattrKeys(_ path: UnsafePointer<Int8>?, _ options: Int8) -> Int {
        return 0
    }

    func displayXattrValue(_ path: UnsafePointer<Int8>?, _ key: UnsafePointer<Int8>?, _ options: Int8) -> Int {
        return 0
    }

    func setXattrValue(_ path: UnsafePointer<Int8>?, _ key: UnsafePointer<Int8>?, _ value: UnsafePointer<Int8>?, _ options: Int8) -> Int {
        return 0
    }

    func deleteXattr(_ path: UnsafePointer<Int8>?, _ key: UnsafePointer<Int8>?, _ options: Int8) -> Int {
        return 0
    }
}

//func PSPDF_NOT_DESIGNATED_INITIALIZER() {
//    PSPDF_NOT_DESIGNATED_INITIALIZER_CUSTOM(`init`)
//}
//#define PSPDF_NOT_DESIGNATED_INITIALIZER_CUSTOM(initName) _Pragma("clang diagnostic push")
//_Pragma("clang diagnostic ignored \"-Wobjc-designated-initializers\"")
//- (instancetype)initName
//{ do {
//NSAssert2(NO, @"%@ is not the designated initializer for instances of %@.", NSStringFromSelector(_cmd), NSStringFromClass([self class]));
//return nil;
//} while (0); }
//_Pragma("clang diagnostic pop")

func PSPDF_NOT_DESIGNATED_INITIALIZER_CUSTOM(_ `init`: Int) {
}

 /* at a null termination in the buffer... */ /* and move to the next name. */func free(_ listBuffer: Int) {
}

//func free(_ buffer: Int) {
//}

// getxattr returns without nullterm, make room...
//func free(_ buffer: Int) {
    //}

 /* error was created */ /* error was created */ // attribute was deleted
