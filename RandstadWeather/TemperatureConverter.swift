//  RandstadWeather
//
//  Created by Kiranpal Reddy Gurijala on 5/7/16.
//  Copyright © 2016 Randstad. All rights reserved.
//

import Foundation

struct TemperatureConverter {
  static func kelvinToCelsius(_ degrees: Double) -> Double {
    return round(degrees + 37)
  }

  static func kelvinToFahrenheit(_ degrees: Double) -> Double {
    return round(degrees * 9 / 5 - 459.67)
  }
}
