//  RandstadWeather
//
//  Created by Kiranpal Reddy Gurijala on 5/7/16.
//  Copyright © 2016 Randstad. All rights reserved.
//

import Foundation

struct ForecastDateTime {
  let rawDate: Double
  
  init(_ date: Double) {
    rawDate = date
  }
  
  var shortTime: String {
    let date = Date(timeIntervalSince1970: rawDate)
    let dateFormatter = DateFormatter()
    //dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
    dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
    dateFormatter.timeZone = TimeZone.current
    let localDate = dateFormatter.string(from: date)
    return localDate
  }
}
