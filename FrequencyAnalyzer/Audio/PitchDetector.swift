import Accelerate
import Foundation

struct PitchDetector {
    let sampleRate: Float
    let threshold: Float

    init(sampleRate: Float, threshold: Float = 0.15) {
        self.sampleRate = sampleRate
        self.threshold = threshold
    }

    func detectPitch(buffer: UnsafePointer<Float>, frameCount: Int) -> Float? {
        let minLag = Int(sampleRate / 2000) // max ~2000 Hz
        let maxLag = Int(sampleRate / 50)   // min ~50 Hz

        guard maxLag < frameCount / 2 else { return nil }

        // Step 1: Difference function using vDSP
        var difference = [Float](repeating: 0, count: maxLag + 1)

        for tau in 1...maxLag {
            var sum: Float = 0
            let count = vDSP_Length(frameCount - maxLag)

            // Compute (x[j] - x[j+tau])^2 using vDSP
            var diff = [Float](repeating: 0, count: Int(count))
            vDSP_vsub(buffer + tau, 1, buffer, 1, &diff, 1, count)
            vDSP_dotpr(diff, 1, diff, 1, &sum, count)

            difference[tau] = sum
        }

        // Step 2: Cumulative mean normalized difference
        var cmndf = [Float](repeating: 0, count: maxLag + 1)
        cmndf[0] = 1.0
        var runningSum: Float = 0

        for tau in 1...maxLag {
            runningSum += difference[tau]
            if runningSum == 0 {
                cmndf[tau] = 1.0
            } else {
                cmndf[tau] = difference[tau] * Float(tau) / runningSum
            }
        }

        // Step 3: Absolute threshold - find first tau below threshold, then walk to local min
        var bestTau = -1
        for tau in minLag...maxLag {
            if cmndf[tau] < threshold {
                bestTau = tau
                // Walk forward to find the local minimum
                var t = tau + 1
                while t <= maxLag && cmndf[t] < cmndf[t - 1] {
                    bestTau = t
                    t += 1
                }
                break
            }
        }

        guard bestTau > 0 else { return nil }

        // Step 4: Parabolic interpolation for sub-sample accuracy
        let refined: Float
        if bestTau > 0 && bestTau < maxLag {
            let s0 = cmndf[bestTau - 1]
            let s1 = cmndf[bestTau]
            let s2 = cmndf[bestTau + 1]
            let adjustment = (s0 - s2) / (2.0 * (s0 - 2.0 * s1 + s2))
            refined = Float(bestTau) + adjustment
        } else {
            refined = Float(bestTau)
        }

        // Step 5: Convert to frequency
        let frequency = sampleRate / refined
        guard frequency >= 50 && frequency <= 2000 else { return nil }

        return frequency
    }
}
