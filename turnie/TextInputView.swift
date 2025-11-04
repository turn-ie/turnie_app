import SwiftUI

struct TextInputView: View {
    @State private var inputText = ""
    @ObservedObject var bleManager: BLEManager
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            VStack(){
                TextField("いまの気分は？", text: $inputText)
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
                    Text("ピクチャを登録")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(AccentProminentButtonStyle())
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .navigationTitle("テキストをおくる")
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
