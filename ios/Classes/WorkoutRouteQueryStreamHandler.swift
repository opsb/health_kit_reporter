//
//  WorkoutRouteQueryStreamHandler.swift
//  health_kit_reporter
//
//  Created by Florian on 09.12.20.
//

import Foundation
import HealthKitReporter

public class WorkoutRouteQueryStreamHandler: NSObject {
    let reporter: HealthKitReporter
    var query: SampleQuery?

    public init(reporter: HealthKitReporter) {
        self.reporter = reporter
    }
}
// MARK: - StreamHandlerProtocol
extension WorkoutRouteQueryStreamHandler: StreamHandlerProtocol {
    func setQuery(arguments: [String: Any], events: @escaping FlutterEventSink) throws {
        guard
            let startTimestamp = arguments["startTimestamp"] as? Double,
            let endTimestamp = arguments["endTimestamp"] as? Double
        else {
            return
        }
        let predicate = NSPredicate.samplesPredicate(
            startDate: Date.make(from: startTimestamp),
            endDate: Date.make(from: endTimestamp)
        )
        if #available(iOS 13.0, *) {
            query = try reporter.reader.workoutRouteQuery(
                predicate: predicate
            ) { (workoutRoute, error) in
                guard
                    error == nil,
                    let workoutRoute = workoutRoute
                else {
                    return
                }
                do {
                    events(try workoutRoute.encoded())
                } catch {
                    events(nil)
                }
            }
        } else {
            events(nil)
        }
    }
}
// MARK: - FlutterStreamHandler
extension WorkoutRouteQueryStreamHandler: FlutterStreamHandler {
    public func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        handleOnListen(withArguments: arguments, eventSink: events)
    }
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        handleOnCancel(withArguments: arguments)
    }
}

