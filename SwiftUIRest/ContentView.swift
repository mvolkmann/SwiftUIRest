import SwiftUI

struct Response: Codable {
    var results: [Result]
}

struct Result: Codable {
    var trackId: Int
    var trackName: String
    var collectionName: String
}

/*
 func alert(title: String, error: Error) {
 let alert = UIAlertController(
 title: title,
 message: error.localizedDescription,
 preferredStyle: .alert
 )
 
 alert.addAction(UIAlertAction(
 title: "Dismiss",
 style: .default
 ))
 
 present(alert, animated: true)
 }
 */

//TODO: What is a better way to handle errors?
func getJson(from url: String, callback: @escaping ([Result], String?) -> Void) {
    guard let urlObject = URL(string: url) else {
        callback([], "invalid URL")
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
                    callback(results, nil)
                }
                return
            }
        }
        
        callback([], error?.localizedDescription ?? "unknown error")
    }.resume()
}

struct ContentView: View {
    @State var artist = "Radiohead"
    @State var message = ""
    @State var results = [Result]() // creates an empty array
    
    var body: some View {
        VStack {
            TextField("Artist Name", text: $artist )
                .autocapitalization(.none)
                .padding()
                .textFieldStyle(.roundedBorder)
            Button("Search", action: getSongs).disabled(artist.isEmpty)
            if !message.isEmpty {
                //TODO: How can you display this in a modal instead?
                Text(message).foregroundColor(.red).padding()
            }
            List(results, id: \.trackId) { item in
                VStack(alignment: .leading) {
                    Text(item.trackName).font(.headline)
                    Text(item.collectionName)
                }
            }
            //}.onAppear(perform: getSongs)
        }
        //.alert(item: error) { error in
        //    Alert(title: Text("Error"), message: Text(error), dismissButton: .cancel())
        //}
    }
    
    func getSongs() {
        if artist.isEmpty {
            message = "Enter an artist name."
            results = []
            return
        }
        
        let term = artist.lowercased().replacingOccurrences(of: " ", with: "+")
        let url = "https://itunes.apple.com/search?term=\(term)&entity=song"
        getJson(from: url) { results, error in
            if let error = error {
                message = error
            } else if results.isEmpty {
                message = "No songs found"
            } else {
                message = ""
            }
            self.results = results
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
