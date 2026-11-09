//
//  ContentView.swift
//  MyGym
//
//  Created by Sudheer Reddy Tagireddy on 6/29/26.
//

import SwiftUI

struct ContentView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var isLoading: Bool = false
    @State private var isLoggedIn: Bool = false

    var body: some View {
        if isLoggedIn {
            StaffAccessDashboardView(isLoggedIn: $isLoggedIn)
        } else {
            loginView
        }
    }

    private var loginView: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.08, green: 0.09, blue: 0.14),
                    Color(red: 0.13, green: 0.14, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome Back")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)

                    Text("Sign in to your account")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 38)

                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Email", systemImage: "envelope.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)

                        TextField("Enter your email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textContentType(.emailAddress)
                            .padding(12)
                            .background(Color(red: 0.2, green: 0.2, blue: 0.25))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Password", systemImage: "lock.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)

                        HStack {
                            if showPassword {
                                TextField("Enter your password", text: $password)
                                    .autocorrectionDisabled()
                                    .textContentType(.password)
                            } else {
                                SecureField("Enter your password", text: $password)
                                    .textContentType(.password)
                            }

                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(12)
                        .background(Color(red: 0.2, green: 0.2, blue: 0.25))
                        .cornerRadius(10)
                    }

                    HStack {
                        Spacer()
                        Button(action: {}) {
                            Text("Forgot Password?")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)

                Button(action: handleLogin) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        Text("Sign In")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.blue)
                .cornerRadius(10)
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                .opacity((isLoading || email.isEmpty || password.isEmpty) ? 0.65 : 1.0)
                .padding(.horizontal, 24)
                .padding(.bottom, 18)

                Text("Prototype only • sign-in is simulated")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)

                HStack {
                    Rectangle().frame(height: 1).foregroundColor(.gray)
                    Text("or")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                    Rectangle().frame(height: 1).foregroundColor(.gray)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 18)

                VStack(spacing: 12) {
                    Button(action: {}) {
                        HStack(spacing: 12) {
                            Image(systemName: "applelogo")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Sign in with Apple")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .foregroundColor(.white)
                        .background(Color(red: 0.18, green: 0.18, blue: 0.22))
                        .cornerRadius(10)
                    }

                    Button(action: {}) {
                        HStack(spacing: 12) {
                            Image(systemName: "globe")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Sign in with Google")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .foregroundColor(.white)
                        .background(Color(red: 0.18, green: 0.18, blue: 0.22))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                Spacer()

                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)

                    Button(action: {}) {
                        Text("Sign up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 36)
            }
        }
        .navigationBarHidden(true)
    }

    private func handleLogin() {
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isLoading = false
            isLoggedIn = true
        }
    }
}

enum BottomTab: String {
    case home
    case schedule
    case checkIn
    case account

    var title: String {
        switch self {
        case .home: return "Home"
        case .schedule: return "Schedule"
        case .checkIn: return "Check-in"
        case .account: return "Account"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .schedule: return "calendar"
        case .checkIn: return "checkmark.seal.fill"
        case .account: return "person.fill"
        }
    }
}

struct HomeDashboardView: View {
    @State private var selectedTab: BottomTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            TabContentView(selectedTab: selectedTab)
                .padding(.bottom, 82)

            FooterBarView(selectedTab: $selectedTab)
                .padding(.horizontal, 14)
                .padding(.bottom, 18)
        }
        .background(Color(white: 0.96))
        .ignoresSafeArea()
    }
}

struct FooterBarView: View {
    @Binding var selectedTab: BottomTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach([BottomTab.home, .schedule, .checkIn, .account], id: \ .self) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18, weight: .semibold))
                        Text(tab.title)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .foregroundColor(selectedTab == tab ? .blue : .gray)
                }
            }
        }
        .frame(height: 74)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -4)
    }
}

struct TabContentView: View {
    let selectedTab: BottomTab

    var body: some View {
        switch selectedTab {
        case .home:
            HomeView()
        case .schedule:
            ScheduleView()
        case .checkIn:
            CheckInView()
        case .account:
            AccountView()
        }
    }
}

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Good morning")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    Text("Alex Johnson")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 50)

                VStack(alignment: .leading, spacing: 14) {
                    Text("Membership")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)

                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Gold Access")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            Text("Valid until 12 Aug 2027")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.21, green: 0.68, blue: 0.95), Color(red: 0.15, green: 0.39, blue: 0.95)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                }
                .padding(.horizontal, 20)

                HStack(spacing: 12) {
                    StatCard(title: "Workouts", value: "12", accent: .blue)
                    StatCard(title: "Streak", value: "8 days", accent: .green)
                }
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 16) {
                    Text("Today’s plan")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)

                    WorkoutRow(title: "Strength Training", time: "07:30 AM", detail: "Upper body • 45 mins")
                    WorkoutRow(title: "HIIT Circuit", time: "12:15 PM", detail: "Cardio • 30 mins")
                    WorkoutRow(title: "Mobility Flow", time: "06:00 PM", detail: "Recovery • 20 mins")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color.white)
                .cornerRadius(22)
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 16) {
                    Text("Progress")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)

                    HStack {
                        ProgressRing(progress: 0.72, title: "Goal", value: "72%")
                        ProgressRing(progress: 0.58, title: "Recovery", value: "58%")
                        ProgressRing(progress: 0.85, title: "Energy", value: "85%")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color.white)
                .cornerRadius(22)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

struct ScheduleView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Schedule")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 60)
                .padding(.horizontal, 20)

            ScrollView {
                VStack(spacing: 16) {
                    ScheduleCard(day: "Mon", date: "20", title: "Power Lift", coach: "Coach Mark", time: "6:30 AM")
                    ScheduleCard(day: "Tue", date: "21", title: "Yoga Flow", coach: "Coach Maya", time: "8:00 AM")
                    ScheduleCard(day: "Wed", date: "22", title: "HIIT Blast", coach: "Coach Leo", time: "5:45 PM")
                    ScheduleCard(day: "Thu", date: "23", title: "Core Focus", coach: "Coach Sara", time: "7:00 AM")
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

struct CheckInView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("Check-in")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 60)
                .padding(.horizontal, 20)

            VStack(spacing: 18) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.blue)

                Text("Ready to check in?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)

                Text("Tap below to log your visit and start your workout session.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Button(action: {}) {
                    Text("Check In")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .background(Color.blue)
                .cornerRadius(14)
                .padding(.horizontal, 20)
            }
            .padding(28)
            .background(Color.white)
            .cornerRadius(22)
            .padding(.horizontal, 20)

            Spacer()
        }
    }
}

struct AccountView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Account")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 60)
                .padding(.horizontal, 20)

            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    Circle()
                        .frame(width: 70, height: 70)
                        .foregroundColor(Color(red: 0.82, green: 0.9, blue: 1))
                        .overlay(Image(systemName: "person.fill").foregroundColor(.blue).font(.system(size: 30)))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Alex Johnson")
                            .font(.system(size: 22, weight: .bold))
                        Text("Premium Member")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.bottom, 12)

                AccountRow(title: "Email", value: "alex@mygym.com")
                AccountRow(title: "Phone", value: "+1 (555) 123-4567")
                AccountRow(title: "Membership", value: "Gold")
                AccountRow(title: "Location", value: "Downtown Studio")
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(22)
            .padding(.horizontal, 20)

            Spacer()
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(accent.opacity(0.12))
        .cornerRadius(18)
    }
}

struct WorkoutRow: View {
    let title: String
    let time: String
    let detail: String

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .frame(width: 38, height: 38)
                    .foregroundColor(.blue.opacity(0.12))
                Image(systemName: "timer")
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                Text(detail)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.gray)
            }

            Spacer()

            Text(time)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

struct ProgressRing: View {
    let progress: Double
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                    .frame(width: 62, height: 62)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 62, height: 62)

                Text(value)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.black)
            }

            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ScheduleCard: View {
    let day: String
    let date: String
    let title: String
    let coach: String
    let time: String

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(spacing: 4) {
                Text(day)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                Text(date)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
            }
            .frame(width: 56)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.08))
            .cornerRadius(16)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                Text("with \(coach)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
            }

            Spacer()

            Text(time)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.blue)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
    }
}

struct AccountRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
        }
        .padding(.vertical, 8)
    }
}


enum AccessIncidentFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case needsReview = "Needs review"
    case reviewed = "Reviewed"

    var id: String { rawValue }
}

enum AccessIncidentStatus: String {
    case needsReview = "Needs review"
    case reviewed = "Reviewed"

    var tint: Color {
        switch self {
        case .needsReview: return .orange
        case .reviewed: return .green
        }
    }
}

struct AccessIncident: Identifiable {
    let id = UUID()
    let occurredAt: Date?
    let door: String
    let method: String
    let summary: String
    let source: String
    var status: AccessIncidentStatus

    static let initialReports = [
        AccessIncident(
            occurredAt: nil,
            door: "Main entrance",
            method: "Phone check-in",
            summary: "The entry was treated as sauna access and was denied.",
            source: "Member report • verify against reader logs",
            status: .needsReview
        )
    ]
}

struct StaffAccessDashboardView: View {
    @Binding var isLoggedIn: Bool
    @State private var incidents = AccessIncident.initialReports
    @State private var selectedFilter: AccessIncidentFilter = .all
    @State private var showingLogForm = false

    private var filteredIncidents: [AccessIncident] {
        switch selectedFilter {
        case .all:
            return incidents
        case .needsReview:
            return incidents.filter { $0.status == .needsReview }
        case .reviewed:
            return incidents.filter { $0.status == .reviewed }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Access reliability")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.black)
                        Text("Staff console • Prototype")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.gray)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("34")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.black)
                        Text("Failed scans reported last month")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                        Text("Manager-reported total • not yet verified against reader logs")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("No door system is connected")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            Text("This prototype does not control doors. New notes stay on this device for this session only.")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Reported issues")
                                .font(.system(size: 21, weight: .bold))
                                .foregroundColor(.black)
                            Text("Review the report before treating it as a reader-log event.")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                        Spacer(minLength: 8)
                        Button {
                            showingLogForm = true
                        } label: {
                            Label("Log issue", systemImage: "plus")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    Picker("Filter incidents", selection: $selectedFilter) {
                        ForEach(AccessIncidentFilter.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)

                    if filteredIncidents.isEmpty {
                        ContentUnavailableView(
                            "No matching reports",
                            systemImage: "checkmark.circle",
                            description: Text("Try another filter or log an access issue.")
                        )
                    } else {
                        ForEach(filteredIncidents) { incident in
                            AccessIncidentCard(incident: incident) {
                                markReviewed(incident)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Color(red: 0.96, green: 0.97, blue: 0.98))
            .navigationTitle("Gym Ops")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sign out") {
                        isLoggedIn = false
                    }
                }
            }
            .sheet(isPresented: $showingLogForm) {
                LogAccessIssueView { incident in
                    incidents.insert(incident, at: 0)
                    selectedFilter = .all
                    showingLogForm = false
                }
            }
        }
    }

    private func markReviewed(_ incident: AccessIncident) {
        guard let index = incidents.firstIndex(where: { $0.id == incident.id }) else { return }
        incidents[index].status = .reviewed
    }
}

struct AccessIncidentCard: View {
    let incident: AccessIncident
    let onMarkReviewed: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(incident.door)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)
                    Text(incident.method)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(incident.status.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(incident.status.tint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(incident.status.tint.opacity(0.12))
                    .clipShape(Capsule())
            }

            Text(incident.summary)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)

            Text(incident.source)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)

            if let occurredAt = incident.occurredAt {
                Text(occurredAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
            } else {
                Text("Date not recorded")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
            }

            if incident.status == .needsReview {
                Button(action: onMarkReviewed) {
                    Label("Mark reviewed", systemImage: "checkmark.circle")
                        .font(.system(size: 14, weight: .semibold))
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct LogAccessIssueView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var door = ""
    @State private var method = "Phone check-in"
    @State private var summary = ""

    let onSave: (AccessIncident) -> Void
    private let methods = ["Phone check-in", "Key tag", "Staff report", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Where did it happen?") {
                    TextField("Door or area", text: $door)
                    Picker("Entry method", selection: $method) {
                        ForEach(methods, id: \.self) { value in
                            Text(value)
                        }
                    }
                }

                Section("What happened?") {
                    TextField("Describe the issue", text: $summary, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Text("Do not include member names or private details. This prototype does not save reports after the session ends.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Log access issue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let incident = AccessIncident(
                            occurredAt: Date(),
                            door: door.trimmingCharacters(in: .whitespacesAndNewlines),
                            method: method,
                            summary: summary.trimmingCharacters(in: .whitespacesAndNewlines),
                            source: "Manually logged • local prototype",
                            status: .needsReview
                        )
                        onSave(incident)
                        dismiss()
                    }
                    .disabled(door.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
