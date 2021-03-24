//
//  DbManager.swift
//  TvShows
//
//  Created by Salo Antidze on 3/23/21.
//

import Foundation
import Firebase

final class DbManager {
    
    public static let shared = DbManager()
    
    private let db = Database.database().reference()
    
    static func getEditedEmail(email: String) -> String {
        var editedEmail = email.replacingOccurrences(of: ".", with: "-")
        editedEmail = editedEmail.replacingOccurrences(of: "@", with: "-")
        return editedEmail
    }
}

//extension DbManager {
//    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
//        db.child("\(path)").observeSingleEvent(of: .value) { snapshot in
//            guard let value = snapshot.value else {
//                completion(.failure(DatabaseError.failedToFetch))
//                return
//            }
//            completion(.success(value))
//        }
//    }
//}

extension DbManager {
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {
        
        let editedEmail = DbManager.getEditedEmail(email: email)
        db.child(editedEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? [String: Any] != nil else {
                completion(false)
                return
            }
            completion(true)
        })
        
    }
    
    public func insertUser(with user: User, completion: @escaping (Bool) -> Void) {
        db.child(user.editedEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ], withCompletionBlock: { [weak self] error, _ in
            
            //            guard let self = self else {
            //                return
            //            }
            
            guard error == nil else {
                print("failed ot write to database")
                completion(false)
                return
            }
            
            completion(true)
        })
    }
    public func addToPlaylist(_ tvShow: TvShowInfo, completion: @escaping (Bool) -> Void) {
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String
        else {
            return
        }
        
        let editedEmail = DbManager.getEditedEmail(email: currentEmail)
        
        let ref = db.child("\(editedEmail)")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard var user = snapshot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }
            
            let item : [String: Any] = [
                "id":tvShow.id,
                "name":tvShow.name,
                "country":tvShow.origin_country.count == 0 ? "" : tvShow.origin_country[0],
                "poster":tvShow.poster_path == nil ? "" : tvShow.poster_path!,
                "vote":tvShow.vote_average,
                "date":tvShow.first_air_date == nil ? "" : tvShow.first_air_date!.prefix(4)
            ]
            
            if var playlist = user["favorites"] as? [[String : Any]] {
                playlist.append(item)
                user["favorites"] = playlist
                ref.setValue(user) { error, _ in
                    
                    guard error == nil else {
                        print("failed ot write to database")
                        completion(false)
                        return
                    }
                    
                    completion(true)
                }
            }
            else {
                user["favorites"] = [item]
                ref.setValue(user) { error, _ in
                    
                    guard error == nil else {
                        print("failed ot write to database")
                        completion(false)
                        return
                    }
                    
                    completion(true)
                }
            }
            
            
        }
    }
    
    public func isTvShowInFavorites(_ id: Int, completion: @escaping (_ result: Bool?, _ error: String?) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String
        else {
            return
        }
        
        let editedEmail = DbManager.getEditedEmail(email: currentEmail)
        
        let ref = db.child("\(editedEmail)/favorites")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let tvShows = snapshot.value as? [[String: Any]] else {
                completion(false, "")
                return
            }
            
            var isInFavorites: Bool = false
            
            for item in tvShows {
                if let itemId = item["id"] as? Int,
                   id == itemId  {
                    isInFavorites = true
                    break
                }
            }
            completion(isInFavorites, nil)
        }
    }
    
    
    public func deleteFromFavorites(_ id: Int, completion: @escaping (_ result: Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String
        else {
            return
        }
        
        let editedEmail = DbManager.getEditedEmail(email: currentEmail)
        
        let ref = db.child("\(editedEmail)/favorites")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if var tvShows = snapshot.value as? [[String: Any]] {
                
                var position = 0
                
                for item in tvShows {
                    if let itemId = item["id"] as? Int,
                       id == itemId  {
                        break
                    }
                    position += 1
                }
                tvShows.remove(at: position)
                ref.setValue(tvShows, withCompletionBlock: { error, _  in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                })
                
            }
        }
    }
        
        
        public func getAllFavorites(completion: @escaping (_ result: [TvShowInfo]?, _ error: String?) -> Void) {
            guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String
            else {
                return
            }
            
            let editedEmail = DbManager.getEditedEmail(email: currentEmail)
            
            let ref = db.child("\(editedEmail)/favorites")
            ref.observe(.value) { (snapshot) in
                guard let tvShows = snapshot.value as? [[String: Any]] else {
                    completion(nil, "something went wrong")
                    return
                }
                
                let tvShowsList: [TvShowInfo] = tvShows.compactMap { (dictionary) in
                    guard let id = dictionary["id"] as? Int,
                          let date = dictionary["date"] as? String,
                          let name = dictionary["name"] as? String,
                          let country = dictionary["country"] as? String,
                          let poster = dictionary["poster"] as? String,
                          let vote = dictionary["vote"] as? Float
                    else {
                        return nil
                    }
                    
                    return TvShowInfo(id: id, first_air_date: date, name: name, origin_country: [country], poster_path: poster, vote_average: vote, vote_count: 0, genre_ids: [], overview: "")
                }
                
                completion(tvShowsList, nil)
            }
        }
        
        //    public func addToPlaylist(_ tvShowId: String, with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        //
        //        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
        //            let currentNamme = UserDefaults.standard.value(forKey: "name") as? String else {
        //                return
        //        }
        //
        //        let editedEmail = DbManager.getEditedEmail(email: currentEmail)
        //
        //        let ref = db.child("\(editedEmail)")
        //        ref.observeSingleEvent(of: .value) { (snapshot) in
        //            guard var user = snapshot.value as? [String: Any] else {
        //                completion(false)
        //                print("user not found")
        //                return
        //            }
        //
        //            ref.setValue([tvShowId]) { [weak self] error, _ in
        //
        //                            guard error == nil else {
        //                                print("failed ot write to database")
        //                                completion(false)
        //                                return
        //                            }
        //
        //                            completion(true)
        //            }
        //        }
        //
        //        let ref = db.child("\(editedEmail)")
        //
        //        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
        //            guard var userNode = snapshot.value as? [String: Any] else {
        //                completion(false)
        //                print("user not found")
        //                return
        //            }
        //
        //            let messageDate = firstMessage.sentDate
        //            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        //
        //            var message = ""
        //
        //            let conversationId = "conversation_\(firstMessage.messageId)"
        //
        //            let newConversationData: [String: Any] = [
        //                "id": conversationId,
        //                "other_user_email": otherUserEmail,
        //                "name": name,
        //                "latest_message": [
        //                    "date": dateString,
        //                    "message": message,
        //                    "is_read": false
        //                ]
        //            ]
        //
        //            let recipient_newConversationData: [String: Any] = [
        //                "id": conversationId,
        //                "other_user_email": safeEmail,
        //                "name": currentNamme,
        //                "latest_message": [
        //                    "date": dateString,
        //                    "message": message,
        //                    "is_read": false
        //                ]
        //            ]
        //            // Update recipient conversaiton entry
        //
        //            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
        //                if var conversatoins = snapshot.value as? [[String: Any]] {
        //                    // append
        //                    conversatoins.append(recipient_newConversationData)
        //                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversatoins)
        //                }
        //                else {
        //                    // create
        //                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
        //                }
        //            })
        //
        //            // Update current user conversation entry
        //            if var conversations = userNode["conversations"] as? [[String: Any]] {
        //                // conversation array exists for current user
        //                // you should append
        //
        //                conversations.append(newConversationData)
        //                userNode["conversations"] = conversations
        //                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
        //                    guard error == nil else {
        //                        completion(false)
        //                        return
        //                    }
        //                    self?.finishCreatingConversation(name: name,
        //                                                     conversationID: conversationId,
        //                                                     firstMessage: firstMessage,
        //                                                     completion: completion)
        //                })
        //            }
        //            else {
        //                // conversation array does NOT exist
        //                // create it
        //                userNode["conversations"] = [
        //                    newConversationData
        //                ]
        //
        //                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
        //                    guard error == nil else {
        //                        completion(false)
        //                        return
        //                    }
        //
        //                    self?.finishCreatingConversation(name: name,
        //                                                     conversationID: conversationId,
        //                                                     firstMessage: firstMessage,
        //                                                     completion: completion)
        //                })
        //            }
        //        })
        //    }
        
        //    public func getAllConversations(for email: String, completion: @escaping (Result<[Chat], Error>) -> Void) {
        //        db.child("\(email)/conversations").observe(.value, with: { snapshot in
        //            guard let value = snapshot.value as? [[String: Any]] else{
        //                completion(.failure(DatabaseError.failedToFetch))
        //                return
        //            }
        //
        //            let chats: [Chat] = value.compactMap( { dictionary in
        //                guard let chatId = dictionary["id"] as? String,
        //                    let name = dictionary["name"] as? String,
        //                    let otherUserEmail = dictionary["other_user_email"] as? String,
        //                    let latestMessage = dictionary["latest_message"] as? [String: Any],
        //                    let date = latestMessage["date"] as? String,
        //                    let message = latestMessage["message"] as? String,
        //                    let seen = latestMessage["seen"] as? Bool
        //                else {
        //                        return nil
        //                }
        //
        //                let latestMessageObj = LatestMessage(date: date,
        //                                                         text: message,
        //                                                         seen: seen)
        //                return Chat(id: chatId,
        //                                    name: name,
        //                                    otherUserEmail: otherUserEmail,
        //                                    latestMessage: latestMessageObj)
        //            })
        //
        //            completion(.success(chats))
        //        })
        //    }
        
        
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
        
        //    public var localizedDescription: String {
        //        switch self {
        //        case .failedToFetch:
        //            return "This means blah failed"
        //        }
        //    }
    }

//            strongSelf.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
//                if var usersCollection = snapshot.value as? [[String: String]] {
//                    // append to user dictionary
//                    let newElement = [
//                        "name": user.firstName + " " + user.lastName,
//                        "email": user.safeEmail
//                    ]
//                    usersCollection.append(newElement)
//
//                    strongSelf.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
//                        guard error == nil else {
//                            completion(false)
//                            return
//                        }
//
//                        completion(true)
//                    })
//                }
//                else {
//                    // create that array
//                    let newCollection: [[String: String]] = [
//                        [
//                            "name": user.firstName + " " + user.lastName,
//                            "email": user.safeEmail
//                        ]
//                    ]
//
//                    strongSelf.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
//                        guard error == nil else {
//                            completion(false)
//                            return
//                        }
//
//                        completion(true)
//                    })
//                }
//            })
//        })



