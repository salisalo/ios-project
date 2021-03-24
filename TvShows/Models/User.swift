//
//  User.swift
//  iMessenger
//
//  Created by Salo Antidze on 2/17/21.
//

struct User {
    let firstName: String
    let lastName: String
    let email: String

    var editedEmail: String {
        var editedEmail = email.replacingOccurrences(of: ".", with: "-")
        editedEmail = editedEmail.replacingOccurrences(of: "@", with: "-")
        return editedEmail
    }

    var profilePictureFileName: String {
        return "\(editedEmail)_profile_picture.png"
    }
}
