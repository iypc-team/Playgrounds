// iExpense SwiftUI Tutorial 1/11
//  07/20/2025
// .multilineTextAlignment(.center)

import SwiftUI


struct ContentView: View {
    @State private var user = User()
    
    let backgroundGradient = LinearGradient(
        colors: [Color.navyBlue, Color.cardinalRed],
        startPoint: .top, endPoint: .bottom)
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack {
                Image(systemName: "house.fill")
                    .font(.system(size: 125, weight: nil, design: nil))
                    .foregroundColor(.cardinalRed)
                Text("iExpense")
                    .font(.system(size: 40, weight: .heavy, design: .default))
                    .padding()
                
                
                Text("Full name  \(user.firstName) \(user.lastName)")
                    
                Spacer(minLength: 1)
                
                TextField("First name:", text: $user.firstName)
                    
                    
                TextField("Last name", text: $user.lastName)
                    
                Spacer(minLength: 10)
                Text("Edits: \(user.edits)")
                    
                Spacer(minLength: 10)
                
                Button(action: {user.buttonPressed()}, label: {
                    Text("Edits")
                })
                .cornerRadius(200)
                .border(Color.white)
                .background(Color.navyBlue)
                .foregroundColor(.white)
                .font(.system(size: 30, weight: .regular, design: .default))
            }
            .padding(25)
        }
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
        .font(.system(size: 18, weight: .heavy, design: .default))
    }
}


