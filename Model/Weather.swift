//
//  Weather.swift
//  WeatherApp
//
//  Created by Robert Covu on 5/16/23.
//

import Foundation
import SwiftUI
// MARK: - Welcome
struct TempDetails: Codable, Identifiable {
    let coord: Coord
    let weather: [Weather]
    let base: String
    let main: Main
    let visibility: Double
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let sys: Sys
    let timezone, id: Int
    let name: String
    let cod: Int
}

// MARK: - Clouds
struct Clouds: Codable {
    let all: Int
}

// MARK: - Coord
struct Coord: Codable {
    let lon, lat: Double
}

// MARK: - Main
struct Main: Codable {
    let temp, feelsLike, tempMin, tempMax, pressure, humidity: Double

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
}

// MARK: - Sys
struct Sys: Codable, Identifiable {
    let type, id: Int
    let country: String
    let sunrise, sunset: Int
}

// MARK: - Weather
struct Weather: Codable, Identifiable {
    let id: Int
    let main, description, icon: String
}

// MARK: - Wind
struct Wind: Codable {
    let speed: Double
    let deg: Double
}

struct Info {
    var cityName: String?
    var lon: Double?
    var lat: Double?
    var temp: Double?
    var feelsLike: Double?
    var main: String?
    var desc: String?
    var windSpeed: Double?
    var windDegree: Double?
    var pressure: Double?
    var humidity: Double?
    var visibility: Double?
    var icon: Image?
}





