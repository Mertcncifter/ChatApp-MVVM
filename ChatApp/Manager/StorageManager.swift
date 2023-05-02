//
//  StorageManager.swift
//  ChatApp
//
//  Created by mert can çifter on 20.04.2023.
//

import Foundation
import FirebaseStorage

public enum StorageErrors: Error {
    case failedToUpload
    case failedToGetDowloandUrl
}

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        
        storage.child("images/\(fileName)").putData(data,metadata: nil) { metadata, error in
            
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(StorageErrors.failedToGetDowloandUrl))
                    return
                }
                
                let urlString = url.absoluteString
                
                completion(.success(urlString))

            }
        }
    }
    
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        
        storage.child("message_images/\(fileName)").putData(data,metadata: nil) { [weak self] metadata, error in
            
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(StorageErrors.failedToGetDowloandUrl))
                    return
                }
                
                let urlString = url.absoluteString
                
                completion(.success(urlString))

            }
        }
    }
    
    public func uploadMessageVideo(with fileUrl: URL, fileName: String, completion: @escaping UploadPictureCompletion) {
        
        do {
            let data = try Data(contentsOf: fileUrl)

            if let uploadData = data as? Data {
                let metaData = StorageMetadata()
                metaData.contentType = "video/mp4"
                
                storage.child("message_videos/\(fileName)").putData(uploadData,metadata: metaData) { [weak self] metadata, error in
                    
                    guard error == nil else {
                        completion(.failure(StorageErrors.failedToUpload))
                        return
                    }
                    
                    self?.storage.child("message_videos/\(fileName)").downloadURL { url, error in
                        guard let url = url else {
                            completion(.failure(StorageErrors.failedToGetDowloandUrl))
                            return
                        }
                        
                        let urlString = url.absoluteString
                        
                        completion(.success(urlString))

                    }
                }
            }
            
        } catch {
            
        }
    }
    
    public func dowloandUrl(for path: String, completion: @escaping(Result<URL,Error>) -> Void) {
        
        let reference = storage.child(path)
        
        reference.downloadURL { url, error in
            
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDowloandUrl))
                return
            }
            
            completion(.success(url))
        }
    }
    
 
}
