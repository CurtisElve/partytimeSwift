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
    init(name: String = "", description: String = "", latitude: Float = 100, longitude: Float = 100, address: String = "", starttime: Date = Date.now, endtime: Date = Date.now, maxattendees: Int = -1, hashtags: String = "", image: String = "") {
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
        validated = !name.isEmpty && !description.isEmpty && !address.isEmpty && maxattendees != -1 && !hashtags.isEmpty
        //re add longatude and latitude nullcheck in deployement - right now its pain in the ass
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
    
    func makeCreatePartyRequest() -> api.createPartyRequest {
        // Backend accepts optional fields, so we can send partial data
        return api.createPartyRequest(
            name: self.name,
            description: self.description.isEmpty ? nil : self.description,
            latitude: self.latitude == -1 ? nil : self.latitude,
            longitude: self.longitude == -1 ? nil : self.longitude,
            address: self.address.isEmpty ? nil : self.address,
            startTime: self.starttime,
            endTime: self.endtime,
            maxAttendees: self.maxattendees <= 0 ? nil : self.maxattendees,
            hashtags: self.hashtags.isEmpty ? nil : self.hashtags,
            mediaUrl: self.image.isEmpty ? nil : self.image
        )
    }
}
