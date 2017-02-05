//
//  WeatherDetailViewController.swift
//  RandstadWeather
//
//  Created by Kiranpal Reddy Gurijala on 5/8/16.
//  Copyright © 2016 Randstad. All rights reserved.
//

import UIKit
import CoreData

class WeatherDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var cityCode:String=""
    var cityNameInfo:String=""
    var cityWeatherInfoList:[Weather]=[]
    @IBOutlet weak var cityWeatherInfoTable: UITableView!
    @IBOutlet weak var cityName: UILabel!
    fileprivate var weatherService: OpenWeatherServiceProtocol = OpenWeatherService()
    var cityWeatherDetailsInfoCell = cityWeatherDetailsInfo()
    var weatherData = [NSManagedObject]()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("City Code",cityCode)
        var cityCodes:[String]=[]
        cityCodes.append(cityCode)
        if Reachability.isConnectedToNetwork() == true {
        weatherService.retrieveWeatherInfo(cityCodes as NSArray, type: "forecast") { (weather, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let unwrappedError = error {
                    print(unwrappedError)
                    self.update(unwrappedError)
                    return
                }
                
                guard let unwrappedWeather = weather else {
                    return
                }
                self.update(unwrappedWeather)
            })

        }
        }
        else{
            print("Internet connection FAILED")
        }
        self.cityName.text=cityNameInfo

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Weather")
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            weatherData = results as! [NSManagedObject]
            cityWeatherInfoTable.reloadData()
            print("Fetched data",weatherData.count)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    class func storyboardID() -> String {
        return "weatherDetailVC"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)->Int {
        print("cityWeatherInfoList.count", self.cityWeatherInfoList.count)
         if Reachability.isConnectedToNetwork() == true {
        if(self.cityWeatherInfoList.count==0){
            return self.cityWeatherInfoList.count
        }
        else{
            return self.cityWeatherInfoList[0].forecasts.count
        }
         }else{
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cityWeatherDetailsInfoCell = tableView.dequeueReusableCell(withIdentifier: cityWeatherDetailsInfo.tableViewCellIdentier(), for: indexPath) as! cityWeatherDetailsInfo
        cityWeatherDetailsInfoCell.backgroundColor = UIColor.clear
        if Reachability.isConnectedToNetwork() == true {
        print("Internet connection OK")
        cityWeatherDetailsInfoCell.cityTemperature.text = cityWeatherInfoList[0].forecasts[indexPath.row].temperature
        cityWeatherDetailsInfoCell.cityWeatherDescription.text = cityWeatherInfoList[0].forecasts[indexPath.row].description
        cityWeatherDetailsInfoCell.cityWeatherReadingDay.text = cityWeatherInfoList[0].forecasts[indexPath.row].time
        }
        else{
        let weatherDetail = weatherData[indexPath.row]
        cityWeatherDetailsInfoCell.cityTemperature.text = weatherDetail.value(forKey: "temperature") as? String
        cityWeatherDetailsInfoCell.cityWeatherDescription.text = weatherDetail.value(forKey: "weatherDescription") as? String
        cityWeatherDetailsInfoCell.cityWeatherReadingDay.text = weatherDetail.value(forKey: "time") as? String
        }
        
        return cityWeatherDetailsInfoCell
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - private
    fileprivate func update(_ weather: Weather) {
        print("WeatherInfo",weather.forecasts)
        cityWeatherInfoList.append(weather)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "Weather",in:managedContext)
        let weatherInfo = NSManagedObject(entity: entity!, insertInto: managedContext)
        print(weather.forecasts.count)
        for index in 0..<weather.forecasts.count{
            weatherInfo.setValue(cityNameInfo, forKey: "location")
            weatherInfo.setValue(weather.forecasts[index].temperature, forKey: "temperature")
            weatherInfo.setValue(weather.forecasts[index].time, forKey: "time")
            weatherInfo.setValue(weather.forecasts[index].description, forKey: "weatherDescription")
        }
        
        do {
            try managedContext.save()
            weatherData.append(weatherInfo)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        cityWeatherInfoTable.reloadData()
    }
    
    fileprivate func update(_ error: Error) {
        print("WeatherInfoError",error)
    }
    
}
class cityWeatherDetailsInfo : UITableViewCell {
    
    @IBOutlet weak var cityWeatherReadingDay: UILabel!
    @IBOutlet weak var cityWeatherDescription: UILabel!
    @IBOutlet weak var cityTemperature: UILabel!
    class func tableViewCellIdentier() -> String {
        return "cityWeatherDetailsInfoID"
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

