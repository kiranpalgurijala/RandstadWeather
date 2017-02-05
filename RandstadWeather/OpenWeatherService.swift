//
//  OpenWeatherServiceProtocol.swift
//  RandstadWeather
//
//  Created by Kiranpal Reddy Gurijala on 5/7/16.
//  Copyright © 2016 Randstad. All rights reserved.
//

import Foundation
import CoreLocation

struct OpenWeatherService: OpenWeatherServiceProtocol {
  fileprivate let urlPath = "http://api.openweathermap.org/data/2.5/forecast/"
  //city?id=524901&APPID={APIKEY}
    
    func retrieveWeatherInfo(_ location: NSArray, type:String, completionHandler: @escaping WeatherCompletionHandler) {
    let sessionConfig = URLSessionConfiguration.default
    let session = URLSession(configuration: sessionConfig)
    
    guard let url = generateRequestURL(location, type: type) else {
      let error = Error(errorCode: .urlError)
      completionHandler(nil, error)
      return
    }
    print(url)
    let request = URLRequest(url: url)
    let task = session.dataTask(with: request, completionHandler: { data, response, networkError in
      
      // Check network error
      guard networkError == nil else {
        let error = Error(errorCode: .networkRequestFailed)
        completionHandler(nil, error)
        return
      }
      
      // Check JSON serialization error
      guard let unwrappedData = data else {
        let error = Error(errorCode: .jsonSerializationFailed)
        completionHandler(nil, error)
        return
      }
      
      let json = JSON(data: unwrappedData)
      
        if(type=="current"){
            print("Result is", json)
      // Get temperature, location, description and icon and check parsing error
        var weatherbuilderArray:[WeatherBuilder]=[]
        for index in 0..<json["list"].count{
            guard let tempDegrees = json["list"][index]["main"]["temp"].double,
                let country = json["list"][index]["sys"]["country"].string,
                let city = json["list"][index]["name"].string,
                let weatherCondition = json["list"][index]["weather"][0]["id"].int,
                let weatherDescription = json["list"][index]["weather"][0]["description"].string,
                let iconString = json["list"][index]["weather"][0]["icon"].string else {
                    let error = Error(errorCode: .jsonParsingFailed)
                    completionHandler(nil, error)
                    return
            }
            var weatherBuilder = WeatherBuilder()
            let temperature = Temperature(country: "CA", openWeatherMapDegrees:tempDegrees)
            weatherBuilder.temperature = temperature.degrees
            weatherBuilder.location = city
            weatherBuilder.description = weatherDescription
            let weatherIcon = WeatherIcon(condition: weatherCondition, iconString: iconString)
            weatherBuilder.iconText = weatherIcon.iconText
            weatherBuilder.forecasts=[]
            completionHandler(weatherBuilder.build(), nil)
            //weatherbuilderArray.append(weatherBuilder)
        }
        }
        else{
           print("Result is", json)
            guard let tempDegrees = json["list"][0]["temp"]["day"].double,
                let country = json["city"]["country"].string,
                let city = json["city"]["name"].string,
                let weatherCondition = json["list"][0]["weather"][0]["id"].int,
                let weatherDescription = json["list"][0]["weather"][0]["description"].string,
                let iconString = json["list"][0]["weather"][0]["icon"].string else {
                    let error = Error(errorCode: .jsonParsingFailed)
                    completionHandler(nil, error)
                    return
            }
            
            var weatherBuilder = WeatherBuilder()
            let temperature = Temperature(country: "US", openWeatherMapDegrees:tempDegrees)
            weatherBuilder.temperature = temperature.degrees
            weatherBuilder.location = city
            weatherBuilder.description = weatherDescription
            let weatherIcon = WeatherIcon(condition: weatherCondition, iconString: iconString)
            weatherBuilder.iconText = weatherIcon.iconText
            
            var forecasts: [Forecast] = []
            // Get the first four forecasts
            for index in 0...4 {
                guard let forecastTempDegrees = json["list"][index]["temp"]["day"].double,
                    let rawDateTime = json["list"][index]["dt"].double,
                    let forecastCondition = json["list"][index]["weather"][0]["id"].int,
                    let weatherDescription = json["list"][index]["weather"][0]["description"].string,
                    let forecastIcon = json["list"][index]["weather"][0]["icon"].string else {
                        break
                }
                
                let forecastTemperature = Temperature(country: country, openWeatherMapDegrees: forecastTempDegrees)
                let forecastTimeString = ForecastDateTime(rawDateTime).shortTime
                
                let weatherIcon = WeatherIcon(condition: forecastCondition, iconString: forecastIcon)
                let forcastIconText = weatherIcon.iconText
                let forecastDescription = weatherDescription
                let forecast = Forecast(time: forecastTimeString,
                    iconText: forcastIconText,
                    temperature: forecastTemperature.degrees, description:forecastDescription)
                
                forecasts.append(forecast)
            }
            
            weatherBuilder.forecasts = forecasts
            
            completionHandler(weatherBuilder.build(), nil)
        }
        //print(weatherbuilderArray)
    })
    
    task.resume()
  }
  
    fileprivate func generateRequestURL(_ location: NSArray, type: String) -> URL? {
    guard let components = URLComponents(string:urlPath) else {
      return nil
    }
    var group:String=""
    for index in 0..<location.count {
        group=group+(location[index] as! String)+","
    }
    var openURL:String=""
    if(type=="current"){
        openURL="http://api.openweathermap.org/data/2.5/group?id="+group+"&units=metric&appid=e450f19dcd0309b83b5ee086aea18d07"
    }
    else{
       openURL="http://api.openweathermap.org/data/2.5/forecast/daily?id="+(location[0] as! String)+"&appid=e450f19dcd0309b83b5ee086aea18d07&cnt=5"
    }
    let openWeatherAPIURL:URL = URL.init(string: openURL)!
    return openWeatherAPIURL
  }
    
}
