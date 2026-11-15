import SwiftUI

/// A Liquid Glass search bar: the magnifier, the words, and a clear button once something is typed.
/// Used instead of `.searchable`, which on iOS 26 shrinks the large title and hides the sheet's Done button.
struct SearchField: View {
    var prompt = ""
    @Binding var text: String
    var focus: FocusState<Bool>.Binding

    /// The bar's height, which buttons beside it match.
    static let height: CGFloat = 52

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            TextField("Search", text: $text, prompt: Text(prompt))
                .focused(focus)
                .submitLabel(.search)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            if !text.isEmpty {
                Button("Clear", systemImage: "xmark.circle.fill") { text = "" }
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.secondary)
            }
        }
        .font(.title3)
        .padding(.horizontal, 16)
        .frame(height: Self.height)
        .glassEffect(.regular.interactive(), in: .capsule)
    }
}
