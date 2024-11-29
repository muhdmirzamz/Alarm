//
//  Utilities.swift
//  Alarm
//
//  Created by Muhd Mirza on 29/6/24.
//

import Foundation

class Utilities {
    func getStringForDate(date dateObject: Date) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sss'Z'"
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: dateObject)
    }
    
    func getDateFromDateString(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sss'Z'"
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.date(from: dateString)!
    }
    
    func getUserReadableStringFromDate(dateString: String) -> String {

        let dateObject = self.getDateFromDateString(dateString: dateString)

        let dateFormatter = DateFormatter()
        
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "dd/MM/yyyy, HH:mm:ss"
        
        return dateFormatter.string(from: dateObject)
    }
    
    func getUserReadableStringForTableCellFromDate(dateString: String) -> String {

        let dateObject = self.getDateFromDateString(dateString: dateString)

        let dateFormatter = DateFormatter()
        
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: dateObject)
    }
}
