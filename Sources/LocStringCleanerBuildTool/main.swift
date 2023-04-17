import Foundation
import LocStringCleaner

func findProjectPath(inDirectory directoryPath: String) -> String? {
    let fileManager = FileManager.default
    let enumerator = fileManager.enumerator(atPath: directoryPath)
    
    while let filePath = enumerator?.nextObject() as? String {
        if filePath.hasSuffix(".xcodeproj") || filePath.hasSuffix(".xcworkspace") {
            return URL(fileURLWithPath: directoryPath).appendingPathComponent(filePath).path
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

func extractKeys(localizableStringFilePath: String) -> [(key: String, lineNumber: Int)] {
    guard let content = try? String(contentsOfFile: localizableStringFilePath) else { return [] }
    
    let lines = content.split(separator: "\n")
    var keysWithLineNumbers: [(key: String, lineNumber: Int)] = []
    
    for (index, line) in lines.enumerated() {
        if line.trimmingCharacters(in: .whitespaces).isEmpty { continue }
        let components = line.components(separatedBy: " = ")
        if let key = components.first {
            keysWithLineNumbers.append((key: key.trimmingCharacters(in: .whitespaces), lineNumber: index + 1))            }
    }
    return keysWithLineNumbers
}

func isKeyUsed(_ key: String, inDirectory directoryPath: String) -> Bool {
    let fileManager = FileManager.default
    let enumerator = fileManager.enumerator(atPath: directoryPath)
    
    while let filePath = enumerator?.nextObject() as? String {
        if filePath.hasSuffix(".swift") {
            let swiftFilePath = URL(fileURLWithPath: directoryPath).appendingPathComponent(filePath).path
            do {
                let fileContent = try String(contentsOf: URL(fileURLWithPath: swiftFilePath), encoding: .utf8)
                let contentByLines = fileContent.split(separator: "\n").map(String.init)
                
                if contentByLines.contains(where: { $0.contains("\(key)") }) {
                    return true
                }
                
            } catch {
                print("Error: Could not read file content at path '\(swiftFilePath)'")
            }
        }
    }
    return false
}


func main() {
    let projectRootPath: String
    
    if let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"] {
        projectRootPath = srcRoot
    } else {
        print("Error: Could not find the SRCROOT environment variable.")
        exit(1)
    }
    
    guard let projectPath = findProjectPath(inDirectory: projectRootPath) else {
        print("Error: Could not find .xcodeproj or .xcworkspace file in the project root directory.")
        exit(1)
    }
    print("warning: projectpath \(projectRootPath)")

    print("warning: Found project at path: \(projectPath)")
    
    
    let parentDirectoryPath = URL(fileURLWithPath: projectPath).deletingLastPathComponent().path
    print("warning: search starting point(test): \(parentDirectoryPath)")
    
    guard findProjectPath(inDirectory: parentDirectoryPath) != nil else {
        print("Error: Could not find the project root path.")
        exit(1)
    }
    
    
    // Find all Localizable.strings files in the project
    let localizableStringsFiles = findLocalizableStringsFiles(inDirectory: projectRootPath)
    
    // Process each Localizable.strings file
    for localizableStringsPath in localizableStringsFiles {
        let keysWithLineNumbers = extractKeys(localizableStringFilePath: localizableStringsPath)
        for (key, lineNumber) in keysWithLineNumbers {
            print("warning: (test) searching key \(key)")
            if !isKeyUsed(key, inDirectory: projectRootPath) {
                let warningMessage = "\(localizableStringsPath):\(lineNumber):1: warning: Unused localized string key '\(key)'"
                print(warningMessage)
            }
        }
    }
}

main()

