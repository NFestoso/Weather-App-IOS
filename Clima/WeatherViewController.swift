//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "f5d6cf1225f567005e6aaeef2cc9f573"
    
    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameters: [String:String]){
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                print("Success! Got weather data")
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                print("Error \(response.result.error!)")
                self.cityLabel.text = "Connection Issue"
            }
        }
        
    }
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    func updateWeatherData(json: JSON){
        
        if let tempResult = json["main"]["temp"].double {
            let condResult = json["weather"][0]["id"].intValue
            let cityResult = json["name"].stringValue
            
            weatherDataModel.temperature = Int(tempResult - 273.15)
            weatherDataModel.condition = Int(condResult)
            weatherDataModel.city = cityResult
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: condResult)
            
            updateUI()
        }
        else{
            cityLabel.text = "Weather Unavailable"
        }
    }
    

    //MARK: - UI Updates
    /***************************************************************/
    func updateUI(){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temperature)+"°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    

    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // get location
        let location = locations[locations.count-1]
        
        // check if location is valid
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            print("Longitude: \(location.coordinate.longitude) Latitude: \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    func userEnteredNewCity(city: String) {
        
        let params: [String: String] = ["q": city, "appid": APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
    
    
}


