//
//  ViewController.swift
//  RandstadWeather
//
//  Created by Kiranpal Reddy Gurijala on 5/6/16.
//  Copyright © 2016 Randstad. All rights reserved.
//

import UIKit
import CoreData

class WeatherViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var weatherTableView: UITableView!
    
    var cityWeatherDetailsCell = cityWeatherDetails()
    let cityNames = ["Chicago", "New York", "Houston", "San Francisco", "Austin", "Denver", "Detroit", "Los Angeles", "Seattle", "Nashville"]
    let cityCodes = ["4887398", "5128638", "4699066", "5391959", "4099974", "4853799", "4990729", "5368361", "5809844", "5003243"];
    var cityWeatherInfoList:[Weather]=[]
    // MARK: - Services
    //private var locationService: LocationService
    fileprivate var weatherService: OpenWeatherServiceProtocol = OpenWeatherService()
    var weatherData = [NSManagedObject]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
            weatherService.retrieveWeatherInfo(cityCodes as NSArray, type: "current") { (weather, error) -> Void in
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

        } else {
            print("Internet connection FAILED")
        }
        
        
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
            print("Fetched data",weatherData.count)
            weatherTableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)->Int {
        return self.cityWeatherInfoList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cityWeatherDetailsCell = tableView.dequeueReusableCell(withIdentifier: cityWeatherDetails.tableViewCellIdentier(), for: indexPath) as! cityWeatherDetails
        cityWeatherDetailsCell.backgroundColor = UIColor.clear
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
            cityWeatherDetailsCell.cityName.text = cityNames[indexPath.row]
            cityWeatherDetailsCell.cityTemperature.text = cityWeatherInfoList[indexPath.row].temperature
            cityWeatherDetailsCell.cityWeatherDescription.text = cityWeatherInfoList[indexPath.row].description
        } else {
            print("Internet connection FAILED")
            let weatherDetail = weatherData[indexPath.row]
            print(weatherDetail.value(forKey: "temperature")!)
            cityWeatherDetailsCell.cityName.text = cityNames[indexPath.row]
            cityWeatherDetailsCell.cityTemperature.text = weatherDetail.value(forKey: "temperature") as? String
            cityWeatherDetailsCell.cityWeatherDescription.text = weatherDetail.value(forKey: "weatherDescription") as? String
        }
        
        return cityWeatherDetailsCell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc:WeatherDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: WeatherDetailViewController.storyboardID()) as! WeatherDetailViewController
        vc.cityCode=cityCodes[indexPath.row]
        vc.cityNameInfo=cityNames[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - private
    fileprivate func update(_ weather: Weather) {
        cityWeatherInfoList.append(weather)
        weatherTableView.reloadData()
    }
    
    fileprivate func update(_ error: Error) {
        print("WeatherInfo",error)
    }


}
class cityWeatherDetails : UITableViewCell {
    
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var cityWeatherDescription: UILabel!
    @IBOutlet weak var cityTemperature: UILabel!
    class func tableViewCellIdentier() -> String {
        return "cityWeatherDetailsID"
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

