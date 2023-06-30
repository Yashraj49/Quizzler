//
//  QuestionsView.swift
//  Quizzler
//
//  Created by Yashraj jadhav on 13/06/23.
//

import SwiftUI
import FirebaseFirestore

struct QuestionsView: View {
    var info : Info
    @State var questions : [Question]
    var onFinish : ()->()
    
    // View properties
    let randomCustomTransition =  Bool.random() ? AnyTransition.move(edge: .leading) : AnyTransition.identity

    
    
    @Environment(\.dismiss) private var dismiss
    @State private var progress: CGFloat = 0
    @State private var currentIndex : Int = 0
    @State private var score: CGFloat = 0
    @State private var showScoreCard : Bool = false
    
    var body: some View {
    
        VStack(spacing:15){
            Button{
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .hAlign(.leading)
            Text(info.title)
                .font(.title)
                .fontWeight(.semibold)
                .hAlign(.leading)
            
            GeometryReader {
                let size = $0.size
                ZStack(alignment: .leading){
                    Rectangle()
                        .fill(.black.opacity(0.2))
                    
                    Rectangle()
                        .fill(.pink)
                        .frame(width: progress * size.width,alignment: .leading)
                }
                .clipShape(Capsule())
            }
            .frame(height: 20)
            .padding(.top,5)
            
            // Questions
            
            GeometryReader {_ in
                ForEach(questions.indices, id: \.self) { index in
                    // using tranbsitions
                    
                    if currentIndex == index{
                        QuestionView(questions[currentIndex])
                            .transition(randomTransition())

                    }
                }
            }
            .padding(.vertical , 15)
            .padding(.vertical, -15)
            
            Home.CustomButton(title : currentIndex == (questions.count - 1) ? "Finish" : "Next Question") {
                if currentIndex == (questions.count - 1) {
                    showScoreCard.toggle()
                }else{
                    withAnimation(.easeIn) {
                        currentIndex += 1
                        progress = CGFloat(currentIndex) / CGFloat(questions.count - 1 )
                    }
                }
            }
        }
        .padding(15)
        .hAlign(.center).vAlign(.top)
        .background{
            Color(uiColor: .systemTeal)
                .ignoresSafeArea()
        }
        .environment(\.colorScheme, .dark)
        .fullScreenCover(isPresented: $showScoreCard){
            // Discplay in 100 %
            ScoreCardView(score: score / CGFloat(questions.count) * 100){
                // closing view
                dismiss()
                onFinish()
            }
        }
    }
    
    func randomTransition() -> AnyTransition {
        let transitions: [AnyTransition] = [
            .opacity,
            .move(edge: .top),
            .scale,
            .move(edge: .leading),
            .move(edge: .trailing),
            .scale(scale: 0.5).combined(with: .opacity),
            .asymmetric(insertion: .push(from: .bottom), removal: .move(edge: .leading))
        ]
        let randomIndex = Int.random(in: 0..<transitions.count)
        return transitions[randomIndex]
    }

    
    // Question View
    @ViewBuilder
    func QuestionView(_ question : Question)-> some View {
        VStack(alignment: .leading, spacing: 15 ){
            Text("Question\(currentIndex + 1)/\(questions.count)")
                .font(.callout)
                .foregroundColor(.gray)
                .hAlign(.leading)
            
            Text(question.question)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            VStack(spacing: 12){
                ForEach(question.options,id: \.self) {option in
                    
                    // displaying correct and wrong answers after user has Tapped
                    ZStack{
                        
                        optionView(option , .gray)
                            .opacity(question.answer == option && question.tappedAnswer != "" ? 0 : 1)
                        optionView(option , .green)
                            .opacity(question.answer == option && question.tappedAnswer != "" ? 1 : 0)
                        optionView(option , .red)
                            .opacity(question.tappedAnswer == option && question.tappedAnswer != question.answer ? 1 : 0)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Disabling tap if already answer was selected
                        
                        guard questions[currentIndex].tappedAnswer == ""else{return}
                        withAnimation(.easeInOut){
                            questions[currentIndex].tappedAnswer = option
                            /// whenever the correct answer , updating the score
                            if question.answer == option {
                                score += 1.0
                            }
                        }
                        
                    }
                }
                
            }
            .padding(.vertical , 12)
        }
        .padding(15)
        .hAlign(.center)
        .background{
            RoundedRectangle(cornerRadius:  20 , style: .continuous)
            
                .fill(.white)
            
        }
        .padding(.horizontal , 15)
    }
    
    @ViewBuilder
    func optionView(_ option: String, _ tint: Color) -> some View {
        HStack {
            Text(option)
                .font(.headline)
                .foregroundColor(tint)
                .padding(.leading, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if tint == .green {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.black)
                    .padding(.trailing, 20)
            } else if tint == .red {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.black)
                    .padding(.trailing, 20)
            }
        }
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(tint.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(tint, lineWidth: 2)
                )
        )
        .padding(.horizontal, 20)
    }

        
    }

struct ScoreCardView : View {
    var score: CGFloat
    // Moving to homee when this view was diesmissed
    var onDismiss: ()->()
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack{
            VStack(spacing: 15){
                Text("Result of You Exercise")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                VStack(spacing: 15){
                    Text("Congratulations! You\n have score")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    // Removing Flotation points
                    Text(String(format:"%.0f" , score) + "%")
                        .font(.title.bold())
                        .padding(.bottom, 10)
                    
                    Image("BGIMG")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 220)
                }
                .foregroundColor(.black)
                .padding(.horizontal,15)
                .padding(.vertical,20)
                .hAlign(.center)
                .background{
                    RoundedRectangle(cornerRadius: 25 , style: .continuous)
                        .fill(.white)
                }
            }
            .vAlign(.center)
            
            Home.CustomButton(title: "Back to Home") {
                // before closign updating people attending count on Firebase
                Firestore.firestore().collection("Quiz").document("Info").updateData([
                    "peopleAttended" : FieldValue.increment(1.0)
                ])
                onDismiss()
                dismiss()
            }
        }
        .padding(15)
        .background{
            Color(uiColor: .systemTeal)
                .ignoresSafeArea()
        }
    }
}
