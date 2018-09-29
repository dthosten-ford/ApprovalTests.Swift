//
// Created by Industrial Logic on 9/29/18.
// Copyright (c) 2018 NA. All rights reserved.
//

import Foundation

class Namer: ApprovalNamer {
    var className = String()
    var testName = String()

    func getApprovalName() -> String {
        demangleStack(depth: 3)
        return className + "." + testName
    }

    func getSourceFilePath() -> String {
        demangleStack(depth: 3)
        let fileManager = FileManager.default
        let directoryName = fileManager.currentDirectoryPath

        let baseName = String(format:"%@/%@.%@", directoryName, className, testName)
        return baseName;
    }

    private func demangleStack(depth: Int) {
        do {
            var result = String()

            let symbols = Thread.callStackSymbols

            let index = symbols[depth].range(of: "_T")?.lowerBound
            let tempName = String(symbols[depth].suffix(from: index!))

            let indexEnd = tempName.range(of: " ")?.lowerBound
            let mangledName = String(tempName.prefix(upTo: indexEnd!))

            let swiftSymbol = try parseMangledSwiftSymbol(mangledName)
            result = swiftSymbol.print(using: SymbolPrintOptions.simplified.union(.synthesizeSugarOnTypes))

            let splitResult = result.split(separator: " ")
            let classAndMethod = splitResult.last!

            className = extractClassName(result: String(classAndMethod))
            testName = extractTestName(result: String(classAndMethod))

        } catch {
            print("Got an error")
        }
    }

    private func extractTestName(result: String) -> String {
        let testNameWithParens = String(result.suffix(from: (result.range(of: ".")?.upperBound)!))
        let testName = String(testNameWithParens.prefix(upTo: (testNameWithParens.range(of: "(")?.lowerBound)!))
        return testName
    }

    private func extractClassName(result: String) -> String {
        let className = String(result.prefix(upTo: (result.range(of: ".")?.lowerBound)!))
        return className
    }
}

