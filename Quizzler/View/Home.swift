//
//  Home.swift
//  Quizzler
//
//  Created by Yashraj jadhav on 12/06/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

struct Home: View {
    @State private var isLoading = false
    @State private var quizInfo : Info?
    @State private var questions : [Question] = []
    @State private var startQuiz : Bool = false
   
    // User anonymous Log Status
    @AppStorage("log_status") private var logStatus : Bool = false
    
    var body: some View {
        if let info = quizInfo {
            VStack(spacing: 10){
                Text(info.title)
                    .font(.title)
                    .fontWeight(.semibold)
                    .hAlign(.leading)
                
                // custom Label
                
                CustomLabel("list.bullet.rectangle.portrait","\(questions.count)","Multiple Choice Questions")
                .padding(.top,20)
                
                CustomLabel("person", "\(info.peopleAttended)", "Attended the exercise")
                    .padding(.top,5)
                
                
                
                Divider()
                    .padding(.horizontal,-15)
                    .padding(.top,15)
                
                if !info.rules.isEmpty {
                    RulesView(info.rules)
                }
                //
                CustomButton(title: "Start Test", onClick: {
                    startQuiz.toggle()
                })
                .vAlign(.bottom)
            }
            .padding(15)
            .vAlign(.top)
            .fullScreenCover(isPresented: $startQuiz){
                QuestionsView(info: info, questions: questions){
                    // user successfully finished the quiz
                    // so update the UI
                    quizInfo?.peopleAttended += 1
                    
                }
            }
            
        } else {
            VStack(spacing: 4) {
                ZStack {
                    Color(uiColor: .white)
                        .edgesIgnoringSafeArea(.all)
                    Circle()
                        .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round, dash: [4, 20]))
                        .frame(width: 100, height: 100, alignment: .center)
                        .foregroundColor(.black)
                        .onAppear() {
                            withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false))
                            {
                                isLoading.toggle()
                            }
                        }
                        .rotationEffect(Angle(degrees: isLoading ? 0 : 360))
                    Text("Please Wait")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .foregroundColor(.black)
                }
                
            }
            
            .task {
                do {
                   try await fetchData()
                } catch {
                    print(error.localizedDescription)
                    print(error.self)
                }
            }
        }
    }
    
    // Rules view
    @ViewBuilder
    func RulesView(_ rules: [String])->some View {
        VStack(alignment: .leading,spacing: 15) {
            Text("Before you start")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.bottom,12)
            
            ForEach(rules , id: \.self) {rule in
                HStack(alignment : .top , spacing: 10){
                    Circle()
                        .fill(.black)
                        .frame(width: 8 , height: 8)
                    Text(rule)
                        .font(.callout)
                        .lineLimit(30   )
                }
            }
        }
    }
    
    
    // custom Button
    
    struct CustomButton : View {
        var title : String
        var onClick : ()->()
        
        var body: some View {
            Button {
                onClick()
            } label: {
                Text(title)
                    .font(.title)
                    .fontWeight(.semibold)
                    .hAlign(.center)
                    .padding(.top,15)
                    .padding(.bottom,10)
                    .foregroundColor(.white)
                    .background{
                        Rectangle()
                            .fill(.pink)
                            .ignoresSafeArea()
                    }
            }
            .cornerRadius(35)
            .padding([.bottom],-15)
        }
    }
    
    // custom label
    
    @ViewBuilder
    func CustomLabel(_ image : String , _ title : String , _ subTitle : String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: image)
                .font(.title3)
                .frame(width: 45, height: 45)
                .background {
                    Circle()
                        .fill(.gray.opacity(0.1))
                        .padding(-1)
                        .background{
                            Circle()
                                .stroke(Color(.black),lineWidth: 1)
                        }
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(.black))
                Text(subTitle)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
            }
            .hAlign(.leading)
        }
    }
    // fetching Quiz and questions
    
    func fetchData() async throws{
       
        
            try await loginUserAnonymous()
            
            let info = try await Firestore.firestore().collection("Quiz").document("Info").getDocument().data(as: Info.self)
            
            let questions = try await
            Firestore.firestore().collection("Quiz").document("Info").collection("Questions ").getDocuments().documents.compactMap{
                try $0.data(as: Question.self)
            }
            // UI - Must be updated on main thread
            await MainActor.run(body: {
                self.quizInfo = info
                self.questions = questions
            })
        
    }
    // Login user as Anonymous for firestore Access
    
    func loginUserAnonymous()async throws{
        if !logStatus{
            try await Auth.auth().signInAnonymously()
        }
    }
}
struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

// Extensions

extension View {
    func hAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity , alignment: alignment)
    }
    
    func vAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity , alignment: alignment)
    }
    
}



{
    
}
