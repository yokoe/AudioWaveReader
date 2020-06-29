import AVFoundation

public class AudioWaveReader {
    public enum Result {
        case success(data: [Int16])
        case failure(error: Error)
    }
    
    private let asset: AVAsset
    private let samplingRate: Int
    
    public init(asset: AVAsset, samplingRate: Int = 48000) {
        self.asset = asset
        self.samplingRate = samplingRate
    }
    
    public func readAsynchronously(
        progress: ((Progress) -> ())? = nil,
        completion: @escaping ((Result) -> ())
    ) {
        DispatchQueue.global().async {
            completion(self.read(progress: progress))
        }
    }
    
    private func read(progress: ((Progress) -> ())? = nil) -> Result {
        let audioTracks = asset.tracks(withMediaType: .audio)
        if audioTracks.isEmpty {
            return .failure(error: NSError(domain: "AudioWaveReader", code: 1, userInfo: [NSLocalizedDescriptionKey: "No audio tracks"]))
        }
        if audioTracks.count != 1 {
            debugPrint(String(format: "Warning: %d audio tracks found", audioTracks.count))
        }
        
        do {
            let reader = try AVAssetReader(asset: asset)
            let trackOutput = AVAssetReaderTrackOutput(track: audioTracks[0], outputSettings: [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsFloatKey: false,
                AVSampleRateKey: samplingRate,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMIsBigEndianKey: false,
            ])
            reader.add(trackOutput)
            
            reader.startReading()
            var waveData = [Int16]()
            
            var readDuration: TimeInterval = 0
            let readProgress = Progress(totalUnitCount: Int64(reader.asset.duration.seconds * 100))
            while reader.status == .reading {
                if let buffer = trackOutput.copyNextSampleBuffer() {
                    guard let dataBuffer = buffer.dataBuffer else {
                        debugPrint("No data buffer")
                        continue
                    }
                    
                    let data = try dataBuffer.dataBytes()
                    waveData.append(contentsOf: data.withUnsafeBytes {
                        Array($0.bindMemory(to: Int16.self)).map(Int16.init(littleEndian:))
                    })
                    readDuration += buffer.duration.seconds
                    readProgress.completedUnitCount = Int64(readDuration * 100)
                    
                    progress?(readProgress)
                }
            }
            
            if reader.status == .failed || reader.status == .unknown {
                return .failure(error: NSError(domain: "AudioWaveReader", code: 2, userInfo: [NSLocalizedDescriptionKey: "something went wrong"]))
            }
            
            return .success(data: waveData)
            
        } catch let error {
            return .failure(error: error)
        }
    }
}

