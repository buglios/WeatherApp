//
//  ViewModel.swift
//  WeatherApp
//
//  Created by Robert Covu on 5/16/23.
//

import Foundation
import SwiftUI
import Combine

class ViewModel: ObservableObject {
    
    @Published var city: String = "Atlanta"
    var networkManager = WeatherAPI()
    var locationManger = LocationManager()
    
    @MainActor @Published var locationError = false
    @MainActor @Published var info = Info()
    
    private var _firstLocationFetch = true
    
    private var combineStorageBag = Set<AnyCancellable>()
    
    init(networkManager: WeatherAPI, locationManger: LocationManager) {
        self.networkManager = networkManager
        self.locationManger = locationManger
        
        locationManger.locationSubject
            .sink { _ in
                
            } receiveValue: { [weak self] _ in
                print("something updated with location...")
                
                if let self = self {
                    self.requestLocation()
                }
            }
            .store(in: &combineStorageBag)
    }
    
    func requestLocation() {
        if let coordinate = locationManger.lastLocation {
            _firstLocationFetch = false
            Task {
                await fetchWeather(lat: coordinate.coordinate.latitude,
                                   lon: coordinate.coordinate.longitude)
            }
        } else {
            if _firstLocationFetch {
                _firstLocationFetch = false
            } else {
                Task { @MainActor in
                    locationError = true
                }
            }
        }
    }
    
    func fetchWeather(cityName: String) async {
        do {
            let details = try await networkManager.getCityWeather(for: cityName)
            await processDetails(details: details)
        } catch DecodingError.dataCorrupted(let context) {
            print(context.debugDescription)
        } catch DecodingError.keyNotFound(let key, let context) {
            print("\(key.stringValue) was not found, \(context.debugDescription)")
        } catch DecodingError.typeMismatch(let type, let context) {
            print("\(type) was expected, \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            print("no value was found for \(type), \(context.debugDescription)")
        } catch {
            print("I know not this error")
        }
    }
    
    func fetchWeather(lat: Double, lon: Double) async {
        do {
            let details = try await networkManager.getGPSWeather(lat: lat, lon: lon)
            await processDetails(details: details)
        } catch DecodingError.dataCorrupted(let context) {
            print(context.debugDescription)
        } catch DecodingError.keyNotFound(let key, let context) {
            print("\(key.stringValue) was not found, \(context.debugDescription)")
        } catch DecodingError.typeMismatch(let type, let context) {
            print("\(type) was expected, \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            print("no value was found for \(type), \(context.debugDescription)")
        } catch {
            print("I know not this error")
        }
    }
    
    func processDetails(details: TempDetails?) async {
        if let details =  details {
            await saveTempDetails(details)
            if let icon = details.weather.first?.icon {
                try? networkManager.icon(id: icon, completionHandler: { data in
                    DispatchQueue.main.async {
                        self.info.icon = Image(uiImage: UIImage(data: data) ?? UIImage(systemName: "sun.max.fill")!)
                    }
                })
            }
        }
    }
    
    @MainActor private func saveTempDetails(_ temp: TempDetails) {
        self.info.cityName = temp.name
        self.info.lat = temp.coord.lat
        self.info.lon = temp.coord.lon
        self.info.temp = temp.main.temp
        self.info.feelsLike = temp.main.feelsLike
        self.info.main = temp.weather.first?.main
        self.info.desc = temp.weather.description
        self.info.windSpeed = temp.wind.speed
        self.info.windDegree = temp.wind.deg
        self.info.pressure = temp.main.pressure
        self.info.humidity = temp.main.humidity
        self.info.visibility = temp.visibility        
    }
    
    func farenheit(kelvin: Double) -> Double {
        (kelvin - 273.15) * 9.0 / 5.0 + 32.0
    }
}
