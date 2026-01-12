//
//  authServiceProtocol.swift
//  partytime
//
//  Created by Curtis on 2025-07-27.
//

import Foundation

protocol authServiceProtocol: AnyObject {
    func login(email: String, password: String, completion: @escaping (Bool, Error?) -> Void)
    func SignUp(email: String, password: String, completion: @escaping (Bool, Error?) -> Void)
    func logout(completion: @escaping (Bool, Error?) -> Void)
    func whoisit() -> String
    func uid() -> String?
    func newidtoken() async -> String?
    func idtoken() async -> String?
}

extension authService: authServiceProtocol{}
