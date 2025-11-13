import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var navigationPath = NavigationPath()
    @State private var columnVisibility = NavigationSplitViewVisibility.automatic
    @State private var isSidebarPresented = false
    @State private var isSearchActive = false

    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .phone {
                // iPhone: Normal NavigationStack + Sheet sidebar
                NavigationStack(path: $navigationPath) {
                    mainContent
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    isSidebarPresented = true
                                } label: {
                                    Image(systemName: "line.3.horizontal")
                                }
                            }
                        }
                }
                .sheet(isPresented: $isSidebarPresented) {
                    NavigationStack {
                        SidebarView(viewModel: viewModel, columnVisibility: .constant(.automatic), onAccountSelected: {
                            isSidebarPresented = false
                        })
                    }
                }
            } else {
                // iPad: NavigationSplitView
                NavigationSplitView(columnVisibility: $columnVisibility) {
                    SidebarView(viewModel: viewModel, columnVisibility: $columnVisibility, onAccountSelected: nil)
                } detail: {
                    NavigationStack(path: $navigationPath) {
                        mainContent
                    }
                }
            }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                header(isSearchActive: $isSearchActive)
                
                // Arama çubuğu - sadece aktif olduğunda görünür
                if isSearchActive, let mailbox = viewModel.activeSession?.mailboxViewModel {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Postalarda ara", text: Binding(
                            get: { mailbox.searchQuery },
                            set: { mailbox.searchQuery = $0 }
                        ))
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .onSubmit {
                            // Arama yapıldı
                        }
                        
                        Button {
                            isSearchActive = false
                            mailbox.searchQuery = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(12)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                }
            }
            
            if let mailbox = viewModel.activeSession?.mailboxViewModel {
                MailboxBoard(viewModel: mailbox)
            } else {
                EmptyStateView(
                    gmailAction: { viewModel.connectGmailAccount() },
                    isConnecting: viewModel.isConnectingGmail
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationDestination(for: MailMessage.self) { message in
            MailDetailView(message: message, account: viewModel.activeSession?.account) { intent in
                handleDetailIntent(intent, mailbox: viewModel.activeSession?.mailboxViewModel)
            }
        }
        .toolbar {
            if let mailbox = viewModel.activeSession?.mailboxViewModel {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Yenile butonu
                    Button {
                        viewModel.performQuickAction(.refresh)
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    
                    // Seç butonu
                    Button {
                        viewModel.performQuickAction(.selectMode)
                    } label: {
                        Image(systemName: mailbox.isSelectMode ? "checkmark.circle.fill" : "checkmark.circle")
                            .foregroundStyle(mailbox.isSelectMode ? .blue : .primary)
                    }
                    
                    // Kategorilendir butonu
                    Button {
                        viewModel.performQuickAction(.categorize)
                    } label: {
                        Image(systemName: mailbox.isGroupedByCategory ? "folder.badge.minus" : "folder.badge.plus")
                    }
                    
                    // Mail gönderme butonu
                    Button {
                        viewModel.presentComposer()
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            } else {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.presentComposer()
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingComposer) {
            if let account = viewModel.activeSession?.account {
                ComposeMailView(account: account, draft: $viewModel.composerDraft) {
                    viewModel.sendCurrentDraft()
                }
            }
        }
        .overlay(alignment: .bottom) {
            if let toast = viewModel.toastMessage {
                ToastView(message: toast)
                    .padding(.bottom, 30)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                viewModel.toastMessage = nil
                            }
                        }
                    }
            }
        }
    }

    private func header(isSearchActive: Binding<Bool>) -> some View {
        HStack {
            Text(viewModel.activeSession?.account.displayName ?? "Hesap yok")
                .font(.title3.weight(.semibold))
            Spacer()
            
            // Arama icon'u
            if viewModel.activeSession?.mailboxViewModel != nil {
                Button {
                    isSearchActive.wrappedValue = true
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                        .foregroundStyle(.primary)
                }
            }
        }
    }


    private func handleDetailIntent(_ intent: MailDetailIntent, mailbox: MailboxViewModel?) {
        guard let mailbox else {
            print("⚠️ Mailbox bulunamadı, intent işlenemedi")
            return
        }
        switch intent {
        case .toggleFlag(let message):
            print("🚩 toggleFlag çağrıldı: \(message.subject.prefix(30))")
            mailbox.toggleFlag(for: message)
        case .toggleRead(let message):
            print("📖 toggleRead çağrıldı: \(message.subject.prefix(30)) | isRead: \(message.isRead)")
            mailbox.toggleReadState(for: message)
        case .delete(let message):
            print("🗑️ delete çağrıldı: \(message.subject.prefix(30))")
            mailbox.delete(message)
        }
    }
}

private struct MailboxBoard: View {
    @ObservedObject var viewModel: MailboxViewModel

    var body: some View {
        VStack(spacing: 16) {
            CategoryPicker(selection: $viewModel.selectedCategory)
            MailListView(viewModel: viewModel)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}


private struct CategoryPicker: View {
    @Binding var selection: MailboxCategory

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(MailboxCategory.allCases) { category in
                    Button {
                        selection = category
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: category.systemImage)
                                .font(.caption)
                            Text(category.title)
                                .font(.caption.weight(.medium))
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(selection == category ? Color.accentColor.opacity(0.15) : Color(.systemBackground), in: Capsule())
                        .foregroundStyle(selection == category ? Color.accentColor : .primary)
                    }
                }
            }
        }
    }
}


private struct MailListView: View {
    @ObservedObject var viewModel: MailboxViewModel

    var body: some View {
        if viewModel.isLoading && viewModel.visibleMessages.isEmpty {
            ProgressView("Yükleniyor...")
                .frame(maxWidth: .infinity, alignment: .center)
        } else if viewModel.visibleMessages.isEmpty {
            VStack(spacing: 10) {
                Image(systemName: "mail.stack")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text("Hiç mesaj yok")
                    .font(.headline)
                Text("Yeni mesajlar geldiğinde burada göreceksiniz.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
        } else if viewModel.isGroupedByCategory {
            // Kategorilendirmeyle mail listesi (kapalı/açılır)
            List {
                ForEach(Array(viewModel.senderCategories.keys.sorted()), id: \.self) { senderEmail in
                    if let messages = viewModel.senderCategories[senderEmail], let firstMessage = messages.first {
                        DisclosureGroup {
                            ForEach(messages) { message in
                                if viewModel.isSelectMode {
                                    // Seçim modu
                                    HStack {
                                        Button {
                                            if viewModel.selectedMessages.contains(message.id) {
                                                viewModel.selectedMessages.remove(message.id)
                                            } else {
                                                viewModel.selectedMessages.insert(message.id)
                                            }
                                        } label: {
                                            Image(systemName: viewModel.selectedMessages.contains(message.id) ? "checkmark.circle.fill" : "circle")
                                                .foregroundStyle(viewModel.selectedMessages.contains(message.id) ? .blue : .secondary)
                                                .font(.title3)
                                        }
                                        .buttonStyle(.plain)
                                        
                                        MailRowView(message: message)
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if viewModel.selectedMessages.contains(message.id) {
                                            viewModel.selectedMessages.remove(message.id)
                                        } else {
                                            viewModel.selectedMessages.insert(message.id)
                                        }
                                    }
                                } else {
                                    // Normal mod
                                    NavigationLink(value: message) {
                                        MailRowView(message: message)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            viewModel.delete(message)
                                        } label: {
                                            Label("Sil", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                // Seçim modu aktifse başlık satırına da checkbox ekle
                                if viewModel.isSelectMode {
                                    let allSelected = messages.allSatisfy { viewModel.selectedMessages.contains($0.id) }
                                    Button {
                                        if allSelected {
                                            // Hepsini kaldır
                                            messages.forEach { viewModel.selectedMessages.remove($0.id) }
                                        } else {
                                            // Hepsini seç
                                            messages.forEach { viewModel.selectedMessages.insert($0.id) }
                                        }
                                    } label: {
                                        Image(systemName: allSelected ? "checkmark.circle.fill" : "circle")
                                            .foregroundStyle(allSelected ? .blue : .secondary)
                                            .font(.title3)
                                    }
                                    .buttonStyle(.plain)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(firstMessage.sender.name.isEmpty ? senderEmail : firstMessage.sender.name)
                                        .font(.headline)
                                    Text(senderEmail)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(messages.count) mail")
                                    .font(.caption)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue, in: Capsule())
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .frame(maxHeight: .infinity)
            .toolbar {
                if viewModel.isSelectMode && !viewModel.selectedMessages.isEmpty {
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Button(role: .destructive) {
                                viewModel.deleteSelectedMessages()
                            } label: {
                                Label("Sil (\(viewModel.selectedMessages.count))", systemImage: "trash")
                            }
                            Spacer()
                            Button {
                                viewModel.selectedMessages.removeAll()
                                viewModel.isSelectMode = false
                            } label: {
                                Text("İptal")
                            }
                        }
                    }
                }
            }
        } else {
            // Normal mail listesi
            List {
                ForEach(Array(viewModel.visibleMessages.enumerated()), id: \.element.id) { index, message in
                    if viewModel.isSelectMode {
                        // Seçim modu: NavigationLink yok
                        HStack {
                            Button {
                                if viewModel.selectedMessages.contains(message.id) {
                                    viewModel.selectedMessages.remove(message.id)
                                } else {
                                    viewModel.selectedMessages.insert(message.id)
                                }
                            } label: {
                                Image(systemName: viewModel.selectedMessages.contains(message.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(viewModel.selectedMessages.contains(message.id) ? .blue : .secondary)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                            
                            MailRowView(message: message)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if viewModel.selectedMessages.contains(message.id) {
                                viewModel.selectedMessages.remove(message.id)
                            } else {
                                viewModel.selectedMessages.insert(message.id)
                            }
                        }
                        .onAppear {
                            // Son 5 mesaja yaklaşınca daha fazla yükle
                            if index >= viewModel.visibleMessages.count - 5 && viewModel.hasMoreMessages {
                                viewModel.loadMoreMessages()
                            }
                        }
                    } else {
                        // Normal mod: NavigationLink var
                        NavigationLink(value: message) {
                            MailRowView(message: message)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                viewModel.delete(message)
                            } label: {
                                Label("Sil", systemImage: "trash")
                            }
                        }
                        .onAppear {
                            // Son 5 mesaja yaklaşınca daha fazla yükle
                            if index >= viewModel.visibleMessages.count - 5 && viewModel.hasMoreMessages {
                                viewModel.loadMoreMessages()
                            }
                        }
                    }
                }
                
                // Yükleme göstergesi
                if viewModel.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                }
            }
            .listStyle(.plain)
            .frame(maxHeight: .infinity)
            .toolbar {
                if viewModel.isSelectMode && !viewModel.selectedMessages.isEmpty {
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Button(role: .destructive) {
                                viewModel.deleteSelectedMessages()
                            } label: {
                                Label("Sil (\(viewModel.selectedMessages.count))", systemImage: "trash")
                            }
                            Spacer()
                            Button {
                                viewModel.selectedMessages.removeAll()
                                viewModel.isSelectMode = false
                            } label: {
                                Text("İptal")
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct AccountChip: View {
    var account: Account
    var isActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(account.displayName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isActive ? .white : .primary)
            Text(account.emailAddress)
                .font(.caption)
                .foregroundStyle(isActive ? .white.opacity(0.8) : .secondary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(isActive ? account.accentColor.swiftUIColor : Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct EmptyStateView: View {
    var gmailAction: () -> Void
    var isConnecting: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "envelope.badge.shield.half.filled")
                .font(.system(size: 56))
                .foregroundStyle(.blue)
            Text("Speedmail'e Hoş Geldiniz")
                .font(.title2.weight(.semibold))
            Text("Gmail hesabınızla giriş yaparak maillerinizi yönetmeye başlayın.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                gmailAction()
            } label: {
                HStack {
                    if isConnecting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(width: 20, height: 20)
                        Text("Bağlanıyor...")
                    } else {
                        Image(systemName: "envelope.badge")
                        Text("Gmail ile Giriş Yap")
                    }
                }
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isConnecting)
        }
        .frame(maxWidth: .infinity, minHeight: 260)
    }
}

private struct ToastView: View {
    var message: String

    var body: some View {
        Text(message)
            .font(.footnote.weight(.medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .shadow(radius: 8)
    }
}

private struct AddAccountSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var displayName: String = ""
    @State private var email: String = ""
    @State private var accent: Account.AccentColorToken = .ocean
    var onCreate: (String, String, Account.AccentColorToken) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Profil") {
                    TextField("Ad", text: $displayName)
                    TextField("E-posta", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }

                Section("Renk") {
                    Picker("Vurgu Rengi", selection: $accent) {
                        ForEach(Account.AccentColorToken.allCases) { color in
                            HStack {
                                Circle()
                                    .fill(color.swiftUIColor)
                                    .frame(width: 14, height: 14)
                                Text(color.displayName)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Hesap Ekle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        onCreate(displayName, email, accent)
                        dismiss()
                    }
                    .disabled(displayName.isEmpty || email.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Sidebar View
private struct SidebarView: View {
    @ObservedObject var viewModel: AppViewModel
    @Binding var columnVisibility: NavigationSplitViewVisibility
    var onAccountSelected: (() -> Void)? = nil
    
    var body: some View {
        List {
            Section {
                ForEach(viewModel.sessions) { session in
                    Button {
                        viewModel.select(session: session)
                        // iPhone'da sheet'i kapat
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            onAccountSelected?()
                        } else {
                            // iPad'de sidebar'ı kapat
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                columnVisibility = .detailOnly
                            }
                        }
                    } label: {
                        HStack {
                            Circle()
                                .fill(session.account.accentColor.swiftUIColor)
                                .frame(width: 12, height: 12)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(session.account.displayName)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(session.account.emailAddress)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if session.id == viewModel.activeSession?.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            viewModel.removeAccount(session)
                        } label: {
                            Label("Hesabı Kaldır", systemImage: "trash")
                        }
                    }
                }
            } header: {
                Text("Hesaplar")
            }
            
            Section {
                Button {
                    viewModel.connectGmailAccount()
                } label: {
                    HStack {
                        if viewModel.isConnectingGmail {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                        }
                        Text("Hesap Ekle")
                            .foregroundStyle(.blue)
                    }
                }
                .disabled(viewModel.isConnectingGmail)
            }
        }
        .listStyle(.sidebar)
    }
}

private extension Account.AccentColorToken {
    var displayName: String {
        switch self {
        case .ocean: return "Okyanus"
        case .coral: return "Mercan"
        case .lime: return "Limon"
        case .violet: return "Menekşe"
        case .graphite: return "Grafit"
        case .amber: return "Kehribar"
        }
    }

    var swiftUIColor: Color {
        switch self {
        case .ocean: return Color.teal
        case .coral: return Color.pink
        case .lime: return Color.green
        case .violet: return Color.purple
        case .graphite: return Color.gray
        case .amber: return Color.orange
        }
    }
}

