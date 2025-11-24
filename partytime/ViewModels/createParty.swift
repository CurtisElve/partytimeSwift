//
//  createParty.swift
//  partytime
//
//  Created by Curtis on 2025-09-19.
//

import Foundation

class createParty : ObservableObject{
    @Published var name:String
    @Published var description:String
    @Published var latitude:Float
    @Published var longitude:Float
    @Published var address:String
    @Published var starttime:Date
    @Published var endtime:Date
    @Published var maxattendees:Int
    @Published var hashtags:String
    @Published var image:String
    @Published var validated : Bool = true
    init(name: String = "", description: String = "", latitude: Float = -1, longitude: Float = -1, address: String = "", starttime: Date = Date.now, endtime: Date = Date.now, maxattendees: Int = -1, hashtags: String = "", image: String = "") {
        self.name = name
        self.description = description
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.starttime = starttime
        self.endtime = endtime
        self.maxattendees = maxattendees
        self.hashtags = hashtags
        self.image = image
    }
    private func validate(){
        validated = !name.isEmpty && !description.isEmpty && latitude != -1 && longitude != -1 && !address.isEmpty && maxattendees != -1 && !hashtags.isEmpty && !image.isEmpty
    }
    
    func makeApiCall() throws -> api.makeparty{
        validate()
        if validated{
            return api.makeparty(name: self.name, description: self.description, latitude: self.latitude, longitude: self.longitude, address: self.address, starttime: self.starttime, endtime: self.endtime, maxattendees: self.maxattendees, hashtags: self.hashtags, image: self.image)
        }
        else{
            throw NSError(domain: "Validation Error", code: 1001, userInfo: nil)
        }
    }
}
