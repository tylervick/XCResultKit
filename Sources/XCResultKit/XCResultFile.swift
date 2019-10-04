//
//  XCResultFile.swift
//  
//
//  Created by David House on 7/6/19.
//

import Foundation

public class XCResultFile {
    
    let url: URL
    
    public init(url: URL) {
        self.url = url
    }
    
    public func getInvocationRecord() -> ActionsInvocationRecord? {
        
        guard let getOutput = shell(command: ["-l", "-c", "xcrun xcresulttool get --path \(url.path) --format json"]) else {
            return nil
        }
        
        do {
            guard let data = getOutput.data(using: .utf8) else {
                debug("Unable to turn string into data, must not be a utf8 string")
                return nil
            }
            
            guard let rootJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else {
                debug("Expecting top level dictionary but didn't find one")
                return nil
            }
            
            let invocation = ActionsInvocationRecord(rootJSON)
            return invocation
        } catch {
            debug("Error deserializing JSON: \(error)")
            return nil
        }
    }
    
    public func getTestPlanRunSummaries(id: String) -> ActionTestPlanRunSummaries? {
        
        guard let getOutput = shell(command: ["-l", "-c", "xcrun xcresulttool get --path \(url.path) --id \(id) --format json"]) else {
            return nil
        }
        
        do {
            guard let data = getOutput.data(using: .utf8) else {
                debug("Unable to turn string into data, must not be a utf8 string")
                return nil
            }
            
            guard let rootJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else {
                debug("Expecting top level dictionary but didn't find one")
                return nil
            }
            
            let runSummaries = ActionTestPlanRunSummaries(rootJSON)
            return runSummaries
        } catch {
            debug("Error deserializing JSON: \(error)")
            return nil
        }
    }
    
    public func getActionTestSummary(id: String) -> ActionTestSummary? {
        
        guard let getOutput = shell(command: ["-l", "-c", "xcrun xcresulttool get --path \(url.path) --id \(id) --format json"]) else {
            return nil
        }
        
        do {
            guard let data = getOutput.data(using: .utf8) else {
                debug("Unable to turn string into data, must not be a utf8 string")
                return nil
            }
            
            guard let rootJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else {
                debug("Expecting top level dictionary but didn't find one")
                return nil
            }
            
            let summary = ActionTestSummary(rootJSON)
            return summary
        } catch {
            debug("Error deserializing JSON: \(error)")
            return nil
        }
    }
    
    public func getPayload(id: String) -> Data? {
        
        guard let getOutput = shell(command: ["-l", "-c", "xcrun xcresulttool get --path \(url.path) --id \(id)"]) else {
            return nil
        }
        
        guard let data = getOutput.data(using: .utf8) else {
            debug("Unable to turn string into data, must not be a utf8 string")
            return nil
        }
        return data
    }
    
    public func exportPayload(id: String) -> URL? {
        
        let tempPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(id)
        _ = shell(command: ["-l", "-c", "xcrun xcresulttool export --type file --path \(url.path) --id \(id) --output-path \(tempPath.path)"])
        return tempPath
    }
    
    public func getCodeCoverage() -> CodeCoverage? {
        
        guard let getOutput = shell(command: ["-l", "-c", "xcrun xccov view --report --json \(url.path)"]) else {
            return nil
        }
        
        do {
            guard let data = getOutput.data(using: .utf8) else {
                debug("Unable to turn string into data, must not be a utf8 string")
                return nil
            }
            
            let decoded = try JSONDecoder().decode(CodeCoverage.self, from: data)
            return decoded
        } catch {
            debug("Error deserializing JSON: \(error)")
            return nil
        }
    }
    
    private func shell(command: [String]) -> String? {
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = command
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String? = String(data: data, encoding: String.Encoding.utf8)
        
        return output
    }
}
