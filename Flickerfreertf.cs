using System;
using System.Windows.Forms;

namespace Glos
{
	/// <summary>
	/// Summary description for Flickerfreertf.
	/// </summary>
	public class Flickerfreertf : RichTextBox
		{
			const short WM_PAINT = 0x00f;
			public Flickerfreertf()
			{
			}

			public static bool _Paint = true;
			protected override void WndProc(ref System.Windows.Forms.Message m)
			{
				// Code courtesy of Mark Mihevc
				// sometimes we want to eat the paint message so we don't have to see all the
				// flicker from when we select the text to change the color.
				if (m.Msg == WM_PAINT)
				{
					if (_Paint)
						base.WndProc(ref m);   // if we decided to paint this control, just call the RichTextBox WndProc
					else
						m.Result = IntPtr.Zero;   //  not painting, must set this to IntPtr.Zero if not painting otherwise serious problems.
				}
				else
					base.WndProc (ref m);   // message other than WM_PAINT, jsut do what you normally do.

			}
		}
}
