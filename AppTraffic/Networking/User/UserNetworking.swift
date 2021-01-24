//
//  UserNetworking.swift
//  AppTraffic
//
//  Created by MAC OS on 11/20/20.
//  Copyright © 2020 Edward Lauv. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase
import FirebaseStorage
import CoreLocation

class UserNetworking {
    static let instance = UserNetworking()
    let ref = Database.database().reference()
    // create user
    func createUser(user: UserModel, image: UIImage, completion: @escaping (_ success: Bool,_ message: String) -> Void) {
        Auth.auth().createUser(withEmail: user.email ?? "", password: user.password ?? "") { (results, error) in
            var message : String = ""
            var isSuccess : Bool = false
            if let error = error, let errorcode = AuthErrorCode(rawValue: error._code) {
                switch  errorcode{
                case AuthErrorCode.emailAlreadyInUse:
                    isSuccess = false
                    message = "Email already in use"
                case AuthErrorCode.invalidEmail:
                    isSuccess = false
                    message = "Email invalid"
                case AuthErrorCode.weakPassword:
                    isSuccess = false
                    message = "Weak Password"
                default:
                    break
                }
            }
            else {
                let location = CLLocationManager()
                guard let locValue : CLLocationCoordinate2D = location.location?.coordinate else {return}
                isSuccess = true
                message = "Bạn đã đăng kí thành công"
                var userid = String()
                if let newuser = Auth.auth().currentUser {
                    userid = newuser.uid
                }
                var datadictionary : [String: Any] = [:]
                datadictionary["email"] = user.email
                datadictionary["fullname"] = user.fullname
                datadictionary["long"] = locValue.longitude
                datadictionary["lat"] = locValue.latitude
                UserDefaultsDataStore.userdeaultsdatastore.save(forKey: USER_ID, value: Auth.auth().currentUser!.uid)
                self.registerInfo(uid: userid, image: image, value: datadictionary)
            }
            completion(isSuccess,message)
            
        }
    }
    // register info
    func registerInfo(uid: String, image: UIImage, value: [String:Any]) {
        let userref = ref.child("USERS_INFO").child(uid)
        userref.updateChildValues(value) { (err, ref) in
            if let err = err {
                print("----error:\(err)")
                return
            }
            self.getUserFromFirebase(id: uid)
            print("Successfully Added a New User to the Database")
        }
        uploadAvatar(uid, image: image)
    }
    
    func updateUser(uid : String, location : CLLocationCoordinate2D) {
        let userref = ref.child("USERS_INFO").child(uid)
        userref.updateChildValues([
            "lat" : location.latitude,
            "long" : location.longitude,
        ])
    }
    
    // login with firebase
    func signIn(email: String, password: String, completion: @escaping (_ success: Bool, _ message: String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (results, error) in
            var isScuccess : Bool = false
            var message : String = ""
            if let error = error , let errorcode = AuthErrorCode(rawValue: error._code){
                print("error login: \(error)")
                switch  errorcode{
                case AuthErrorCode.userDisabled:
                    isScuccess = false
                    message = "Email Disabled, please sign up"
                case AuthErrorCode.invalidEmail:
                    isScuccess = false
                    message = "Email is invalid"
                case AuthErrorCode.wrongPassword:
                    isScuccess = false
                    //case AuthErrorCode.
                    message = "Password is wrong"
                case AuthErrorCode.appNotAuthorized:
                    isScuccess = false
                    message = "App not Authorized"
                case AuthErrorCode.emailAlreadyInUse:
                    isScuccess = false
                    message = "Email already in use"
                default:
                    break
                }
            }
            else {
                let location = CLLocationManager()
                guard let locValue : CLLocationCoordinate2D = location.location?.coordinate else {return}
                isScuccess = true
                message = "Sign in success"
                UserDefaultsDataStore.userdeaultsdatastore.save(forKey: USER_ID, value: Auth.auth().currentUser!.uid)
                self.getUserFromFirebase(id: Auth.auth().currentUser!.uid)
                self.updateUser(uid: Auth.auth().currentUser!.uid, location: locValue)
            }
            completion(isScuccess, message)
        }
    }
    
    // get user
    func getUserFromFirebase(id: String) {
        self.ref.child("USERS_INFO").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.saveUserDeaults(data: value!)
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // userdeault save user
    func saveUserDeaults(data : NSDictionary) {
        UserDefaultsDataStore.userdeaultsdatastore.save(forKey: USER_EMAIL, value: data["email"])
        UserDefaultsDataStore.userdeaultsdatastore.save(forKey: USER_NAME, value: data["fullname"])
        UserDefaultsDataStore.userdeaultsdatastore.save(forKey: USER_LAT, value: data["lat"])
        UserDefaultsDataStore.userdeaultsdatastore.save(forKey: USER_LONG, value: data["long"])
    }
    
    func uploadAvatar(_ id : String, image : UIImage) {
        let storageRef = Storage.storage().reference().child(id)
        if let uploadTask = image.pngData() {
            storageRef.putData(uploadTask, metadata: nil) { (data, error) in
                if let error = error {
                    print("error when upload image: \(error)")
                    return
                } else {
                    storageRef.downloadURL { (url, error) in
                        print("upload image scucess")
                    }
                }
            }
        }
    }
    
    func loadimageFromFirebase(_ id: String, completion: @escaping ((UIImage?) -> Void)) {
        let storageRef = Storage.storage().reference().child(id)
        storageRef.getData(maxSize: 1024*1024*1024) { data, error in
            if let error = error {
                print("load image from firebase: \(error)")
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)!
                completion(image)
            }
        }
    }
}
