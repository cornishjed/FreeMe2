//
//  Weather.swift
//  Modified version from the UWEWeatherMaps tutorial of Mobile Applications module
//
//  Created by Jed Powell on 25/02/2022.
//

import Foundation

public struct Weather: Codable {
    // only description needed to filter suitable activities. 'dt' held as possible reference.
    
    let description: String
    let dt: Int32
    
    init(response: APIResponse) {
        description = response.list.first?.weather.first?.description ?? ""
        dt = (response.list.first?.dt)!
    }
}
