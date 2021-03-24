//
//  StorageManager.swift
//  iMessenger
//
//  Created by Salo Antidze on 2/24/21.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {}
    
    private let storage = Storage.storage().reference()
    
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping (_ url: String?, _ error: String?) -> Void) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                if let error = error {
                    completion(nil, error.localizedDescription)
                }
                if let url = url {
                    let urlString = url.absoluteString
                    completion(urlString, nil)
                }
            })
        })
    }
    
    public func downloadURL(for path: String, completion: @escaping (_ url: String?, _ error: String?) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL(completion: { url, error in
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            
            if let url = url {
                completion(url.absoluteString, nil)
            }
        })
    }
    
    
}
