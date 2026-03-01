import Benchmark
import NanoID

let benchmarks: @Sendable () -> Void = {
    // Mirrors JS: nanoid() — default secure generation (21-char, URL-safe alphabet)
    Benchmark("nanoid") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(NanoID())
        }
    }

    // Mirrors JS: customAlphabet() — custom alphabet, same default size (21)
    Benchmark("customAlphabet") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(NanoID(from: NanoID.Alphabets.alphanumeric, size: 21))
        }
    }
}
