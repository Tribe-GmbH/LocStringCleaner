import Foundation
import LocStringCleaner

func findProjectPath(projectName: String, inDirectory directoryPath: String) -> String? {
    let fileManager = FileManager.default
    guard let enumerator = fileManager.enumerator(atPath: directoryPath) else { return nil }
    
    while let filePath = enumerator.nextObject() as? String {
        if filePath.contains("\(projectName).xcodeproj") || filePath.contains("\(projectName).xcworkspace") {
            return directoryPath + "/" + filePath
        }
    }
    return nil
}

func findLocalizableStringsFiles(inDirectory directoryPath: String) -> [String] {
    let fileManager = FileManager.default
    guard let enumerator = fileManager.enumerator(atPath: directoryPath) else { return [] }
    
    var localizableStringsFiles: [String] = []
    while let filePath = enumerator.nextObject() as? String {
        if filePath.hasSuffix("Localizable.strings") {
            localizableStringsFiles.append(directoryPath + "/" + filePath)
        }
    }
    return localizableStringsFiles
}

func main() {
    // Locate the current directory path
    let currentDirectoryPath = "/Users/kokiisshiki/github.com/private/localizeTest"
    print("warning: search starting point(test): \(currentDirectoryPath)")
    
    let parentDirectoryPath = URL(fileURLWithPath: currentDirectoryPath).deletingLastPathComponent().path
    print("warning: search starting point(test): \(parentDirectoryPath)")

    // Find the .xcodeproj or .xcworkspace file and the project root path for "LocalizeTest"
    guard findProjectPath(projectName: "localizeTest", inDirectory: parentDirectoryPath) != nil else {
        print("Error: Could not find the project root path.")
        exit(1)
    }
    
    
    // Find all Localizable.strings files in the project
    let localizableStringsFiles = findLocalizableStringsFiles(inDirectory: currentDirectoryPath)
    print("warning: found localizableString(test): \(localizableStringsFiles)")
    
    // Process each Localizable.strings file
    for localizableStringsPath in localizableStringsFiles {
        // Add your logic to detect unused localized strings here
        // For demonstration purposes, let's show a warning if a Localizable.strings file is found
        let warningFilePath = localizableStringsPath
        let warningLineNumber = 1 // Output the warning on the first line
        let warningColumnNumber = 1 // Column number is set to 1 since we don't have the exact column number
        let warningMessage = "Unused localized string detected"
        
        // Output the warning message in Xcode's expected format for the file
        print("\(warningFilePath):\(warningLineNumber):\(warningColumnNumber): warning: \(warningMessage)")
        
        // Output a warning message for the navigation bar
        print("warning: Localizable.strings file found at: \(localizableStringsPath)")
    }
}

main()

