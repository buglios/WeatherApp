//
//  NetworkManager.swift
//  WeatherApp
//
//  Created by Robert Covu on 5/16/23.
//


import Foundation
import UIKit

protocol NetworkSession {
    func dataTask(with request: URLRequest) async throws -> (Data, URLResponse)
}

struct URLSessionWrapper: NetworkSession {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func dataTask(with request: URLRequest) async throws -> (Data, URLResponse) {
        let (data, response) = try await session.data(for: request)
        return (data, response)
    }
}

protocol WeatherAPIProtocol {
    func getCityWeather(for city: String) async throws -> TempDetails
    func getGPSWeather(lat: Double, lon: Double) async throws -> TempDetails
}

class WeatherAPI: WeatherAPIProtocol {
    private static let apiKey = "32e2c929fae2d63a6b58ab810d73958d"
    private let session: NetworkSession
    
    init(session: NetworkSession = URLSessionWrapper()) {
        self.session = session
    }
    func getGPSWeather(lat: Double, lon: Double) async throws -> TempDetails {
        guard let url = URL(string:
                                "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(WeatherAPI.apiKey)&units=metric") else {
            throw WeatherAPIError.invalidURL
        }
        
        let request = URLRequest(url: url)
        let (data, response) = try await session.dataTask(with: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw WeatherAPIError.invalidResponse
        }
        
        return try JSONDecoder().decode(TempDetails.self, from: data)
    }
    
    func getCityWeather(for city: String)  async throws -> TempDetails {
        
        let city = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(WeatherAPI.apiKey)") else {
            throw WeatherAPIError.invalidURL
        }
        print(url)
        let request = URLRequest(url: url)
        let (data, response) = try  await session.dataTask(with: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw WeatherAPIError.invalidResponse
        }
        
        return try JSONDecoder().decode(TempDetails.self, from: data)
    }
    
    func icon(id: String, completionHandler:@escaping  (Data)->Void) throws {
        let urlString = "https://openweathermap.org/img/wn/\(id)@2x.png"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
                completionHandler(data)
            }
        }.resume()
    }
    
    enum WeatherAPIError: Error {
        case invalidURL
        case invalidResponse
    }
}
