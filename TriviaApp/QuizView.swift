//
//  QuizView.swift
//  TriviaApp
//
//  Created by Richard Brito on 10/29/25.
//

import SwiftUI

struct QuizView: View {
    let questions: [TriviaQuestion]

    @State private var currentQuestion = 0
    @State private var score = 0
    @State private var showAnswer = false
    @State private var answerWasCorrect: Bool? = nil
    @State private var quizFinished = false

    var body: some View {
        VStack {
            if quizFinished {
                VStack(spacing: 20) {
                    Text("Quiz Finished!")
                        .font(.largeTitle)
                        .bold()
                    Text("Your Score: \(score) / \(questions.count)")
                        .font(.title2)
                    Button("Play Again") {
                        resetQuiz()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .transition(.scale)
            } else {
                let question = questions[currentQuestion]

                VStack(spacing: 30) {
                    Text(question.category)
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text(question.question)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding()

                    HStack(spacing: 40) {
                        Button("True") {
                            checkAnswer("True")
                        }
                        .buttonStyle(QuizButtonStyle())

                        Button("False") {
                            checkAnswer("False")
                        }
                        .buttonStyle(QuizButtonStyle())
                    }

                    if showAnswer {
                        Text(answerWasCorrect == true ? "✅ Correct!" : "❌ Wrong!")
                            .font(.headline)
                            .foregroundColor(answerWasCorrect == true ? .green : .red)
                            .padding(.top)

                        Button("Next Question") {
                            nextQuestion()
                        }
                        .padding(.top, 10)
                    }

                    Spacer()

                    Text("Question \(currentQuestion + 1) of \(questions.count)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding()
                .animation(.easeInOut, value: showAnswer)
            }
        }
        .navigationTitle("Quiz")
    }

    private func checkAnswer(_ userAnswer: String) {
        let correct = questions[currentQuestion].correct_answer == userAnswer
        answerWasCorrect = correct
        if correct {
            score += 1
        }
        showAnswer = true
    }

    private func nextQuestion() {
        if currentQuestion + 1 < questions.count {
            currentQuestion += 1
            showAnswer = false
            answerWasCorrect = nil
        } else {
            quizFinished = true
        }
    }

    private func resetQuiz() {
        currentQuestion = 0
        score = 0
        showAnswer = false
        answerWasCorrect = nil
        quizFinished = false
    }
}

// Reusable button style
struct QuizButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 120, height: 44)
            .background(configuration.isPressed ? Color.blue.opacity(0.7) : Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}
