import SwiftUI

private enum AppColors {
    static let ink = Color(red: 0.08, green: 0.11, blue: 0.17)
    static let blue = Color(red: 0.18, green: 0.39, blue: 0.96)
    static let muted = Color(red: 0.43, green: 0.47, blue: 0.54)
    static let canvas = Color(red: 0.96, green: 0.97, blue: 0.985)
    static let green = Color(red: 0.12, green: 0.58, blue: 0.38)
    static let orange = Color(red: 0.80, green: 0.42, blue: 0.08)
}

struct ContentView: View {
    @State private var store = GymStore()
    @State private var enteredWorkspace = false

    var body: some View {
        Group {
            if enteredWorkspace {
                GymWorkspaceView(store: store) {
                    enteredWorkspace = false
                }
            } else {
                DemoWelcomeView { enteredWorkspace = true }
            }
        }
        .preferredColorScheme(.light)
    }
}

private struct DemoWelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(colors: [AppColors.ink, Color(red: 0.13, green: 0.19, blue: 0.30)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(AppColors.blue, in: RoundedRectangle(cornerRadius: 18))
                    .padding(.bottom, 26)
                Text("MYGYM OPS")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .tracking(2.5)
                    .foregroundStyle(.white.opacity(0.65))
                Text("Run your gym.\nNot the paperwork.")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.top, 12)
                Text("A staff workspace for members, classes, check-ins, and access reports.")
                    .font(.system(size: 17))
                    .foregroundStyle(.white.opacity(0.72))
                    .lineSpacing(4)
                    .padding(.top, 14)
                Button(action: onContinue) {
                    HStack {
                        Text("Open demo workspace")
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .frame(height: 56)
                    .background(AppColors.blue, in: RoundedRectangle(cornerRadius: 15))
                }
                .padding(.top, 32)
                Label("Demo mode • local device data only", systemImage: "info.circle")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.64))
                    .padding(.top, 16)
                Spacer()
            }
            .padding(28)
        }
    }
}

private struct GymWorkspaceView: View {
    let store: GymStore
    let onSignOut: () -> Void

    var body: some View {
        TabView {
            DashboardScreen(store: store)
                .tabItem { Label("Overview", systemImage: "square.grid.2x2.fill") }
            MembersScreen(store: store)
                .tabItem { Label("Members", systemImage: "person.2.fill") }
            ClassesScreen(store: store)
                .tabItem { Label("Classes", systemImage: "calendar") }
            AccessScreen(store: store)
                .tabItem { Label("Access", systemImage: "door.left.hand.open") }
            MoreScreen(store: store, onSignOut: onSignOut)
                .tabItem { Label("More", systemImage: "ellipsis.circle.fill") }
        }
        .tint(AppColors.blue)
    }
}

private struct DashboardScreen: View {
    let store: GymStore
    @State private var showingCheckIn = false

    private var activeMembers: Int { store.members.filter { $0.status == .active }.count }
    private var pastDueMembers: Int { store.members.filter { $0.status == .pastDue }.count }
    private var upcoming: [GymClass] { Array(store.classes.sorted { $0.startsAt < $1.startsAt }.prefix(3)) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppColors.muted)
                        Text("Gym overview")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.ink)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 12) {
                        MetricCard(title: "Members", value: "\(store.members.count)", detail: "\(activeMembers) active", symbol: "person.2.fill", tint: AppColors.blue)
                        MetricCard(title: "Past due", value: "\(pastDueMembers)", detail: "Memberships", symbol: "exclamationmark.circle.fill", tint: AppColors.orange)
                    }
                    HStack(spacing: 12) {
                        MetricCard(title: "Check-ins", value: "\(store.checkIns.count)", detail: "Staff demo logs", symbol: "checkmark.seal.fill", tint: AppColors.green)
                        MetricCard(title: "Classes", value: "\(store.classes.count)", detail: "On the schedule", symbol: "calendar", tint: AppColors.ink)
                    }

                    HStack(alignment: .top, spacing: 11) {
                        Image(systemName: "info.circle.fill").foregroundStyle(AppColors.blue)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Local demo workspace")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(AppColors.ink)
                            Text("Changes save on this device. No real accounts, payments, cloud sync, or door readers are connected.")
                                .font(.system(size: 13))
                                .foregroundStyle(AppColors.muted)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))

                    HStack {
                        Text("Quick actions")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.ink)
                        Spacer()
                    }
                    Button { showingCheckIn = true } label: {
                        Label("Record a staff check-in", systemImage: "checkmark.seal.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(.white, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .foregroundStyle(AppColors.ink)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Upcoming classes")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.ink)
                        if upcoming.isEmpty {
                            Text("No classes scheduled yet.").foregroundStyle(AppColors.muted)
                        } else {
                            ForEach(upcoming) { item in
                                ClassSummaryRow(item: item)
                                if item.id != upcoming.last?.id { Divider() }
                            }
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white, in: RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Access reliability")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.ink)
                        Text("\(store.managerReportedFailedScans) failed scans reported last month")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppColors.ink)
                        Text("Manager-reported total • not verified against reader logs")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.muted)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(20)
            }
            .background(AppColors.canvas)
            .navigationTitle("MyGym Ops")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingCheckIn) { CheckInPickerScreen(store: store) }
        }
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let detail: String
    let symbol: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: symbol).font(.system(size: 17, weight: .semibold)).foregroundStyle(tint)
            Text(value).font(.system(size: 27, weight: .bold, design: .rounded)).foregroundStyle(AppColors.ink)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 13, weight: .semibold)).foregroundStyle(AppColors.ink)
                Text(detail).font(.system(size: 11)).foregroundStyle(AppColors.muted)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
        .padding(15)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct ClassSummaryRow: View {
    let item: GymClass
    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 2) {
                Text(item.startsAt.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 13, weight: .bold))
                Text(item.startsAt.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppColors.muted)
            }
            .frame(width: 55)
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title).font(.system(size: 14, weight: .semibold)).foregroundStyle(AppColors.ink)
                Text("\(item.instructor) • \(item.location)").font(.system(size: 12)).foregroundStyle(AppColors.muted)
            }
            Spacer()
            Text("\(item.bookedMemberIDs.count)/\(item.capacity)")
                .font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.blue)
        }
        .padding(.vertical, 4)
    }
}

private struct MembersScreen: View {
    let store: GymStore
    @State private var searchText = ""
    @State private var showingAddMember = false
    @State private var selectedMember: GymMember?

    private var filteredMembers: [GymMember] {
        guard !searchText.isEmpty else { return store.members }
        return store.members.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.email.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(filteredMembers) { member in
                        Button { selectedMember = member } label: { MemberRow(member: member) }
                            .buttonStyle(.plain)
                    }
                } header: {
                    Text("\(store.members.count) members • demo records")
                }
            }
            .searchable(text: $searchText, prompt: "Name or email")
            .navigationTitle("Members")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAddMember = true } label: { Image(systemName: "plus") }
                        .accessibilityLabel("Add member")
                }
            }
            .sheet(isPresented: $showingAddMember) { AddMemberScreen(store: store) }
            .sheet(item: $selectedMember) { member in MemberDetailScreen(store: store, memberID: member.id) }
        }
    }
}

private struct MemberRow: View {
    let member: GymMember
    var body: some View {
        HStack(spacing: 12) {
            Circle().fill(AppColors.blue.opacity(0.12)).frame(width: 42, height: 42)
                .overlay(Text(initials).font(.system(size: 14, weight: .bold)).foregroundStyle(AppColors.blue))
            VStack(alignment: .leading, spacing: 4) {
                Text(member.name).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.ink)
                Text("\(member.planName) • \(member.visitsThisMonth) visits this month")
                    .font(.system(size: 12)).foregroundStyle(AppColors.muted)
            }
            Spacer()
            StatusPill(title: member.status.rawValue, tint: member.status == .active ? AppColors.green : AppColors.orange)
        }
        .padding(.vertical, 5)
        .contentShape(Rectangle())
    }
    private var initials: String {
        member.name.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined()
    }
}

private struct StatusPill: View {
    let title: String
    let tint: Color
    var body: some View {
        Text(title).font(.system(size: 11, weight: .semibold)).foregroundStyle(tint)
            .padding(.horizontal, 9).padding(.vertical, 5)
            .background(tint.opacity(0.1), in: Capsule())
    }
}

private struct AddMemberScreen: View {
    let store: GymStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var planName = "Core"

    var body: some View {
        NavigationStack {
            Form {
                Section("Member details") {
                    TextField("Full name", text: $name)
                    TextField("Email", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never)
                    TextField("Phone", text: $phone).keyboardType(.phonePad)
                }
                Section("Membership") {
                    Picker("Plan", selection: $planName) {
                        ForEach(store.plans) { plan in Text(plan.name).tag(plan.name) }
                    }
                    Text("New demo members start as Active. No payment is collected.")
                        .font(.footnote).foregroundStyle(AppColors.muted)
                }
            }
            .navigationTitle("Add member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.addMember(GymMember(name: name.trimmingCharacters(in: .whitespacesAndNewlines), email: email.trimmingCharacters(in: .whitespacesAndNewlines), phone: phone.trimmingCharacters(in: .whitespacesAndNewlines), planName: planName, status: .active))
                        dismiss()
                    }.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private struct MemberDetailScreen: View {
    let store: GymStore
    let memberID: UUID
    private var member: GymMember? { store.members.first { $0.id == memberID } }

    var body: some View {
        NavigationStack {
            Form {
                if let member {
                    Section("Contact") {
                        LabeledContent("Name", value: member.name)
                        LabeledContent("Email", value: member.email.isEmpty ? "Not added" : member.email)
                        LabeledContent("Phone", value: member.phone.isEmpty ? "Not added" : member.phone)
                    }
                    Section("Membership") {
                        LabeledContent("Plan", value: member.planName)
                        Picker("Status", selection: Binding(get: { self.member?.status ?? .active }, set: { store.updateMemberStatus(memberID, to: $0) })) {
                            ForEach(MembershipStatus.allCases) { status in Text(status.rawValue).tag(status) }
                        }
                        LabeledContent("Visits this month", value: "\(member.visitsThisMonth)")
                        LabeledContent("Joined", value: member.joinedAt.formatted(date: .abbreviated, time: .omitted))
                    }
                } else {
                    ContentUnavailableView("Member not found", systemImage: "person.crop.circle.badge.questionmark")
                }
            }
            .navigationTitle(member?.name ?? "Member")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct ClassesScreen: View {
    let store: GymStore
    @State private var showingAddClass = false
    @State private var selectedClass: GymClass?

    var body: some View {
        NavigationStack {
            List {
                Section("Class schedule • local demo") {
                    ForEach(store.classes.sorted { $0.startsAt < $1.startsAt }) { item in
                        Button { selectedClass = item } label: {
                            ClassSummaryRow(item: item)
                        }.buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Classes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAddClass = true } label: { Image(systemName: "plus") }
                        .accessibilityLabel("Add class")
                }
            }
            .sheet(isPresented: $showingAddClass) { AddClassScreen(store: store) }
            .sheet(item: $selectedClass) { item in ClassDetailScreen(store: store, classID: item.id) }
        }
    }
}

private struct AddClassScreen: View {
    let store: GymStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var instructor = ""
    @State private var location = "Studio A"
    @State private var startsAt = Date().addingTimeInterval(3600)
    @State private var duration = 45
    @State private var capacity = 12

    var body: some View {
        NavigationStack {
            Form {
                Section("Class") {
                    TextField("Class name", text: $title)
                    TextField("Instructor", text: $instructor)
                    TextField("Location", text: $location)
                    DatePicker("Starts", selection: $startsAt, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                }
                Section("Capacity") {
                    Stepper("Duration: \(duration) min", value: $duration, in: 15...180, step: 5)
                    Stepper("Spots: \(capacity)", value: $capacity, in: 1...100)
                }
            }
            .navigationTitle("Add class")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.addClass(GymClass(title: title.trimmingCharacters(in: .whitespacesAndNewlines), instructor: instructor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Staff" : instructor, location: location, startsAt: startsAt, durationMinutes: duration, capacity: capacity))
                        dismiss()
                    }.disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private struct ClassDetailScreen: View {
    let store: GymStore
    let classID: UUID
    @State private var showingBooking = false
    private var item: GymClass? { store.classes.first { $0.id == classID } }

    var body: some View {
        NavigationStack {
            List {
                if let item {
                    Section("Details") {
                        LabeledContent("Instructor", value: item.instructor)
                        LabeledContent("Location", value: item.location)
                        LabeledContent("Starts", value: item.startsAt.formatted(date: .abbreviated, time: .shortened))
                        LabeledContent("Duration", value: "\(item.durationMinutes) minutes")
                        LabeledContent("Capacity", value: "\(item.bookedMemberIDs.count) / \(item.capacity)")
                    }
                    Section("Roster") {
                        let booked = store.members.filter { item.bookedMemberIDs.contains($0.id) }
                        if booked.isEmpty { Text("No bookings yet").foregroundStyle(AppColors.muted) }
                        ForEach(booked) { member in Text(member.name) }
                        if item.bookedMemberIDs.count < item.capacity {
                            Button { showingBooking = true } label: { Label("Add member to class", systemImage: "person.badge.plus") }
                        }
                    }
                }
            }
            .navigationTitle(item?.title ?? "Class")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingBooking) { AddBookingScreen(store: store, classID: classID) }
        }
    }
}

private struct AddBookingScreen: View {
    let store: GymStore
    let classID: UUID
    @Environment(\.dismiss) private var dismiss
    private var currentClass: GymClass? { store.classes.first { $0.id == classID } }
    private var eligibleMembers: [GymMember] {
        store.members.filter { $0.status == .active && !(currentClass?.bookedMemberIDs.contains($0.id) ?? true) }
    }

    var body: some View {
        NavigationStack {
            List {
                if eligibleMembers.isEmpty {
                    ContentUnavailableView("No eligible members", systemImage: "person.2", description: Text("Add an active member or check the class capacity."))
                }
                ForEach(eligibleMembers) { member in
                    Button {
                        _ = store.book(member.id, into: classID)
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(member.name).foregroundStyle(AppColors.ink)
                                Text(member.planName).font(.caption).foregroundStyle(AppColors.muted)
                            }
                            Spacer()
                            Image(systemName: "plus.circle.fill").foregroundStyle(AppColors.blue)
                        }
                    }
                }
            }
            .navigationTitle("Add to roster")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } } }
        }
    }
}

private struct AccessScreen: View {
    let store: GymStore
    @State private var filter: IncidentStatus? = nil
    @State private var showingLogIssue = false

    private var displayed: [AccessIssue] {
        guard let filter else { return store.incidents }
        return store.incidents.filter { $0.status == filter }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(store.managerReportedFailedScans)")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.ink)
                        Text("Failed scans reported last month")
                            .font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.ink)
                        Text("Manager-reported total • verify against reader logs")
                            .font(.system(size: 12)).foregroundStyle(AppColors.muted)
                    }
                    .padding(.vertical, 6)
                }
                Section {
                    Picker("Filter", selection: $filter) {
                        Text("All").tag(Optional<IncidentStatus>.none)
                        ForEach(IncidentStatus.allCases) { status in Text(status.rawValue).tag(Optional(status)) }
                    }
                    ForEach(displayed) { issue in
                        AccessIssueRow(issue: issue) {
                            store.markIncidentReviewed(issue.id)
                        }
                    }
                    if displayed.isEmpty { Text("No reports match this filter.").foregroundStyle(AppColors.muted) }
                } header: {
                    Text("Incident reports • not reader logs")
                } footer: {
                    Text("No door hardware is connected. The app does not grant or deny entry.")
                }
            }
            .navigationTitle("Access issues")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingLogIssue = true } label: { Image(systemName: "plus") }
                        .accessibilityLabel("Log access issue")
                }
            }
            .sheet(isPresented: $showingLogIssue) { AddAccessIssueScreen(store: store) }
        }
    }
}

private struct AccessIssueRow: View {
    let issue: AccessIssue
    let onReview: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text(issue.door).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.ink)
                Spacer()
                StatusPill(title: issue.status.rawValue, tint: issue.status == .reviewed ? AppColors.green : AppColors.orange)
            }
            Text("\(issue.method) • \(issue.reportedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.system(size: 12)).foregroundStyle(AppColors.muted)
            Text(issue.summary).font(.system(size: 14)).foregroundStyle(AppColors.ink)
            Text(issue.source).font(.system(size: 11, weight: .medium)).foregroundStyle(AppColors.muted)
            if issue.status == .needsReview {
                Button(action: onReview) { Label("Mark reviewed", systemImage: "checkmark.circle") }
                    .font(.system(size: 13, weight: .semibold)).buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 6)
    }
}

private struct AddAccessIssueScreen: View {
    let store: GymStore
    @Environment(\.dismiss) private var dismiss
    @State private var door = ""
    @State private var method = "Phone check-in"
    @State private var summary = ""
    private let methods = ["Phone check-in", "Key tag", "Staff report", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Where?") {
                    TextField("Door or area", text: $door)
                    Picker("Entry method", selection: $method) { ForEach(methods, id: \.self) { Text($0) } }
                }
                Section("What happened?") {
                    TextField("Describe the issue", text: $summary, axis: .vertical).lineLimit(3...6)
                }
                Section {
                    Text("Avoid member names or private details. This demo saves reports on this device only.")
                        .font(.footnote).foregroundStyle(AppColors.muted)
                }
            }
            .navigationTitle("Log access issue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.addIncident(AccessIssue(door: door.trimmingCharacters(in: .whitespacesAndNewlines), method: method, summary: summary.trimmingCharacters(in: .whitespacesAndNewlines), source: "Staff report • local demo"))
                        dismiss()
                    }.disabled(door.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private struct MoreScreen: View {
    let store: GymStore
    let onSignOut: () -> Void
    var body: some View {
        NavigationStack {
            List {
                Section("Gym operations") {
                    NavigationLink { AttendanceScreen(store: store) } label: { Label("Check-in log", systemImage: "checkmark.seal") }
                    NavigationLink { MembershipPlansScreen(store: store) } label: { Label("Membership plans", systemImage: "creditcard") }
                    NavigationLink { ReportsScreen(store: store) } label: { Label("Reports", systemImage: "chart.bar") }
                }
                Section("Workspace") {
                    NavigationLink { DemoSettingsScreen() } label: { Label("Demo settings", systemImage: "gearshape") }
                    Button(role: .destructive, action: onSignOut) { Label("Exit demo workspace", systemImage: "rectangle.portrait.and.arrow.right") }
                }
                Section {
                    Text("Prototype only. Do not enter real member or payment data. Authentication, cloud storage, billing, and access hardware are not configured.")
                        .font(.footnote).foregroundStyle(AppColors.muted)
                }
            }
            .navigationTitle("More")
        }
    }
}

private struct AttendanceScreen: View {
    let store: GymStore
    @State private var showingCheckIn = false
    var body: some View {
        List {
            Section {
                Button { showingCheckIn = true } label: { Label("Record staff check-in", systemImage: "plus.circle.fill") }
            } footer: {
                Text("Manual demo log only. This does not scan a phone or communicate with a door reader.")
            }
            Section("Recent visits") {
                if store.checkIns.isEmpty { Text("No check-ins logged yet.").foregroundStyle(AppColors.muted) }
                ForEach(store.checkIns) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.memberName).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.ink)
                        Text("\(event.occurredAt.formatted(date: .abbreviated, time: .shortened)) • \(event.method)")
                            .font(.system(size: 12)).foregroundStyle(AppColors.muted)
                    }
                    .padding(.vertical, 3)
                }
            }
        }
        .navigationTitle("Check-in log")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingCheckIn) { CheckInPickerScreen(store: store) }
    }
}

private struct CheckInPickerScreen: View {
    let store: GymStore
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("This records a staff-entered visit in the demo. It does not use phone check-in or unlock a door.")
                        .font(.footnote).foregroundStyle(AppColors.muted)
                }
                Section("Choose a member") {
                    ForEach(store.members.filter { $0.status == .active }) { member in
                        Button {
                            store.recordStaffCheckIn(for: member)
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(member.name).foregroundStyle(AppColors.ink)
                                    Text("\(member.planName) • \(member.visitsThisMonth) visits this month")
                                        .font(.caption).foregroundStyle(AppColors.muted)
                                }
                                Spacer()
                                Image(systemName: "checkmark.circle").foregroundStyle(AppColors.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Staff check-in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
        }
    }
}

private struct MembershipPlansScreen: View {
    let store: GymStore
    @State private var showingAddPlan = false
    var body: some View {
        List {
            Section {
                Text("Demo prices only. No charges, invoices, or recurring payments are processed.")
                    .font(.footnote).foregroundStyle(AppColors.muted)
            }
            Section("Plans") {
                ForEach(store.plans) { plan in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(plan.name).font(.system(size: 16, weight: .semibold)).foregroundStyle(AppColors.ink)
                            Spacer()
                            Text(plan.monthlyPrice, format: .currency(code: "USD"))
                                .font(.system(size: 15, weight: .bold)).foregroundStyle(AppColors.ink)
                        }
                        Text("per month • demo rate").font(.system(size: 11)).foregroundStyle(AppColors.muted)
                        Text(plan.benefits).font(.system(size: 13)).foregroundStyle(AppColors.muted)
                        let count = store.members.filter { $0.planName == plan.name }.count
                        Text("\(count) demo members").font(.system(size: 12, weight: .medium)).foregroundStyle(AppColors.blue)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .navigationTitle("Membership plans")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingAddPlan = true } label: { Image(systemName: "plus") }.accessibilityLabel("Add plan")
            }
        }
        .sheet(isPresented: $showingAddPlan) { AddPlanScreen(store: store) }
    }
}

private struct AddPlanScreen: View {
    let store: GymStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var monthlyPrice = 49.0
    @State private var benefits = "Gym floor access"
    var body: some View {
        NavigationStack {
            Form {
                Section("Plan details") {
                    TextField("Plan name", text: $name)
                    TextField("Monthly demo price", value: $monthlyPrice, format: .number).keyboardType(.decimalPad)
                    TextField("Included benefits", text: $benefits, axis: .vertical).lineLimit(2...4)
                }
                Section { Text("This saves a demo plan only. It does not create a billing product.").font(.footnote).foregroundStyle(AppColors.muted) }
            }
            .navigationTitle("Add plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.addPlan(GymPlan(name: name.trimmingCharacters(in: .whitespacesAndNewlines), monthlyPrice: max(0, monthlyPrice), benefits: benefits))
                        dismiss()
                    }.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private struct ReportsScreen: View {
    let store: GymStore
    private var active: Int { store.members.filter { $0.status == .active }.count }
    private var pastDue: Int { store.members.filter { $0.status == .pastDue }.count }
    private var totalBookings: Int { store.classes.reduce(0) { $0 + $1.bookedMemberIDs.count } }
    var body: some View {
        List {
            Section("Snapshot • demo data") {
                LabeledContent("Total members", value: "\(store.members.count)")
                LabeledContent("Active memberships", value: "\(active)")
                LabeledContent("Past-due memberships", value: "\(pastDue)")
                LabeledContent("Staff check-in logs", value: "\(store.checkIns.count)")
                LabeledContent("Class bookings", value: "\(totalBookings)")
                LabeledContent("Open access reports", value: "\(store.incidents.filter { $0.status == .needsReview }.count)")
            }
            Section {
                Text("This report is calculated from local demo records. It is not financial, tax, attendance-reader, or business-performance reporting.")
                    .font(.footnote).foregroundStyle(AppColors.muted)
            }
        }
        .navigationTitle("Reports")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct DemoSettingsScreen: View {
    var body: some View {
        List {
            Section("Current workspace") {
                LabeledContent("Mode", value: "Local demo")
                LabeledContent("Sign-in", value: "Not configured")
                LabeledContent("Data storage", value: "This device")
                LabeledContent("Door readers", value: "Not connected")
                LabeledContent("Payments", value: "Not connected")
            }
            Section {
                Text("Use sample records only. Before a real gym launch, the app needs secure staff authentication, a backend with access controls and backups, a payment provider, and an approved integration for the gym’s access system.")
                    .font(.footnote).foregroundStyle(AppColors.muted)
            }
        }
        .navigationTitle("Demo settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
}
