import SwiftUI

struct ComposeMailView: View {
    var account: Account
    @Binding var draft: DraftMessage
    var onSend: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Gönderen") {
                    HStack {
                        Text(account.displayName)
                        Spacer()
                        Text(account.emailAddress)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .font(.subheadline)
                }

                Section("Alıcı") {
                    TextField("Kime", text: $draft.to)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("CC", text: $draft.cc)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }

                Section("İçerik") {
                    TextField("Konu", text: $draft.subject)
                    TextEditor(text: $draft.body)
                        .frame(minHeight: 180)
                }
            }
            .navigationTitle("Yeni Mail")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gönder") {
                        onSend()
                        dismiss()
                    }
                    .disabled(draft.to.isEmpty)
                }
            }
        }
    }
}
