import SwiftUI
import Foundation

let clock = ContinuousClock()

let time = clock.measure {
    // complex work here
}

let date = Date.now
func formattingDates() {
    // Note: This will use your current date & time plus current locale. Example output is for en_US locale.
//    let date = Date.now
    
    let formatted = date.formatted()
    // example: "6/7/2021, 9:42 AM"
    print(formatted)
    
    let onlyDate = date.formatted(date: .numeric, time: .omitted)
    // example: "6/7/2021"
    print(onlyDate)
    
    let onlyTime = date.formatted(date: .omitted, time: .shortened)
    // example: "9:42 AM"
    print(onlyTime)
}

func formattingDatesWithStyles() {
    // Note: This will use your current date & time plus current locale. Example output is for en_US locale.
    let date = Date.now
    
    let formatted = date.formatted(.dateTime)
    // example: "6/7/2021, 9:42 AM"
    print(formatted)
}

func formattingDatesMoreExamples() {
    // Note: This will use your current date & time plus current locale. Example output is for en_US locale.
    let date = Date.now
    
    let formatted = date.formatted(.dateTime.year().day().month())
    // example: "Jun 7, 2021"
    print(formatted)
    
    let formattedWide = date.formatted(.dateTime.year().day().month(.wide))
    // example: "June 7, 2021"
    print(formattedWide)
    
    let formattedWeekday = date.formatted(.dateTime.weekday(.wide))
    // example: "Monday"
    print(formattedWeekday)
    
    let logFormat = date.formatted(.iso8601)
    // example: "20210607T164200Z"
    print(logFormat)
    
    
    let fileNameFormat = date.formatted(.iso8601.year().month().day().dateSeparator(.dash))
    // example: "2021-06-07"
    print(fileNameFormat)
    
    print("Took \(time.components.seconds) seconds")
}


