//
//  Weather.swift
//  RandstadWeather
//
//  Created by Kiranpal Reddy Gurijala on 5/6/16.
//

import Foundation

struct Weather {
  let location: String
  let iconText: String
  let temperature: String
  let description: String
  let forecasts: [Forecast]
}
