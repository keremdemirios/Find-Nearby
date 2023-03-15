//
//  String+Extension.swift
//  Find Nearby
//
//  Created by Kerem Demır on 14.03.2023.
//

import Foundation

extension String {
    
    var formatPhoneForCall: String {
        self.replacingOccurrences(of: "", with: "")
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "-", with: "")
    }
}
