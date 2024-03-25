// README

here is how to get the token from the userdefaults

// To retrieve a string. If the key doesn't exist the return value for the string method is nil
let stringValue = UserDefaults.standard.string(forKey: "yourStringKey") ?? "defaultString"
