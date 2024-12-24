//
//  WeatherService.swift
//  UWEWeatherMaps
//
//  Modified version from the UWEWeatherMaps tutorial of Mobile Applications module
//  Created by Jed Powell on 25/02/2022.
//

import CoreLocation

struct APIResponse: Decodable {
    let list: [APIList]
}

public struct APIList: Decodable {
    let dt: Int32
    let weather: [APIWeather]
}

struct APIWeather: Decodable {
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case description
    }
}

public final class WeatherService: NSObject, CLLocationManagerDelegate {
    var settings = Settings()
    private let locationManager = CLLocationManager()
    private let API_KEY = "a58ce39a86022f944c859bf36376a65b"
    private var completionHandler: ((Weather) -> Void)?
    
    // Store array of Weather entries (each entry is every 3 hours for next 5 days)
    public var lists = [APIList]()
    
    public override init() {
        super.init()
        locationManager.delegate = self
    }
    
    public func getUserLocation(_ completionHandler: @escaping((Weather) -> Void)) {
        self.completionHandler = completionHandler
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func makeDataRequest(forCoordinates coordinates: CLLocationCoordinate2D) {
        // Coordinates recieved when weatherViewModel.refresh triggered upon SetupView appearing
        // Needed to work out distance between coordinates
        let latitude = String(format: "%f", coordinates.latitude)
        let longitude = String(format: "%f", coordinates.longitude)
        
        self.settings.setUserLatitude(la: latitude)
        self.settings.setUserLongitude(lo: longitude)
        
        
        guard let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&appid=\(API_KEY)&units=metric"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else { return }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) {data, response, error in
            guard error == nil, let data = data else { return }
            
            if let response = try? JSONDecoder().decode(APIResponse.self, from: data) {
                self.lists = response.list
                self.completionHandler?(Weather(response: response))
            }
        }.resume()
    }
    
    // Function currently not in use as distanceBetweenLocations() is not giving data on SetupView while creating Notification
    private func makeDataRequest() {
        
        // Source: https://stackoverflow.com/questions/67643445/can-i-search-by-post-code-in-uk-open-weather-map
        
        let postcodeArr = self.settings.getPostcode().components(separatedBy: " ") // Because people use full postcode
        
        let pc = postcodeArr[0] // we only need the first part
        
        // Note: not an accurate method as the first part of a postcode can span 100s of miles. But it is the only option without coordinates with this API.
        
        guard let urlString = "https://api.openweathermap.org/data/2.5/forecast?zip=\(pc),gb&appid=\(API_KEY)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else { return }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) {data, response, error in
            guard error == nil, let data = data else { return }
            
            if let response = try? JSONDecoder().decode(APIResponse.self, from: data) {
                self.lists = response.list
                self.completionHandler?(Weather(response: response)) // 16th entry = 2 days from now
            }
        }.resume()
        
        // Source end.
    }
    
    public func locationManager (_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        if CLLocationManager.locationServicesEnabled() {
            makeDataRequest(forCoordinates: location.coordinate)
        }
        
        // unused as distanceBetweenLocations() malfunctions while creating Noftification with postcode
        /*if CLLocationManager.locationServicesEnabled() && self.settings.getLocationSetting() {
            makeDataRequest(forCoordinates: location.coordinate)
        }
        else {
            settings.setLocationSetting(ls: false)
            makeDataRequest() // Using postcode
        }*/
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        settings.setLocationSetting(ls: false)
        print("Issue with data: \(error.localizedDescription)")
    }
    
}
