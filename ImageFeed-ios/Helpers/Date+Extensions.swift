//
//  Date+Extensions.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 04.07.2023.
//

import Foundation

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()

extension Date {
    var dateTimeString: String { dateFormatter.string(from: self) }
}
