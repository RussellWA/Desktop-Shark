using Godot;
using System;
using System.Runtime.InteropServices;

public partial class SystemNode : Node2D
{
	[DllImport("user32.dll")]
	private static extern IntPtr GetActiveWindow();
	
	[DllImport("user32.dll")]
	private static extern int SetWindowLong(IntPtr hwnd, int index, uint val);
	
	[DllImport("user32.dll")]
	private static extern int SetLayeredWindowAttributes(IntPtr hwnd, uint crKey, byte bAlpha, uint dwFlags);

	private const int GWL_EXSTYLE = -20;
	private const int WS_EX_LAYERED = 0x80000;
	private const uint LWA_COLORKEY = 0x00000001;

	public void SetupTransparentWindow()
	{
		IntPtr hWnd = GetActiveWindow();
		SetWindowLong(hWnd, GWL_EXSTYLE, WS_EX_LAYERED);
		SetLayeredWindowAttributes(hWnd, 0, 0, LWA_COLORKEY);
	}
}
