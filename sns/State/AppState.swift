import Foundation
import Observation

protocol ProfileCriteriaOption: CaseIterable, Identifiable, Hashable {
    var label: String { get }
}

extension ProfileCriteriaOption {
    var id: Self { self }
}

enum GenderIdentity: String, ProfileCriteriaOption {
    case male
    case female
    case nonbinary

    var label: String {
        switch self {
        case .male: "Male"
        case .female: "Female"
        case .nonbinary: "Nonbinary"
        }
    }
}

enum PronounOption: String, ProfileCriteriaOption {
    case heHim = "he/him"
    case sheHer = "she/her"
    case theyThem = "they/them"
    case notListed = "not listed"

    var label: String {
        rawValue
    }
}

enum SexualityOption: String, ProfileCriteriaOption {
    case straight
    case gay
    case lesbian
    case bisexual
    case notListed

    var label: String {
        switch self {
        case .straight: "Straight"
        case .gay: "Gay"
        case .lesbian: "Lesbian"
        case .bisexual: "Bisexual"
        case .notListed: "Not listed"
        }
    }
}

enum SubstanceUseCategory: String, ProfileCriteriaOption {
    case vaping
    case smoking
    case marijuana
    case drinking
    case other

    var label: String {
        switch self {
        case .vaping: "Vaping"
        case .smoking: "Smoking"
        case .marijuana: "Marijuana"
        case .drinking: "Drinking"
        case .other: "Other"
        }
    }
}

struct AvailabilityWindow: Identifiable, Hashable {
    let id: UUID
    var startTime: Date
    var endTime: Date

    init(id: UUID = UUID(), startTime: Date, endTime: Date) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
    }

    var isValid: Bool {
        endTime > startTime
    }
}

struct WeeklyAvailabilityDay: Identifiable, Hashable {
    var date: Date
    var windows: [AvailabilityWindow]

    var id: Date { date }

    init(date: Date, windows: [AvailabilityWindow] = []) {
        self.date = Calendar.current.startOfDay(for: date)
        self.windows = windows
    }

    var hasValidWindow: Bool {
        windows.contains { $0.isValid }
    }
}

enum WeeklyAvailabilityCalendar {
    static func configuredCalendar(from calendar: Calendar = .current) -> Calendar {
        var configuredCalendar = calendar
        configuredCalendar.firstWeekday = 2
        return configuredCalendar
    }

    static func currentWeekDates(containing date: Date = Date(), calendar: Calendar = .current) -> [Date] {
        let configuredCalendar = configuredCalendar(from: calendar)
        guard let weekInterval = configuredCalendar.dateInterval(of: .weekOfYear, for: date) else {
            return []
        }

        return (0..<7).compactMap {
            configuredCalendar.date(byAdding: .day, value: $0, to: weekInterval.start)
        }
    }

    static func currentWeekDateRange(containing date: Date = Date(), calendar: Calendar = .current) -> Range<Date>? {
        let dates = currentWeekDates(containing: date, calendar: calendar)
        guard let start = dates.first else { return nil }

        let configuredCalendar = configuredCalendar(from: calendar)
        let end = configuredCalendar.date(byAdding: .day, value: 7, to: start) ?? start
        return start..<end
    }
}

@Observable
final class AppState {
    var myCard: AppContact
    var contacts: [AppContact]
    var groups: [AppGroup]
    var age: Int
    var gender: GenderIdentity
    var pronouns: PronounOption
    var sexuality: SexualityOption
    var substanceUse: Set<SubstanceUseCategory>
    var preferredGenders: Set<GenderIdentity>
    var preferredSexualities: Set<SexualityOption>
    var acceptedSubstanceUse: Set<SubstanceUseCategory>
    var preferredAgeMin: Int
    var preferredAgeMax: Int
    var matchPolicy: MatchPolicy
    var matchingLocation: String
    var matchingRadiusMiles: Int
    var extendRadiusIfNeeded: Bool
    var weeklyAvailability: [WeeklyAvailabilityDay]

    var fofSourceCount: Int {
        contacts.filter(\.useForFoFRecommendations).count
    }

    init(
        myCard: AppContact,
        contacts: [AppContact],
        groups: [AppGroup],
        age: Int = 24,
        gender: GenderIdentity = .female,
        pronouns: PronounOption = .sheHer,
        sexuality: SexualityOption = .notListed,
        substanceUse: Set<SubstanceUseCategory> = [],
        preferredGenders: Set<GenderIdentity> = Set(GenderIdentity.allCases),
        preferredSexualities: Set<SexualityOption> = Set(SexualityOption.allCases),
        acceptedSubstanceUse: Set<SubstanceUseCategory> = Set(SubstanceUseCategory.allCases),
        preferredAgeMin: Int = 21,
        preferredAgeMax: Int = 27,
        matchPolicy: MatchPolicy = .mutualsOnly,
        matchingLocation: String = "SoMa",
        matchingRadiusMiles: Int = 10,
        extendRadiusIfNeeded: Bool = false,
        weeklyAvailability: [WeeklyAvailabilityDay] = []
    ) {
        self.myCard = myCard
        self.contacts = contacts
        self.groups = groups
        self.age = age
        self.gender = gender
        self.pronouns = pronouns
        self.sexuality = sexuality
        self.substanceUse = substanceUse
        self.preferredGenders = preferredGenders
        self.preferredSexualities = preferredSexualities
        self.acceptedSubstanceUse = acceptedSubstanceUse
        self.preferredAgeMin = preferredAgeMin
        self.preferredAgeMax = preferredAgeMax
        self.matchPolicy = matchPolicy
        self.matchingLocation = matchingLocation
        self.matchingRadiusMiles = matchingRadiusMiles
        self.extendRadiusIfNeeded = extendRadiusIfNeeded
        self.weeklyAvailability = weeklyAvailability
    }

    static func mock() -> AppState {
        AppState(
            myCard: AppContact(name: "My Name"),
            contacts: MockData.contacts,
            groups: MockData.groups
        )
    }

    func add(_ contact: AppContact, toGroupAt groupIndex: Int) {
        guard groups.indices.contains(groupIndex), !groups[groupIndex].members.contains(where: { $0.id == contact.id }) else { return }
        groups[groupIndex].members.append(contact)
    }

    func removeContact(_ contactID: AppContact.ID, fromGroupAt groupIndex: Int) {
        guard groups.indices.contains(groupIndex) else { return }
        groups[groupIndex].members.removeAll { $0.id == contactID }
    }
}

extension AppState {
    var hasCompleteWeeklyAvailability: Bool {
        weeklyAvailability.contains { $0.hasValidWindow }
    }

    var weeklyAvailabilitySummary: String {
        let validWindowCount = weeklyAvailability.reduce(0) { total, day in
            total + day.windows.filter(\.isValid).count
        }

        switch validWindowCount {
        case 0:
            return "No availability"
        case 1:
            return "1 time window"
        default:
            return "\(validWindowCount) time windows"
        }
    }

    func setWeeklyAvailabilityDates(_ dates: Set<DateComponents>, calendar: Calendar = .current) {
        let configuredCalendar = WeeklyAvailabilityCalendar.configuredCalendar(from: calendar)
        let selectedDates = dates.compactMap { components in
            configuredCalendar.date(from: components).map { configuredCalendar.startOfDay(for: $0) }
        }

        weeklyAvailability = selectedDates
            .sorted()
            .map { selectedDate in
                weeklyAvailability.first { configuredCalendar.isDate($0.date, inSameDayAs: selectedDate) }
                    ?? WeeklyAvailabilityDay(date: selectedDate)
            }
    }

    func addAvailabilityWindow(on date: Date, calendar: Calendar = .current) {
        let configuredCalendar = WeeklyAvailabilityCalendar.configuredCalendar(from: calendar)
        let day = configuredCalendar.startOfDay(for: date)
        let startTime = configuredCalendar.date(bySettingHour: 18, minute: 0, second: 0, of: day) ?? day
        let endTime = configuredCalendar.date(bySettingHour: 20, minute: 0, second: 0, of: day) ?? startTime

        guard let index = weeklyAvailability.firstIndex(where: { configuredCalendar.isDate($0.date, inSameDayAs: day) }) else {
            weeklyAvailability.append(WeeklyAvailabilityDay(date: day, windows: [
                AvailabilityWindow(startTime: startTime, endTime: endTime)
            ]))
            weeklyAvailability.sort { $0.date < $1.date }
            return
        }

        weeklyAvailability[index].windows.append(AvailabilityWindow(startTime: startTime, endTime: endTime))
    }

    func removeAvailabilityWindow(_ windowID: AvailabilityWindow.ID, on date: Date, calendar: Calendar = .current) {
        let configuredCalendar = WeeklyAvailabilityCalendar.configuredCalendar(from: calendar)
        guard let index = weeklyAvailability.firstIndex(where: { configuredCalendar.isDate($0.date, inSameDayAs: date) }) else {
            return
        }

        weeklyAvailability[index].windows.removeAll { $0.id == windowID }
    }

    var profileSummary: String {
        "\(age), \(gender.label)"
    }

    var substanceUseSummary: String {
        Self.summary(
            for: substanceUse,
            emptyLabel: "None listed",
            allLabel: "All listed"
        )
    }

    var preferredGendersSummary: String {
        Self.summary(
            for: preferredGenders,
            emptyLabel: "None selected",
            allLabel: "Open to all"
        )
    }

    var preferredSexualitiesSummary: String {
        Self.summary(
            for: preferredSexualities,
            emptyLabel: "None selected",
            allLabel: "Open to all"
        )
    }

    var acceptedSubstanceUseSummary: String {
        Self.summary(
            for: acceptedSubstanceUse,
            emptyLabel: "None selected",
            allLabel: "Open to all"
        )
    }

    private static func summary<Option: ProfileCriteriaOption>(
        for values: Set<Option>,
        emptyLabel: String,
        allLabel: String
    ) -> String {
        if values.isEmpty {
            return emptyLabel
        }

        let allOptions = Array(Option.allCases)
        if values.count == allOptions.count && allOptions.allSatisfy(values.contains) {
            return allLabel
        }

        return allOptions
            .filter(values.contains)
            .map(\.label)
            .joined(separator: ", ")
    }
}
