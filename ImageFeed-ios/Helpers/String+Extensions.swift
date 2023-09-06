//
//  String+Extencons.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 28.08.2023.
//

import Foundation

extension String {
    var stringToDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from: self)
    }
}
