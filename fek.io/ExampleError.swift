//
//  ExampleError.swift
//  fek.io
//
//  Created by David Fekke on 6/30/20.
//  Copyright © 2020 David Fekke L.L.C. All rights reserved.
//

import Foundation

struct SampleError : Error {
    let title: String
    let description: String
    let code: Int
}
