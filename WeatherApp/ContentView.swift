//
//  ContentView.swift
//  WeatherApp
//
//  Created by Robert Covu on 5/15/23.
//

import SwiftUI

struct ContentView: View {
    
    @State var cityName = ""
    @StateObject var viewModel = ViewModel(networkManager: WeatherAPI(),
                                           locationManger: LocationManager())
    @State var isNight = false
    var body: some View {
        ZStack {
            BakcgroundView(isNight: $isNight)
            VStack {
                
                VStack {
                    TextField("City", text: $cityName)
                        .padding(10)
                        .textFieldStyle(.roundedBorder)
                    
                        .font(.system(size: 28, weight: .medium, design: .default))
                        .frame(width: 300, alignment: .center)
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            Task {
                                await viewModel.fetchWeather(cityName: cityName)
                            }
                        } label: {
                            HStack {
                                WeatherButton(title: "Check out this City")
                            }
                        }
                        
                        Button {
                            viewModel.requestLocation()
                        } label: {
                            ZStack {
                                Image(systemName: "location")
                                    .foregroundColor(.white)
                                    .font(.system(size: 28.0).bold())
                            }
                            .frame(width: 52.0, height: 52.0)
                        }
                        Spacer()
                    }
                }
                
                VStack {
                    if let city = viewModel.info.cityName {
                        CityView(cityName: city)
                            .padding(.bottom,40)
                    }
                    
                    ScrollView(.horizontal) {
                        HStack(spacing:40) {
                            
                            if let temp = viewModel.info.temp,
                               let image = viewModel.info.icon {
                                WeatherDayView(tempDetails:"Temperature" , image: image, value: String(temp) + "°F")
                                
                            }
                            
                            if let windSpeed = viewModel.info.windSpeed {
                                WeatherDayView(tempDetails: "Wind Speed", image: Image(systemName: "wind"), value: String(windSpeed)+"KPh")
                            }
                            
                            if let visibility = viewModel.info.visibility {
                                WeatherDayView(tempDetails: "Visibility", image: Image(systemName: "cloud.fog"), value: String(visibility)+"M")
                            }
                            
                        }
                        .padding(10)
                    }
                }
                
                Spacer()
            }
        }
        .alert("Error fetching location, please check your location settings and try again.", isPresented: $viewModel.locationError) {
            Button("Okay") { }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct BakcgroundView:View {
    @Binding var isNight:Bool
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [isNight ? .black: .blue,isNight ? .gray: Color("LightBlue")]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
    }
}

struct CityView: View {
    var cityName:String
    var body: some View {
        Text(cityName)
            .font(.system(size: 28, weight: .medium, design: .default))
            .foregroundColor(.white)
            .padding()
    }
}
struct WeatherDayView:View {
    
    var tempDetails:String
    var image:Image
    var value:String
    
    var body: some View {
        VStack() {
            Text(tempDetails)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            image
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40, alignment: .center)
            Text("\(value)")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

struct WeatherButton:View {
    var title:String
    var body: some View {
        Text(title)
            .frame(width: 220.0, height: 50.0)
            .background(.white)
            .font(.system(size: 20, weight: .bold, design: .default))
            .cornerRadius(30)
    }
}


