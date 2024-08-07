import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import CryptoKit

struct ContentView: View {
    
    @State private var passwords: [Password] = []
    @State private var selectedCategory: String? = nil
    @State private var showingAddPasswordView = false
    @State private var searchQuery = ""
    @State private var selectedTab: Tab = .home
    let db = Firestore.firestore()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopSection(searchQuery: $searchQuery, showingAddPasswordView: $showingAddPasswordView)
                
                CategorySelector(selectedCategory: $selectedCategory)
                    .padding(.vertical)
                
                PasswordList(filteredPasswords: filteredPasswords)
                
                BottomNavigation(selectedTab: $selectedTab)
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationTitle("Homepage")
            .toolbarBackground(Color.clear, for: .navigationBar)
            .sheet(isPresented: $showingAddPasswordView) {
                AddPasswordView(passwords: $passwords, db: db)
            }
            .onAppear {
                fetchPasswords()
                EncryptionHelper.setupKey()
            }
        }
    }
    
    var filteredPasswords: [Password] {
        if let selectedCategory = selectedCategory {
            return passwords.filter { $0.category == selectedCategory && ($0.name.contains(searchQuery) || searchQuery.isEmpty) }
        } else {
            return passwords.filter { $0.name.contains(searchQuery) || searchQuery.isEmpty }
        }
    }
    
    func fetchPasswords() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        print("User ID: \(userId)")
        
        db.collection("users").document(userId).collection("passwords").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                passwords = querySnapshot!.documents.map { doc in
                    let data = doc.data()
                    let username = data["username"] as! String
                    let encryptedPassword = data["password"] as! String
                    let url = data["url"] as! String
                    
                    print("Username: \(username)")
                    print("Encrypted Password: \(encryptedPassword)")
                    print("URL: \(url)")
                    
                    if let decryptedPassword = EncryptionHelper.decryptPassword(encryptedPassword) {
                        print("Decrypted Password: \(decryptedPassword)")
                        return Password(name: username, value: decryptedPassword, category: url, logo: "placeholder")
                    } else {
                        print("Failed to decrypt password for username: \(username)")
                        return Password(name: username, value: "", category: url, logo: "placeholder")
                    }
                }
            }
        }
    }
    
    struct TopSection: View {
        @Binding var searchQuery: String
        @Binding var showingAddPasswordView: Bool
        
        var body: some View {
            HStack {
                TextField("Search", text: $searchQuery)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                Button(action: {
                    showingAddPasswordView = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.yellow)
                        .clipShape(Circle())
                }
                .padding(.trailing)
            }
            .padding(.vertical)
            .background(Color.black)
        }
    }
    
    struct CategorySelector: View {
        @Binding var selectedCategory: String?
        let categories = ["All", "Social Media", "Work", "Finance"]
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category == "All" ? nil : category
                        }) {
                            Text(category)
                                .padding()
                                .background(selectedCategory == category ? Color.yellow : Color(.systemGray6))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    struct PasswordList: View {
        var filteredPasswords: [Password]
        
        var body: some View {
            ScrollView {
                LazyVStack {
                    ForEach(filteredPasswords, id: \.id) { password in
                        NavigationLink(destination: PasswordDetailView(password: password)) {
                            HStack {
                                if let logo = UIImage(named: password.logo) {
                                    Image(uiImage: logo)
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .padding(.trailing, 8)
                                }
                                VStack(alignment: .leading) {
                                    Text(password.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(password.value)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "heart")
                                    .foregroundColor(.yellow)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
    }
    
    struct BottomNavigation: View {
        @Binding var selectedTab: Tab
        
        var body: some View {
            HStack {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Spacer()
                    Button(action: {
                        selectedTab = tab
                    }) {
                        VStack {
                            Image(systemName: tab.iconName)
                                .font(.title2)
                                .foregroundColor(selectedTab == tab ? .yellow : .white)
                            Text(tab.rawValue.capitalized)
                                .font(.caption)
                                .foregroundColor(selectedTab == tab ? .yellow : .white)
                        }
                    }
                    Spacer()
                }
            }
            .padding()
            .background(Color.black)
        }
    }
    
    enum Tab: String, CaseIterable {
        case home, analysis, generate, profile
        
        var iconName: String {
            switch self {
            case .home:
                return "house"
            case .analysis:
                return "chart.bar"
            case .generate:
                return "key"
            case .profile:
                return "person.crop.circle"
            }
        }
    }
    
    struct Password: Identifiable {
        var id = UUID()
        var name: String
        var value: String
        var category: String
        var logo: String
    }
    
    struct AddPasswordView: View {
        @Environment(\.dismiss) var dismiss
        @Binding var passwords: [Password]
        let db: Firestore
        
        @State private var name: String = ""
        @State private var value: String = ""
        @State private var category: String = "Social Media"
        @State private var logo: String = "placeholder"
        
        var body: some View {
            NavigationStack {
                Form {
                    Section(header: Text("Password Details")) {
                        TextField("Name", text: $name)
                        TextField("Value", text: $value)
                        Picker("Category", selection: $category) {
                            Text("Social Media").tag("Social Media")
                            Text("Work").tag("Work")
                            Text("Finance").tag("Finance")
                        }
                    }
                    
                    Button(action: addPassword) {
                        Text("Save")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .padding()
                    }
                }
                .navigationTitle("Add Password")
            }
        }
        
        func addPassword() {
            let newPassword = Password(name: name, value: value, category: category, logo: logo)
            passwords.append(newPassword)
            savePasswordToDB(password: newPassword)
            dismiss()
        }
        
        func savePasswordToDB(password: Password) {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            let encryptedPassword = EncryptionHelper.encryptPassword(password.value)
            db.collection("users").document(userId).collection("passwords").addDocument(data: [
                "username": password.name,
                "password": encryptedPassword,
                "url": password.category
            ]) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Document added successfully")
                }
            }
        }
    }
    
    struct PasswordDetailView: View {
        var password: Password
        
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    if let logo = UIImage(named: password.logo) {
                        Image(uiImage: logo)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding(.trailing, 8)
                    }
                    VStack(alignment: .leading) {
                        Text(password.name)
                            .font(.largeTitle)
                            .bold()
                        Text(password.category)
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                
                Text("Password: \(password.value)")
                    .font(.title3)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Password Details")
        }
    }
}

    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
