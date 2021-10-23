import SwiftUI

struct Response: Codable {
    var results: [Result]
}

struct Result: Codable {
    var trackId: Int
    var trackName: String
    var collectionName: String
}

func getJson(from url: String, cb: @escaping ([Result]) -> Void) {
    guard let urlObject = URL(string: url) else {
        print("invalid URL")
        return
    }
    
    let request = URLRequest(url: urlObject)
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let data = data {
            if let decoded = try? JSONDecoder().decode(Response.self, from: data) {
                DispatchQueue.main.async {
                    let results = decoded.results.sorted {
                        $0.trackName < $1.trackName
                    }
                    cb(results)
                }
                return
            }
        }
        
        print("Fetch failed: \(error?.localizedDescription ?? "unknown error")")
    }.resume()
    
}

struct ContentView: View {
    //@State var artist = "Radiohead"
    @State var artist = "Taylor Swift"
    @State var results = [Result]() // creates an empty array
    
    var body: some View {
        VStack {
            TextField("Artist Name", text: $artist )
                .autocapitalization(.none)
                .padding()
                .textFieldStyle(.roundedBorder)
            Button("Search", action: loadData)
            List(results, id: \.trackId) { item in
                VStack(alignment: .leading) {
                    Text(item.trackName).font(.headline)
                    Text(item.collectionName)
                }
            }
            //}.onAppear(perform: loadData)
        }
    }
    
    func loadData() {
        let term = artist.lowercased().replacingOccurrences(of: " ", with: "+")
        let url = "https://itunes.apple.com/search?term=\(term)&entity=song"
        getJson(from: url) { results in self.results = results }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
