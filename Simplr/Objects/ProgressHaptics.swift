//
//  ProgressHaptics.swift
//  Simplr
//

import AppKit

/// Trackpad feedback for the progress slider: a light tick when crossing
/// 25 / 50 / 75 % (in either direction) and a stronger one on reaching 100 %.
/// Mice have no haptic engine, so this is silently a no-op there.
enum ProgressHaptics {
    enum Feedback: Equatable {
        case milestone
        case complete
    }

    static func feedback(from old: Double, to new: Double) -> Feedback? {
        let oldStep = step(old), newStep = step(new)
        guard oldStep != newStep else { return nil }
        if newStep == 4 { return .complete }
        let crossed = (min(oldStep, newStep) + 1)...max(oldStep, newStep)
        return crossed.contains(where: { (1...3).contains($0) }) ? .milestone : nil
    }

    static func play(from old: Double, to new: Double) {
        guard let feedback = feedback(from: old, to: new) else { return }
        let pattern: NSHapticFeedbackManager.FeedbackPattern = feedback == .complete ? .levelChange : .alignment
        NSHapticFeedbackManager.defaultPerformer.perform(pattern, performanceTime: .now)
    }

    /// 0 below 25 %, 1–3 for each quarter, 4 at 100 %.
    private static func step(_ value: Double) -> Int {
        value >= 1 ? 4 : Int(max(value, 0) * 4)
    }
}
