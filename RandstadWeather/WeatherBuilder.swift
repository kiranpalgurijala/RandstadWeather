//
//  RandstadWeather
//
//  Created by Kiranpal Reddy Gurijala on 5/6/16.
//

import Foundation

struct WeatherBuilder {
  var location: String?
  var iconText: String?
  var temperature: String?
  var description: String?
  var forecasts: [Forecast]?

  func build() -> Weather {
    return Weather(location: location!,
                      iconText: iconText!,
                   temperature: temperature!,
                   description: description!,
                   forecasts: forecasts!)
  }
    
}
