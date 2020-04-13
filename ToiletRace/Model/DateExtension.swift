//
//  DateExtension.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 09/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import Foundation

extension Date {
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var monthString: String {
        return Calendar.getLocalizedMonths()[Calendar.current.component(.month, from: self) - 1]
    }
    
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var dayWeekString: String {
        return Calendar.getLocalizedDaysWeek()[Calendar.current.component(.weekday, from: self) - 1]
    }
    
    
    var hours: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    var minutes: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    var seconds: Int {
        return Calendar.current.component(.second, from: self)
    }
    
    // not Int otherwise 09 == 9, 08 == 8 etc
    var hoursString: String {
        var stringHour = String(describing: Calendar.current.component(.hour, from: self))
        if stringHour.count == 1 {
            stringHour = "0\(stringHour)"
        }
        return stringHour
    }
    
    // not Int otherwise 09 == 9, 08 == 8 etc
    var minutesString: String {
        var stringMinute = String(describing: Calendar.current.component(.minute, from: self))
        if stringMinute.count == 1 {
            stringMinute = "0\(stringMinute)"
        }
        return stringMinute
    }
    
    // not Int otherwise 09 == 9, 08 == 8 etc
    var secondsString: String {
        var stringSeconds = String(describing: Calendar.current.component(.second, from: self))
        if stringSeconds.count == 1 {
            stringSeconds = "0\(stringSeconds)"
        }
        return stringSeconds
    }
    
    func isPast() -> Bool {
        return self > Date()
    }
    
    func isToday() -> Bool {
        Calendar.current.isDateInToday(self)
    }
    
    func isYesterday() -> Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    func isVeryRecent() -> Bool {
        return self > Date().addingTimeInterval(-60)
    }
    
    func isLessThan1HAgo() -> Bool {
        return self > Date().addingTimeInterval(-3600)
    }
    
    func isLessThan5HAgo() -> Bool {
        return self > Date().addingTimeInterval(-18000)
    }
    
    func toString(_ format: String = "yyyy-MM-dd'T'HH:mm'Z'") -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format
        return dateFormat.string(from: self)
    }
}

extension Calendar {
    
    static func getLocalizedDaysWeek() -> [String] {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.locale = Locale.current
        return calendar.shortWeekdaySymbols
    }
    
    static func getLocalizedMonths() -> [String] {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.locale = Locale.current
        return calendar.shortMonthSymbols
    }
}

extension String {
    
    func toDate(_ format: String = "yyyy-MM-dd'T'HH:mm'Z'") -> Date? {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format
        return dateFormat.date(from: self)
    }
}
