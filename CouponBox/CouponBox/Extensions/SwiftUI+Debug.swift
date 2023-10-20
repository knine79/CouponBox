//
//  SwiftUI+Debug.swift
//  itBookStore
//
//  Created by Samuel Kim on 2023/07/05.
//

import SwiftUI
import CouponBox_BusinessRules

struct Log: View {
    init(_ logMessage: Any, file: String = #file, line: Int = #line) {
        printLog(logMessage, file: file, line: line)
    }
    
    public var body: some View {
        EmptyView()
    }
}

extension View {
    @ViewBuilder
    func borderForPreview(_ color: Color = .blue, fill: Bool = false) -> some View {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            if fill {
                background(color)
            } else {
                border(color)
            }
        } else {
            self
        }
    }
    
    @ViewBuilder
    func carveLog(_ message: String, font: Font? = nil, alignment: Alignment = .center) -> some View {
#if DEBUG
        if CommandLine.arguments.contains("logCarving") {
            ZStack(alignment: alignment) {
                self
                Button {
                    let pasteBoard = UIPasteboard.general
                    pasteBoard.string = message
                } label: {
                    StrokeText(text: message, font: font ?? .system(size: 12), color: .gray.opacity(0.5))
                        .lineLimit(1)
                        .foregroundColor(.red)
                        .padding(3)
                }
                .buttonStyle(.plain)
            }
        } else {
            self
        }
#else
        self
#endif
    }
}

private struct StrokeText: View {
    let text: String
    let font: Font
    let color: Color

    var body: some View {
        Text(text)
            .font(font)
            .padding(.horizontal, 2)
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .foregroundColor(color)
            )
    }
}
