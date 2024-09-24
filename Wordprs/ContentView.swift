import SwiftUI


// 1. Define the data model for a WordPress post
struct Post: Identifiable, Codable {
    let id: Int
    let title: RenderedTitle
    let content: RenderedContent
    
    struct RenderedTitle: Codable {
        let rendered: String
    }
    
    struct RenderedContent: Codable {
        let rendered: String
    }
}
 
struct ContentView: View {

    @State var posts: [Post] = []

    var body: some View {
        NavigationView {
            List(posts, id:\.id) { model in
                VStack(alignment: .leading) {
                    Text(model.title.rendered)
                        .font(.headline)
                    Text(model.content.rendered)
                        .font(.subheadline)
                       
                }
            }
            .navigationTitle("WordPress Posts")
            .onAppear(perform:  fetchPosts )
        }
    }
}

 
extension ContentView{
   
    
    func fetchPosts() {
        guard let url = URL(string: "http://localhost:8080/wordpress/wp-json/wp/v2/posts") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    // 4. Decode the JSON response
                    let decodedPosts = try JSONDecoder().decode([Post].self, from: data)
                    DispatchQueue.main.async {
                        self.posts = decodedPosts
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            } else if let error = error {
                print("Error fetching data: \(error)")
            }
        }.resume()
    }
}


