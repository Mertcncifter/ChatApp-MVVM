//
//  UserDefault+Extension.swift
//  ChatApp
//
//  Created by mert can çifter on 26.04.2023.
//

import Foundation

extension UserDefaults {

    @UserDefault(key: "email", defaultValue: nil)
    static var email: String?
    
    @UserDefault(key: "name", defaultValue: nil)
    static var name: String?
}
