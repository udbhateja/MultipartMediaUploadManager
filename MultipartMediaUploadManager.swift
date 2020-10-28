//
//  MultipartMediaUploadManager.swift
//
//
//  Created by UDBhateja on 22/04/20.
//  Copyright © 2020 Uday Bhateja. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - MultiPartDataComponents
struct MultiPartDataComponents {
    var data            : Data
    var key             : String
    var fileExtension   : String
    var fileName        : String = "\(Date().timeIntervalSince1970)"
    var mimeType        : String
    var fileURL         : URL?
    
    init(
        data: Data,
        key: String,
        extension ext: String,
        mimeType: String,
        fileName fn: String? = nil
    ) {
        self.data           = data
        self.key            = key
        self.fileExtension  = ext
        self.mimeType       = mimeType
        if let _fileName = fn {
            self.fileName = _fileName + "." + fileExtension
        }
    }
}

// MARK: - MultipartMediaUploadManager
class MultipartMediaUploadManager: NSObject {
    
    //MARK: Private Variables
    private var url                     : String
    private var parameters              : [String: Any]
    private var multipartComponents     : [MultiPartDataComponents]
    private var method                  : HTTPMethod
    
    var headers: HTTPHeaders = [
        "Content-type": "multipart/form-data"
    ]
    
    //MARK: Callbacks
    var onError                         : ( (Error?) -> () )?
    var onCompletion                    : ( (Any?) -> () )?
    
    //MARK: init
    init(url: String,
         parameters: [String: Any],
         dataComponents: [MultiPartDataComponents] = [],
         method: HTTPMethod = .post) {
        self.url                    = url
        self.parameters             = parameters
        self.multipartComponents    = dataComponents
        self.method                 = method
    }
    
    func upload() {
        Alamofire.upload(
            multipartFormData: {
                [weak self] (multipartData) in
                guard let self = self else {return}
                
                for component in self.multipartComponents {
                    multipartData.append(component.data,
                                         withName: component.key,
                                         fileName: component.fileName,
                                         mimeType: component.mimeType)
                }
                
                
                for (key, value) in self.parameters {
                    if let str = value as? String {
                        multipartData.append(str.data(using: .utf8)!, withName: key)
                    }
                    else if let dict = value as? NSDictionary,
                        let json = try? JSONSerialization.data(
                            withJSONObject: dict,
                            options: .prettyPrinted) {
                        multipartData.append(json, withName: key)
                    }
                    else if let arr = value as? NSArray,
                        let json = try? JSONSerialization.data(
                            withJSONObject: arr,
                            options: .prettyPrinted) {
                        multipartData.append(json, withName: key)
                    }
                    else {
                        multipartData.append("\(value)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
                    }
                }
                
            },
            usingThreshold   : UInt64(),
            to               : url,
            method           : method,
            headers          : headers) {
                
                
                [weak self] (result) in
                guard let self = self else {return}
                switch result {
                    
                case .success(let upload, _, _):
                    
                    upload.uploadProgress { (progress) in
                        if self.multipartComponents.count > 0 {
                            let fraction = progress.fractionCompleted * 100.0
                            print("Progress \(fraction)")
                        }
                        else {
                            //Show Loader
                        }
                    }
                    
                    upload.responseJSON {
                        response in
                        print("Succesfully uploaded")
                        
                        if response.result.isSuccess {
                            print(response.result.value!)
                            self.onCompletion?(response.result.value)
                        }
                        else {
                            self.onError?(response.error)
                        }
                    }
                    
                case .failure(let error):
                    print("Error in upload: \(error.localizedDescription)")
                    self.onError?(error)
                }
        }
    }
}
