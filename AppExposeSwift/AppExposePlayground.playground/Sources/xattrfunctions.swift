//  Converted to Swift 5.6.1 by Swiftify v5.6.22657 - https://swiftify.com/
/*
 *  xattrfunctions.swift
 *  little_lister
 *
 *  Created by Matthew Lye on 11/01/08.
 *  Copyright 2008 PolyMicro Systems. All rights reserved.
 *
 *  Using the xattr library calls.
 */

//  define the option flags.
let VERBOSE = 0x0020
let SYMBOLIC = XATTR_NOFOLLOW
let REPLACE = XATTR_REPLACE
let CREATE = XATTR_CREATE

func displayXattrKeys(_ path: UnsafePointer<Int8>?, _ options: Int8) -> Int {
}

func displayXattrValue(_ path: UnsafePointer<Int8>?, _ key: UnsafePointer<Int8>?, _ options: Int8) -> Int {
}

func setXattrValue(_ path: UnsafePointer<Int8>?, _ key: UnsafePointer<Int8>?, _ value: UnsafePointer<Int8>?, _ options: Int8) -> Int {
}

func deleteXattr(_ path: UnsafePointer<Int8>?, _ key: UnsafePointer<Int8>?, _ options: Int8) -> Int {
}