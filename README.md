🎶 ZedBoard Audio In/Out with FIR Filter
📌 Overview

The goal of this project is to implement and test birdsong playback chain using a pre-filtered WAV file. The FPGA design does not perform filtering on-board; instead, it receives the filtered audio via an SDK-generated bitstream and plays it through the audio interface.

📂 Repository Contents

📄 Procedure.pdf → Step-by-step documentation for setup & execution

📦 Project.zip → Source files & setup package for ZedBoard

🎵 birdsong.wav → Example input audio

🔢 birdsong.hex → Input audio samples (int16 HEX format)

🔢 coeffs.hex → FIR filter coefficients (Q15, HEX format)

🎧 filtered_preview.wav → Software FIR preview

🔢 output.hex → FPGA FIR output (captured)

🎧 birdsong_out.wav → Final reconstructed audio

🛠️ Features

Real-time Audio In → FIR → Audio Out pipeline on ZedBoard

65-tap FIR band-pass filter (2–6 kHz) with Q15 scaling

MATLAB utilities for audio → HEX conversion and FPGA output → WAV

SDK integration for audio drivers

Procedure PDF for easy replication

▶️ Setup & Usage

Refer to Procedure.pdf for detailed step-by-step setup instructions.

Load the project files from Project.zip into your Xilinx Vivado/SDK environment.

Connect the ZedBoard with audio input/output peripherals.

Run the design → test with output.wav.


🎥 Demo Video

📺 Watch the project in action on YouTube:
🔗 Audio In/Out on ZedBoard – Demo

🚀 Future Enhancements

Real-time adjustable filter coefficients

Support for multiple filter types (LPF, HPF, BPF, BSF)

Expansion to AGC, RMS meter, and noise gate modules
