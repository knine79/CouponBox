//
//  SelectableTextField.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/30/23.
//

import SwiftUI

struct SelectableTextField: View {
    @State private var confirmationPresented = false

    let title: String
    let value: Binding<String>
    let candidates: [String]
    let placeholder: String
    let selectionDescription: String
    init(title: String, value: Binding<String>, candidates: [String], placeholder: String, selectionDescription: String) {
        self.title = title
        self.value = value
        self.candidates = candidates
        self.placeholder = placeholder
        self.selectionDescription = selectionDescription
    }
    
    var body: some View {
        HStack() {
            Text(title)
                .bold()
                .frame(width: 60, alignment: .leading)
            TextField(placeholder, text: value)
                .textFieldStyle(.roundedBorder)
                .confirmationDialog(selectionDescription, isPresented: $confirmationPresented, titleVisibility: .visible) {
                    ForEach(candidates, id: \.hashValue) { candidate in
                        Button(candidate) {
                            value.wrappedValue = candidate
                        }
                    }
                }
            Button("선택".locaized) {
                confirmationPresented.toggle()
            }
            .disabled(candidates.isEmpty)
        }
    }
}
