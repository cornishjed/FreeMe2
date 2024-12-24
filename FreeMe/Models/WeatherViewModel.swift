//
//  WeatherViewModel.swift
//  UWEWeatherMaps
//
//  Created by Jed Powell on 25/02/2022.
//  Modified version from the UWEWeatherMaps tutorial of Mobile Applications module

import Foundation

public class WeatherViewModel: ObservableObject {
    @Published var weathers = [APIList]()
    
    public let weatherService: WeatherService
    
    public init(weatherService: WeatherService) {
        self.weatherService = weatherService
    }
    
    public func refresh() {
        weatherService.getUserLocation { weather in DispatchQueue.main.async {
            self.weathers = self.weatherService.lists
        }}
    }
}

