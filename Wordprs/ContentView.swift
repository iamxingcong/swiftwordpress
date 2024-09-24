import SwiftUI

import UIKit



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
 

struct HTMLTextView: UIViewRepresentable {
    let htmlContent: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        guard let data = htmlContent.data(using: .utf8) else { return }
        
        
        let attributedOptions: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        if let attributedString = try? NSAttributedString(data: data, options: attributedOptions, documentAttributes: nil) {
            uiView.attributedText = attributedString
        }
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
                    //   Text(model.content.rendered)
                    //    .font(.subheadline)
                     
                    HTMLTextView(htmlContent: model.content.rendered)
                                
                       
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


