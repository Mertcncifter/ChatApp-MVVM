//
//  ChatAppUser.swift
//  ChatApp
//
//  Created by mert can çifter on 26.04.2023.
//

import Foundation

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
        
    var profilePictureFileName: String {
        return "\(emailAddress.safeEmail)_profile_picture.png"
    }
}

extension String {
    var safeEmail: String {
        var safeEmail = self.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
