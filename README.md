# AudioWaveReader

Reads audio track from video file.

## Usage
```
AudioWaveReader(asset: asset).readAsynchronously { result in
    switch result {
    case .success(let data):
        DispatchQueue.main.async {
            self.waveData = data
        }
    case .failure(let error):
        debugPrint("AudioWaveReader", error)
    }
}
```
