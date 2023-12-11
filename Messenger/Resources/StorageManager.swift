//
//  StorageManager.swift
//  Messenger
//
//  Created by Arslan Raza on 29/11/2023.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadProfileCompletion = (Result<String, Error>) -> Void
    
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadProfileCompletion) {
        storage.child("images/\(fileName)").putData(data) { metaData, error in
            guard error == nil else {
                print("Error in uploading file")
                completion(.failure(StorageError.failedToUplaod))
                return
            }
        }
        
        storage.child("images/\(fileName)").downloadURL { url, error in
            guard let url = url else {
                print("Error in downloading file")
                completion(.failure(StorageError.failedToGetDownloadedUrl))
                return
            }
            
            let urlString = url.absoluteString
            completion(.success(urlString))
        }
    }
    
    public func downloadProfileImage(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let referance = storage.child(path)
        referance.downloadURL { url, error in
            guard let url = url else {
                print("Error in downloading file")
                completion(.failure(StorageError.failedToGetDownloadedUrl))
                return
            }
            
            completion(.success(url))
        }
    }
    
    public enum StorageError: Error {
        case failedToUplaod
        case failedToGetDownloadedUrl
    }
}
