//
//  URLSessionNetworkAccess.swift
//  DBNetworkStack
//
//	Legal Notice! DB Systel GmbH proprietary License!
//
//	Copyright (C) 2015 DB Systel GmbH
//	DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/

//	This code is protected by copyright law and is the exclusive property of
//	DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/

//	Consent to use ("licence") shall be granted solely on the basis of a
//	written licence agreement signed by the customer and DB Systel GmbH. Any
//	other use, in particular copying, redistribution, publication or
//	modification of this code without written permission of DB Systel GmbH is
//	expressly prohibited.

//	In the event of any permitted copying, redistribution or publication of
//	this code, no changes in or deletion of author attribution, trademark
//	legend or copyright notice shall be made.
//
//  Created by Lukas Schmidt on 05.09.16.
//

import Foundation

extension NetworkRequestRepresening {
    /**
     Transforms self into a equivalent `NSURLRequest` with a given baseURL.
     
     parameter baseURL: baseURL for the resulting request.
     
     return: the equivalent request
     */
    func urlRequest(with baseURL: NSURL) -> NSURLRequest {
        let absoluteURL = absoluteURLWith(baseURL)
        let request = NSMutableURLRequest(URL: absoluteURL)
        request.allHTTPHeaderFields = allHTTPHeaderFields
        request.HTTPMethod = HTTPMethod.rawValue
        
        return request
    }
    
    func absoluteURLWith(baseUrl: NSURL) -> NSURL {
        guard let absoluteURL = NSURL(string: path, relativeToURL: baseUrl) else {
            fatalError("Error createing absolute URL from path: \(path), with baseURL: \(baseUrl)")
        }
        if let parameter = parameter, let urlComponents = NSURLComponents(URL: absoluteURL, resolvingAgainstBaseURL: true) where !parameter.isEmpty {
            let percentEncodedQuery = parameter.map( {value in
                return "\(value.0)=\(value.1)".stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
            }).flatMap { $0 }
            urlComponents.percentEncodedQuery = percentEncodedQuery.joinWithSeparator("&")
            return urlComponents.URL!
        }
       
        return absoluteURL
    }
}

/**
 Adds conformens to `NetworkAccessProviding`. `NSURLSession` can now be used as a networkprovider.
 */
extension NSURLSession: NetworkAccessProviding {
    public func load(request request: NetworkRequestRepresening, relativeToBaseURL baseURL: NSURL, callback: (NSData?, NSHTTPURLResponse?, NSError?) -> ()) -> NetworkTask {
        let task = dataTaskWithRequest(request.urlRequest(with: baseURL)) { data, response, error in
            callback(data, response as? NSHTTPURLResponse, error)
        }
        task.resume()
        
        return task
    }
}

extension NSURLSessionTask: NetworkTask {
    public var progress: NSProgress {
        let totalBytesExpected = response?.expectedContentLength ?? NSURLSessionTransferSizeUnknown
        let progress = NSProgress(totalUnitCount: totalBytesExpected)
        progress.totalUnitCount = totalBytesExpected
        progress.completedUnitCount = countOfBytesReceived
        
        return progress
    }
}