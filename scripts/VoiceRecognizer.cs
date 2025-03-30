using Godot;
using System;
using Vosk;
using NAudio.Wave; // Install via NuGet

public partial class VoiceRecognizer : Node
{
	private Model model;
	private VoskRecognizer recognizer;
	private WaveInEvent waveIn;

	public override void _Ready()
	{
		// Load the Vosk model (make sure the path is correct)
		model = new Model("res://vosk-model-small-en-us-0.15");
		recognizer = new VoskRecognizer(model, 16000.0f);

		// Initialize microphone input
		waveIn = new WaveInEvent();
		waveIn.WaveFormat = new WaveFormat(16000, 16, 1); // 16-bit PCM, mono, 16kHz
		waveIn.DataAvailable += OnAudioCaptured;
		waveIn.StartRecording();
	}

	private void OnAudioCaptured(object sender, WaveInEventArgs e)
	{
		if (recognizer.AcceptWaveform(e.Buffer, e.BytesRecorded))
		{
			string result = recognizer.Result();
			GD.Print("Recognized Speech: " + result);
		}
	}

	public override void _ExitTree()
	{
		waveIn.StopRecording();
		waveIn.Dispose();
		recognizer.Dispose();
		model.Dispose();
	}
}
