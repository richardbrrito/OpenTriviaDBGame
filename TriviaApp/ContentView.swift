import SwiftUI

struct ContentView: View {
    @State private var numberOfQuestions = ""
    @State private var selectedCategory = "Any Category"
    @State private var selectedType = "Any Type"
    @State private var selectedDifficulty = "Select Difficulty"
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToQuiz = false
    @State private var quizQuestions: [TriviaQuestion] = []


    let categories = ["Any Category", "General Knowledge", "Mythology", "Sports", "History", "Art"]
    let types = ["Any Type" ,"Multiple Choice", "True / False"]
    let difficulty = ["Select Difficulty" , "Easy", "Medium", "Hard"]

    var body: some View {
        NavigationStack{
            ZStack(alignment: .top) {
                Color.blue.ignoresSafeArea(edges: .top)
                
                VStack(spacing: 25) {
                    Text("Trivia Game")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.top, 60)
                        .padding(.bottom, 30)
                    
                    VStack(spacing: 0) {
                        HStack {
                            Text("Number of Questions")
                            Spacer()
                            TextField("Enter a number", text: $numberOfQuestions)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 120)
                        }
                        .padding()
                        Divider()
                        
                        HStack {
                            Text("Select Difficulty")
                            Spacer()
                            Picker("Select Difficulty", selection: $selectedDifficulty) {
                                ForEach(difficulty, id: \.self) { difficulty in
                                    Text(difficulty)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .padding()
                        
                        HStack {
                            Text("Select Category")
                            Spacer()
                            Picker("Select Category", selection: $selectedCategory) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .padding()
                        
                        HStack {
                            Text("Select Type")
                            Spacer()
                            Picker("Select Type", selection: $selectedType) {
                                ForEach(types, id: \.self) { type in
                                    Text(type)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .padding()
                        
                        Button(action: startQuiz) {
                            Text("Start Quiz")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            .navigationDestination(isPresented: $navigateToQuiz) {
                QuizView(questions: quizQuestions)
            }
        }
        .alert("Trivia Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    func startQuiz() {
        guard let questionCount = Int(numberOfQuestions), questionCount > 0 else {
            alertMessage = "Please enter a valid number of questions."
            showAlert = true
            return
        }

        var urlString = "https://opentdb.com/api.php?amount=\(questionCount)"
        let categoryIDs: [String: Int] = [
            "General Knowledge": 9,
            "Mythology": 20,
            "Sports": 21,
            "History": 23,
            "Art": 25
        ]
        if let categoryID = categoryIDs[selectedCategory] {
            urlString += "&category=\(categoryID)"
        }
        if selectedDifficulty != "Select Difficulty" {
            urlString += "&difficulty=\(selectedDifficulty.lowercased())"
        }
        if selectedType == "Multiple Choice" {
            urlString += "&type=multiple"
        } else if selectedType == "True / False" {
            urlString += "&type=boolean"
        }

        print("Final API URL: \(urlString)")
        fetchTrivia(from: urlString)
    }

    func fetchTrivia(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
                    DispatchQueue.main.async {
                        print("data:", decoded)
                        if decoded.response_code == 1 {
                            alertMessage = "No results found for the selected options."
                            showAlert = true
                        } else if decoded.response_code == 0 {
                            DispatchQueue.main.async {
                                quizQuestions = decoded.results
                                navigateToQuiz = true
                            }
                        } else {
                            alertMessage = "Unexpected API response."
                            showAlert = true
                        }
                    }
                } catch {
                                        DispatchQueue.main.async {
                        alertMessage = "Failed to decode trivia data."
                        showAlert = true
                    }
                }
            }
        }.resume()
    }
}

struct TriviaResponse: Decodable {
    let response_code: Int
    let results: [TriviaQuestion]
}

struct TriviaQuestion: Decodable, Identifiable {
    let id = UUID()
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}
