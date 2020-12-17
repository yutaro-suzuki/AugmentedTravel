//
//  ContentView.swift
//  Destination
//
//  Created by Yutaro Suzuki on 2020/12/08.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @State var showCamera: Bool = true
    @ObservedObject var model: DestinationModel = DestinationModel()
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            MapView()
                .environmentObject(self.model)
                .edgesIgnoringSafeArea(.all)
            Button(action:{
                self.showCamera = true
            }){
                ZStack{
                    RoundedRectangle(cornerRadius: 10, style: .circular)
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 50, height: 50, alignment: .center)
                        .shadow(color: .black, radius: 1, x: 1, y: 1)
                    Image(systemName: "camera")
                        .resizable()
                        .foregroundColor(.blue)
                        .frame(width: 20, height: 20, alignment: .center)
                }
            }
        }.fullScreenCover(isPresented: $showCamera) {
            ZStack(alignment: .topTrailing){
                CameraView()
                    .environmentObject(self.model)
                    .edgesIgnoringSafeArea(.all)
                Button(action:{
                    self.showCamera = false
                }){
                    ZStack{
                        RoundedRectangle(cornerRadius: 10, style: .circular)
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 50, height: 50, alignment: .center)
                            .shadow(color: .black, radius: 1, x: 1, y: 1)
                        Image(systemName: "mappin.and.ellipse")
                            .resizable()
                            .foregroundColor(.blue)
                            .frame(width: 30, height: 30, alignment: .center)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
