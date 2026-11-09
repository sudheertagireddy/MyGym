import Foundation
import Observation

enum MembershipStatus: String, Codable, CaseIterable, Identifiable {
    case active = "Active"
    case pastDue = "Past due"
    case frozen = "Frozen"
    case expired = "Expired"

    var id: String { rawValue }
}

enum IncidentStatus: String, Codable, CaseIterable, Identifiable {
    case needsReview = "Needs review"
    case reviewed = "Reviewed"

    var id: String { rawValue }
}

struct GymMember: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var email: String
    var phone: String
    var planName: String
    var status: MembershipStatus
    var joinedAt: Date = Date()
    var visitsThisMonth: Int = 0
}

struct GymPlan: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var monthlyPrice: Double
    var benefits: String
}

struct GymClass: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var instructor: String
    var location: String
    var startsAt: Date
    var durationMinutes: Int
    var capacity: Int
    var bookedMemberIDs: [UUID] = []
}

struct CheckInEvent: Identifiable, Codable, Hashable {
    var id = UUID()
    var memberID: UUID
    var memberName: String
    var occurredAt: Date = Date()
    var method: String = "Staff check-in (demo)"
}

struct AccessIssue: Identifiable, Codable, Hashable {
    var id = UUID()
    var door: String
    var method: String
    var summary: String
    var source: String
    var reportedAt: Date = Date()
    var status: IncidentStatus = .needsReview
}

@MainActor
@Observable
final class GymStore {
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let keyPrefix = "mygym.local-demo.v1."

    var members: [GymMember] { didSet { persist() } }
    var plans: [GymPlan] { didSet { persist() } }
    var classes: [GymClass] { didSet { persist() } }
    var checkIns: [CheckInEvent] { didSet { persist() } }
    var incidents: [AccessIssue] { didSet { persist() } }

    let managerReportedFailedScans = 34

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        members = Self.restore([GymMember].self, key: "members", defaults: defaults, fallback: Self.demoMembers)
        plans = Self.restore([GymPlan].self, key: "plans", defaults: defaults, fallback: Self.demoPlans)
        classes = Self.restore([GymClass].self, key: "classes", defaults: defaults, fallback: Self.demoClasses)
        checkIns = Self.restore([CheckInEvent].self, key: "checkins", defaults: defaults, fallback: [])
        incidents = Self.restore([AccessIssue].self, key: "incidents", defaults: defaults, fallback: Self.demoIncidents)
    }

    private static func restore<T: Decodable>(_ type: T.Type, key: String, defaults: UserDefaults, fallback: T) -> T {
        guard let data = defaults.data(forKey: "mygym.local-demo.v1." + key),
              let value = try? JSONDecoder().decode(type, from: data) else { return fallback }
        return value
    }

    private func persist() {
        save(members, key: "members")
        save(plans, key: "plans")
        save(classes, key: "classes")
        save(checkIns, key: "checkins")
        save(incidents, key: "incidents")
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) { defaults.set(data, forKey: keyPrefix + key) }
    }

    func addMember(_ member: GymMember) { members.insert(member, at: 0) }

    func updateMemberStatus(_ memberID: UUID, to status: MembershipStatus) {
        guard let index = members.firstIndex(where: { $0.id == memberID }) else { return }
        members[index].status = status
    }

    func addPlan(_ plan: GymPlan) { plans.append(plan) }

    func addClass(_ gymClass: GymClass) { classes.append(gymClass); classes.sort { $0.startsAt < $1.startsAt } }

    func book(_ memberID: UUID, into classID: UUID) -> Bool {
        guard let index = classes.firstIndex(where: { $0.id == classID }),
              classes[index].bookedMemberIDs.count < classes[index].capacity,
              !classes[index].bookedMemberIDs.contains(memberID) else { return false }
        classes[index].bookedMemberIDs.append(memberID)
        return true
    }

    func recordStaffCheckIn(for member: GymMember) {
        checkIns.insert(CheckInEvent(memberID: member.id, memberName: member.name), at: 0)
        if let index = members.firstIndex(where: { $0.id == member.id }) {
            members[index].visitsThisMonth += 1
        }
    }

    func addIncident(_ issue: AccessIssue) { incidents.insert(issue, at: 0) }

    func markIncidentReviewed(_ issueID: UUID) {
        guard let index = incidents.firstIndex(where: { $0.id == issueID }) else { return }
        incidents[index].status = .reviewed
    }

    private static let demoPlans = [
        GymPlan(name: "Core", monthlyPrice: 39, benefits: "Gym floor access • Standard hours"),
        GymPlan(name: "Plus", monthlyPrice: 59, benefits: "Gym floor • Group classes • Extended hours"),
        GymPlan(name: "All Access", monthlyPrice: 79, benefits: "All areas • Classes • Guest pass")
    ]

    private static let demoMembers = [
        GymMember(name: "Alex Morgan", email: "alex@example.com", phone: "(555) 010-1200", planName: "Plus", status: .active, visitsThisMonth: 8),
        GymMember(name: "Jordan Lee", email: "jordan@example.com", phone: "(555) 010-1201", planName: "Core", status: .pastDue, visitsThisMonth: 2),
        GymMember(name: "Taylor Brooks", email: "taylor@example.com", phone: "(555) 010-1202", planName: "All Access", status: .active, visitsThisMonth: 12),
        GymMember(name: "Sam Patel", email: "sam@example.com", phone: "(555) 010-1203", planName: "Plus", status: .frozen, visitsThisMonth: 0),
        GymMember(name: "Casey Rivera", email: "casey@example.com", phone: "(555) 010-1204", planName: "Core", status: .active, visitsThisMonth: 5)
    ]

    private static let demoClasses = [
        GymClass(title: "Strength Circuit", instructor: "Coach Maya", location: "Studio A", startsAt: Date().addingTimeInterval(3600 * 2), durationMinutes: 45, capacity: 12),
        GymClass(title: "Yoga Flow", instructor: "Coach Leo", location: "Studio B", startsAt: Date().addingTimeInterval(3600 * 6), durationMinutes: 50, capacity: 16),
        GymClass(title: "HIIT Express", instructor: "Coach Nia", location: "Studio A", startsAt: Date().addingTimeInterval(3600 * 26), durationMinutes: 30, capacity: 10)
    ]

    private static let demoIncidents = [
        AccessIssue(door: "Main entrance", method: "Phone check-in", summary: "Entry was treated as sauna access and denied.", source: "Member report • verify against reader logs")
    ]
}

