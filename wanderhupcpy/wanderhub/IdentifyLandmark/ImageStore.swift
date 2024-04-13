//
//  ChattStore.swift
//  wanderhub
//
//  Created by Neha Tiwari on 3/22/24.
//

import UIKit
import Alamofire
import Observation
import Foundation


@Observable
final class ImageStore {
    
    private let user = User.shared
    static let shared = ImageStore() // create one instance of the class to be shared
    private init() {}                // and make the constructor private so no other
    // instances can be created
    private(set) var chatts = [ImageData]()
  //  private let nFields = Mirror(reflecting: ImageData()).children.count
    
    // TODO: ADD AUTHORIZATION. USE WanderHubID.shared.id TO SEND REQUEST TO BACKEND
    func postImage(_ imagedata: ImageData, image: UIImage?) async -> Data? {
        guard let apiUrl = URL(string: "\(serverUrl)post_landmarks/") else {
            print("postChatt: Bad URL")
            return nil
        }
        
        guard let token = UserDefaults.standard.string(forKey: "usertoken") else {
            return nil
        }
        //        let plainString = token as NSString
        //        let plainData = plainString.data(using:NSUTF8StringEncoding)
        //        let base64String = plainData?.base64EncodedData(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        
        //        let plainString = token as NSString
        //        let plainData = plainString.data(using:NSUTF8StringEncoding)
        //        let base64String = plainData?.base64EncodedData(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        
        let headers : HTTPHeaders = [
            "Authorization": "Token \(token)",
            "Accept": "application/json; charset=utf-8",
            "Content-Type": "application/json; charset=utf-8" ]

        return try? await AF.upload(multipartFormData: { mpFD in
            if let usernameData = imagedata.username?.data(using: .utf8) {
                mpFD.append(usernameData, withName: "username")
            }
            if let timestampData = imagedata.timestamp?.data(using: .utf8) {
                mpFD.append(timestampData, withName: "timestamp")
            }
            if let geoData = imagedata.geoData {
                // Append GeoData fields
                mpFD.append(String(geoData.lat).data(using: .utf8) ?? Data(), withName: "lat")
                mpFD.append(String(geoData.lon).data(using: .utf8) ?? Data(), withName: "lon")
                mpFD.append(geoData.place.data(using: .utf8) ?? Data(), withName: "place")
                mpFD.append(geoData.facing.data(using: .utf8) ?? Data(), withName: "facing")
                mpFD.append(geoData.speed.data(using: .utf8) ?? Data(), withName: "speed")
            }
            if let image = image?.jpegData(compressionQuality: 1.0) {
                mpFD.append(image, withName: "image", fileName: "chattImage", mimeType: "image/jpeg")
            }
            
            
        }, to: apiUrl, method: .post, headers: headers )
        .uploadProgress(queue: .main, closure: { progress in
            //Current upload progress of file
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .responseJSON(completionHandler: { response in
            debugPrint(response)
            if let httpResponse = response.response {
                print("Status Code: \(httpResponse.statusCode)")
                print("Headers:")
                for (header, value) in httpResponse.allHeaderFields {
                    print("\(header): \(value)")
                }
            }
            
        }).validate().serializingData().value
            //Current upload progress of file
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .responseJSON(completionHandler: { response in
            debugPrint(response)
            if let httpResponse = response.response {
                print("Status Code: \(httpResponse.statusCode)")
                print("Headers:")
                for (header, value) in httpResponse.allHeaderFields {
                    print("\(header): \(value)")
                }
            }
            
        }).validate().serializingData().value
    }
    
    func getLandmarkName() async -> String? {
        //let landmark_name: String?
        
        guard let getImageUrl = URL(string: "\(serverUrl)get_landmarks/") else {
            print("getImageInfo: Bad URL")
            return nil
        }
        
        var request = URLRequest(url: getImageUrl)
        guard let token = UserDefaults.standard.string(forKey: "usertoken") else {
            return nil
        }
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization") // todo bug may be here!
        request.httpMethod = "GET"
        
    
    func getLandmarkName() async -> String? {
        //let landmark_name: String?
        
        guard let getImageUrl = URL(string: "\(serverUrl)get_landmarks/") else {
            print("getImageInfo: Bad URL")
            return nil
        }
        
        var request = URLRequest(url: getImageUrl)
        guard let token = UserDefaults.standard.string(forKey: "usertoken") else {
            return nil
        }
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization") // todo bug may be here!
        request.httpMethod = "GET"
        
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("HTTP STATUS: \(httpStatus.statusCode)")
                print("Headers:")
                for (header, value) in httpStatus.allHeaderFields {
                    print("\(header): \(value)")
                }
                return nil
            }
            
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("getImageAndAddToDb: failed JSON deserialization")
                return nil
            }
            
            guard let landmark_name = jsonObj["landmarks_info"] as? String else {
                return nil
            }
            return landmark_name
        } catch {
            print("Login Networking Error")
            return nil
        }
    }
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("HTTP STATUS: \(httpStatus.statusCode)")
                print("Headers:")
                for (header, value) in httpStatus.allHeaderFields {
                    print("\(header): \(value)")
                }
                return nil
            }
            
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("getImageAndAddToDb: failed JSON deserialization")
                return nil
            }
            
            guard let landmark_name = jsonObj["landmarks_info"] as? String else {
                return nil
            }
            return landmark_name
        } catch {
            print("Login Networking Error")
            return nil
        }
    }
    
    func addLandmarkToUserHistory(landmark_name: String) async -> Void {
        guard let getImageUrl = URL(string: "\(serverUrl)add-user-landmark") else {
            print("getImageInfo: Bad URL")
            return
        }
        
        var request = URLRequest(url: getImageUrl)
        guard let token = UserDefaults.standard.string(forKey: "usertoken") else {
            return
        }
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // todo bug may be here!
        request.httpMethod = "POST"
        
        
        let jsonObj = ["landmark_name": landmark_name]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            print("addLandmarkToUserHistory: jsonData serialization error")
            return
        }
        
        request.httpBody = jsonData
        
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            
            // are we sure that we need to serialize it?
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("getImageAndAddToDb: failed JSON deserialization")
                return
            }
            
            return
        } catch {
            print("Login Networking Error")
            return
        }
    }
    
    
    
    
    
    
}
