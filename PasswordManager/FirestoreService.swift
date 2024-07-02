import FirebaseFirestore

struct Password: Identifiable {
    var id = UUID()
    var name: String
    var value: String
    var category: String
    var logo: String
}

class FirestoreService {
    private let db = Firestore.firestore()
    
    func savePassword(userId: String, password: Password) {
        let data: [String: Any] = [
            "name": password.name,
            "value": password.value,
            "category": password.category,
            "logo": password.logo
        ]
        db.collection("users").document(userId).collection("passwords").addDocument(data: data)
    }
    
    func getPasswords(userId: String, completion: @escaping ([Password]) -> Void) {
        db.collection("users").document(userId).collection("passwords").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }
            let passwords = documents.compactMap { doc -> Password? in
                let data = doc.data()
                guard let name = data["name"] as? String,
                      let value = data["value"] as? String,
                      let category = data["category"] as? String,
                      let logo = data["logo"] as? String else {
                    return nil
                }
                return Password(name: name, value: value, category: category, logo: logo)
            }
            completion(passwords)
        }
    }
}
