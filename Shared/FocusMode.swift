enum FocusMode {
    case on
    case off

    init?(_ value: String) {
        switch value.lowercased() {
        case "on":
            self = .on
        case "off":
            self = .off
        case "false":
            self = .off
        case "true":
            self = .on
        default:
            return nil
        }
    }
}
