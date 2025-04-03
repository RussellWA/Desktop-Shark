using Godot;
using System;
using Vosk;
using NAudio.Wave;
using System.Runtime.InteropServices;

public partial class SpeechRecognition : Node
{
	
	[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
	static extern IntPtr LoadLibrary(string lpFileName);
	
	private Model model;
	private VoskRecognizer recognizer;
	private WaveInEvent waveIn;

	public override void _Ready()
	{
		try
		{
			//string dllPath = ProjectSettings.GlobalizePath("res://vosklibs/win-x64/libvosk.dll");
			//
			//// Try loading the library
			//IntPtr handle = LoadLibrary(dllPath);
			//if (handle == IntPtr.Zero)
			//{
				//GD.PrintErr("❌ Failed to load libvosk.dll. Check the path!");
				//return;
			//}
//
			//GD.Print("✅ libvosk.dll loaded successfully from: " + dllPath);
			
			GD.Print("Loading Vosk model...");
			model = new Model("res://addons/vosk-model-small-en-us/");  // Check this path!
			GD.Print("Vosk model loaded successfully!");

			recognizer = new VoskRecognizer(model, 16000.0f);

			waveIn = new WaveInEvent();
			waveIn.WaveFormat = new WaveFormat(16000, 16, 1);
			waveIn.DataAvailable += OnAudioCaptured;
			waveIn.StartRecording();

			GD.Print("Microphone and Vosk started!");
		}
		catch (Exception e)
		{
			GD.PrintErr("Error initializing Vosk: " + e.Message);
		}
	}

	private void OnAudioCaptured(object sender, WaveInEventArgs e)
	{
		GD.Print("Received audio from mic. Processing...");

		if (recognizer.AcceptWaveform(e.Buffer, e.BytesRecorded))
		{
			string result = recognizer.Result();
			GD.Print("🎤 Recognized Speech: " + result);
		}
		else
		{
			string partial = recognizer.PartialResult();
			GD.Print("🔄 Partial Speech: " + partial);
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
