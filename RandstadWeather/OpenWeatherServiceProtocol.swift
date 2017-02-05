//
//  OpenWeatherServiceProtocol.swift
//  RandstadWeather
//
//  Created by Kiranpal Reddy Gurijala on 5/7/16.
//  Copyright © 2016 Randstad. All rights reserved.
//

import Foundation
import CoreLocation

typealias WeatherCompletionHandler = (Weather?, Error?) -> Void

protocol OpenWeatherServiceProtocol {
    func retrieveWeatherInfo(_ location: NSArray, type:String, completionHandler: @escaping WeatherCompletionHandler)
}


