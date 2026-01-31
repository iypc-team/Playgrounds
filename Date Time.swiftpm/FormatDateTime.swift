//  FormatDateTime.swift
//  let
//  

import SwiftUI
import Foundation

final class FormatDateTime {
    
//    private let fullDate = fd.formatted() // example: "6/7/2021, 9:42 AM"
//    private let onlyDate = fd.formatted(date: .long, time: .omitted) // "6/7/2021"
//    private let onlyTime = fd.formatted(date: .omitted, time: .shortened) // "9:42AM"
    
    // MARK: - Properties
    private let clock = ContinuousClock()
    private(set) var measuredTime: Duration
    
    private let date: Date
    
    // MARK: - Initializer
    
    init(date: Date = .now) {
        self.date = date
        
        // Measure some complex work (placeholder for real logic)
        self.measuredTime = clock.measure {
            // complex work here
        }
    }
    
    func onlyTime() -> String  {
        let time: String = String(date.formatted(date: .omitted, time: .shortened))
        return time
    }
    
    func fullDate() -> String  {
        let date: String = String(date.formatted(date: .numeric, time: .omitted))
        return  date
    }
    
    // MARK: - Basic Formatting
    func formattingDates() {
        let formatted = date.formatted()
        print(formatted) // e.g. "6/7/2021, 9:42 AM"
        
        let onlyDate = date.formatted(date: .numeric, time: .omitted)
        print(onlyDate) // e.g. "6/7/2021"
        
        let onlyTime = date.formatted(date: .omitted, time: .shortened)
        print(onlyTime) // e.g. "9:42 AM"
    }
    
    // MARK: - Style-Based Formatting
    
    func formattingDatesWithStyles() {
        let formatted = date.formatted(.dateTime)
        print(formatted)
    }
    
    // MARK: - Advanced Examples
    
    func formattingDatesMoreExamples() {
        let shortDate = date.formatted(.dateTime.year().day().month())
        print(shortDate) // "Jun 7, 2021"
        
        let wideDate = date.formatted(.dateTime.year().day().month(.wide))
        print(wideDate) // "June 7, 2021"
        
        let weekday = date.formatted(.dateTime.weekday(.wide))
        print(weekday) // "Monday"
        
        let logFormat = date.formatted(.iso8601)
        print(logFormat) // "20210607T164200Z"
        
        let fileNameFormat = date.formatted(
            .iso8601.year().month().day().dateSeparator(.dash)
        )
        print(fileNameFormat) // "2021-06-07"
        
        print("Took \(measuredTime.components.seconds) seconds")
    }
}
