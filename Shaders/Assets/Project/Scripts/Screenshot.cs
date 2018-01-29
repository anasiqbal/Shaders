using UnityEngine;
using System.IO;
using System;

public class Screenshot : MonoBehaviour {

	public int resolutionMultiplier = 1;

	[ContextMenu("Capture Screenshot")]
	public void CaptureScreenshot()
	{
		if (!Directory.Exists(Path.Combine(Application.dataPath,  "screenshots")))
			Directory.CreateDirectory(Path.Combine(Application.dataPath , "screenshots"));

		string filePath = Application.dataPath + string.Format("/screenshots/screen-{0}.png", DateTime.Now.ToString("yy-MM-dd-HH-mm-ss"));

		ScreenCapture.CaptureScreenshot(filePath);
		Debug.Log("Screenshot saved at path: " + filePath);
	}
}
