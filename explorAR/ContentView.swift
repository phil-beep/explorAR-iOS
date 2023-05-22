//
//  ContentView.swift
//  explorAR
//
//  Created by Philipp-Michael Handke on 04.02.23.
//

import SwiftUI
import UIKit

private let initialSentence : String = "Start drawing 👇"

struct Line {
    var points = [CGPoint]()
    var color: Color = .primary
    var lineWidth: Double = 5.0
}

struct ContentView: View {
    @State private var currentLine = Line()
    @State private var lines: [Line] = []
    @State private var drawingName: String = initialSentence
    @State private var showingAlert = false
    @State private var openSettings = false
    @State private var axis: CGFloat = 350
    @State private var target_res: Int = 128
    @State private var hideARbutton = true
    @State private var models: [String] = ["shark", "octopus", "dolphin", "crab", "whale"]
    @State private var randomFact: String = ""
    @State private var showingFact = false
    @State private var currentAnimal: String = ""
    private let defaults = UserDefaults.standard
    @State private var showAR : Bool = false
 //Bundle.main.infoDictionary!["API_SERVER_DOMAIN"] as! String
    
    var body: some View {
        NavigationView {
            HStack {
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {openSettings.toggle()}){
                        Image(systemName: "ellipsis")
                    }
                    .controlSize(.large)
                    .foregroundColor(Color.accentColor)
                }
            }
        }

        VStack(alignment: .center) {
            
            Text(drawingName)
                .font(.system(size: 36, weight: .bold))
            
            Canvas { context, size in
                for line in lines {
                    var path = Path()
                    path.addLines(line.points)
                    context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
                }
            }
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged({ value in
                    drawingName = "Done?"
                    let newPoint = value.location
                    
                    let x_normalized = normalize(value: newPoint.x)
                    let y_normalized = normalize(value: newPoint.y)
                    if(((y_normalized >= 0) && (y_normalized <= target_res)) && ((x_normalized >= 0) && (x_normalized <= target_res))){
                        currentLine.points.append(newPoint)
                        self.lines.append(currentLine)
                    }
                })
                .onEnded({ value in
                    self.currentLine = Line()
                })
            )
            .frame(width: axis, height: axis)
            .border(Color.gray)
            
            HStack {
                Button(action: cleanDrawing) {
                    HStack {
                        Image(systemName:"trash")
                        Text("Clean")
                    }
                }
                .buttonStyle(.bordered)
                .disabled(lines.isEmpty ? true : false)
                .foregroundColor(lines.isEmpty ? Color.gray : Color.red)
                .controlSize(.large)
                .cornerRadius(8)
                
                Button(action: analyzeDrawing) {
                    HStack {
                        Image(systemName:"eye")
                        Text("Analyze")
                    }
                }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(lines.isEmpty ? true : false)
                
            }
            .padding(.bottom, 20)
            HStack {
                Button(action: showRandomFact) {
                    HStack {
                        Image(systemName:"lightbulb")
                        Text("Fact")
                    }
                }
                .buttonStyle(.bordered)
                .foregroundColor(Color.accentColor)
                .controlSize(.large)
                .cornerRadius(8)
                
                
                Button(action: {showAR = true}) {
                    HStack {
                        Image(systemName:"arkit")
                        Text("AR View")
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .cornerRadius(8)
                .disabled(hideARbutton ? true : false)
            }
            .opacity(currentAnimal == "" ? 0 : 1)
        }
        .padding(.bottom, 100)
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Error"),
                message: Text(drawingName),
                dismissButton: .default(Text("Ok"))
            )
        }
        .alert(isPresented: $showingFact) {
            Alert(
                title: Text("Random Fact"),
                message: Text(randomFact),
                dismissButton: .default(Text("Close"))
            )
        }
        
        .sheet(isPresented: $openSettings) {
            SettingsView()
        }
        
        .sheet(isPresented: $showAR) {
            RealityKitView(currentAnimal: $currentAnimal)
                .ignoresSafeArea()
        }
    }
    
    func cleanDrawing() {
        if (!lines.isEmpty) {
            lines = []
            drawingName = initialSentence
            currentAnimal = ""
            hideARbutton = true
        }
    }
        
    func normalize(value: CGFloat) -> Int {
        return Int((value.rounded(.towardZero) / axis * CGFloat(target_res)).rounded(.towardZero))
    }
    
    func analyzeDrawing() {
        hideARbutton = true
        drawingName = "Let me think 🤔"
        
        let url = URL(string: getAPIHost() + "/identify_drawing/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let outer = rearrangeDrawingCoords()

        let data = ["client" : "hololens", "dots_connected" : false, "drawing" : outer] as [String : Any]
        let bodyData = try? JSONSerialization.data(
            withJSONObject: data,
            options: []
        )
        request.httpBody = bodyData
        handleResponse(request)
    }
    
    func getAPIHost() -> String {
        //return "https://api.explor-ar.de"

        guard let plistPath = Bundle.main.path(forResource: "Configuration", ofType: "plist"),
              let plistData = FileManager.default.contents(atPath: plistPath),
              let plistDictionary = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any],
              let stringValue = plistDictionary["API_SERVER_DOMAIN"] as? String else {
            print("Unable to read string from plist")
            return ""
        }

        return stringValue
    }
    
    func rearrangeDrawingCoords() -> [[[Int]]] {
        var outer : [[[Int]]] = []
        
        for line in lines {
            var container : [[Int]] = []
            var x_lines : [Int] = []
            var y_lines : [Int] = []
            for point in line.points {
                x_lines.append(normalize(value: point.x))
                y_lines.append(normalize(value: point.y))
            }
            container.append(x_lines)
            container.append(y_lines)
            outer.append(container)
        }
        return outer
    }
    
    func handleResponse(_ request: URLRequest) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                if let error = error {
                    drawingName = error.localizedDescription
                    showingAlert = true
                } else if let data = data {
                    var responseData = String(decoding: data, as: UTF8.self)
                    responseData = responseData.replacingOccurrences(of: "\"", with: "")
                    
                    currentAnimal = responseData
                    checkARavailability(responseData: responseData)
                    
                    let article = responseData == "octopus" ? "an" : "a"
                    responseData = responseData.capitalized
                    drawingName = "That's " + article + " " + responseData + "!"
                } else {
                    drawingName = "unknown error"
                }
            }
        }
        task.resume()
    }
    
    func checkARavailability(responseData: String) {
        if(models.contains(responseData)) {
            hideARbutton = false;
        }
    }
    
    func showRandomFact(){
        let url = URL(string: getAPIHost() + "/animal_fact/" + currentAnimal)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic YXBpLXVzZXI6Sk1Daklpc2tTdm9GY0w0QkZhZXh3UmlHaVMyaXMzRmg=", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                if let error = error {
                    drawingName = error.localizedDescription
                    showingAlert = true
                } else if let data = data {
                    let responseData = String(decoding: data, as: UTF8.self)
                    randomFact = responseData
                    showingFact = true
                }
            }
        }
        task.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
