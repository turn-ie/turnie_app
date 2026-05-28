import SwiftUI

struct TextInputView: View {
    @State private var inputText = ""
    @EnvironmentObject var bleManager: BLEManager
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            VStack(){
                TextField(NSLocalizedString("TextInput_Placeholder", comment: "Text input placeholder"), text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Spacer()
                
                Button(action: {
                    let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { return }
                    
                    let json: [String: Any] = [
                        "id": "p001",
                        "flag": "text",
                        "text": text
                    ]
                    bleManager.sendJSON(json)
                    inputText = ""
                    isPresented = false
                }) {
                    Text(NSLocalizedString("Common_RegisterPicture", comment: "Register picture button"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(AccentProminentButtonStyle())
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .navigationTitle(NSLocalizedString("TextInput_NavigationTitle", comment: "Text input view title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button() {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}
