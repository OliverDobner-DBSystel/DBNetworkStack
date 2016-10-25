//
//  UploadAccessServiceMock.swift
//
//  Copyright (C) 2016 DB Systel GmbH.
//	DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//
//  Created by Christian Himmelsbach on 29.09.16.
//

import Foundation
@testable import DBNetworkStack

class UploadAccessServiceMock: MultipartFormDataUploadAccessProviding {
    
    var uploadData: NSData?
    
    private var reponseData: NSData?
    private var responseError: NSError?
    private var response: NSHTTPURLResponse?
    private var multipartFormData: ((MultipartFormDataRepresenting) -> ())?
    
    func upload(request: NetworkRequestRepresening, relativeToBaseURL: NSURL, multipartFormData: (MultipartFormDataRepresenting) -> (),
                encodingMemoryThreshold: UInt64, callback: (NSData?, NSHTTPURLResponse?, NSError?) -> (),
                onNetworkTaskCreation: DBNetworkTaskCreationCompletionBlock?) {
        
        dispatch_async(dispatch_get_main_queue()) {
            multipartFormData(MulitpartFormDataRepresentingMock())
            onNetworkTaskCreation?(NetworkTaskMock())
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0)*Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), {
                callback(self.reponseData, self.response, self.responseError)
            })
        }
        
    }
    
    func changeMock(data data: NSData?, response: NSHTTPURLResponse?, error: NSError?) {
        self.reponseData = data
        self.response = response
        self.responseError = error
    }
}
