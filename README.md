# STT_Letter
Let's make a speech-to-text letter!

## SFSpeechRecognitionResult
- isFinal : transaction이 finish 된건지 아닌건지 알 수 있는 변수
  ``` swift
    var isFinal: Bool  // true: 최종 결과, false : 부분 발화
  ```
- 오디오 파일을 이용할 경우 : SFSpeechURLRecognitionRequest
- 라이브 음성을 사용할 경우 : SFSpeechAudioBufferRecognitionRequest
