using System;
using System.Drawing;
using System.Windows.Forms;
using System.Drawing.Printing;
using System.IO;
using Lion_assembler;

namespace Lion_assembler
{
    public partial class frmLionAsm : Form
    {
        public string fname = "File.asm";
        int fstart = 0;
        aparser par;
        Boolean exith, changed = false;
        const int un = 2;
        string[] oldtext = new string[un];

        private void MakeColorSyntaxForAll()
        {
            //  Store current cursor position
            exith = true;
            Flickerfreertf._Paint = false;
            int CurrentSelectionStart = fftxtSource.SelectionStart;
            int CurrentSelectionLength = fftxtSource.SelectionLength;
            int pos = 0;
            int pos2 = fftxtSource.Text.Length - 1;
            fftxtSource.SelectAll();
            fftxtSource.SelectionColor = Color.Black;
            int l = pos;
            char ch;
            Color c;
            string ctok = string.Empty;
            while (l < pos2)
            {
                //if ("ABCDEFGHIJKLMNOPQRSTVUWXYZ01234567890_.".IndexOf(fftxtSource.Text.ToUpper()[l]) != -1)
                ch = fftxtSource.Text.ToUpper()[l];
                if (ch == '.' || ch == '.' || (ch >= 'A' && ch <= 'Z') || (ch >= '0' && ch <= '9'))
                {
                    ctok = ctok + ch;
                    l++;
                }
                else
                {
                    //ctok = ctok.ToUpper();
                    if (fftxtSource.Text[l] == ';')
                    {
                        int ss = l;
                        fftxtSource.SelectionStart = ss;
                        l++;
                        while (l < pos2 && fftxtSource.Text[l] != '\n') l++;
                        fftxtSource.SelectionLength = l - ss;
                        fftxtSource.SelectionColor = Color.Green;
                    } else
                    if (ctok != string.Empty)
                    {
                        if (par.colorList.ContainsKey(ctok))
                        {   
                            c = (Color)par.colorList[ctok];
                            fftxtSource.Select(l - ctok.Length, ctok.Length);
                            fftxtSource.SelectionColor = c;
                        }
                        //else if (ctok.Length == 2 && ctok[0] == 'A' && ctok[1] > 47 && ctok[1] < 56)
                        //{
                        //    fftxtSource.Select(l - ctok.Length, ctok.Length);
                        //    fftxtSource.SelectionColor = Color.DarkViolet ;
                        //}
                        ctok = string.Empty;
                    } else
                    if (fftxtSource.Text[l] == '\'')
                    {
                        int ss = l;
                        fftxtSource.SelectionStart = ss;
                        l++;
                        while (l < pos2 && fftxtSource.Text[l] != '\'' && fftxtSource.Text[l] != '\n') l++;
                        fftxtSource.SelectionLength = l - ss+1;
                        fftxtSource.SelectionColor = Color.DarkRed;
                    }
                    else
                        if (fftxtSource.Text[l] == '\"')
                        {
                            int ss = l;
                            fftxtSource.SelectionStart = ss;
                            l++;
                            while (l < pos2 && fftxtSource.Text[l] != '\"' && fftxtSource.Text[l] != '\n') l++;
                            fftxtSource.SelectionLength = l - ss+1;
                            fftxtSource.SelectionColor = Color.DarkRed;
                        }
                    l++;
                }
            }
            if (ctok != string.Empty)
            {
                if (par.colorList.ContainsKey(ctok))
                {
                    c = (Color)par.colorList[ctok];
                    fftxtSource.Select(l - ctok.Length, ctok.Length);
                    fftxtSource.SelectionColor = c;
                }
                ctok = string.Empty;
            }
            //  Restore Cursor
            if (CurrentSelectionStart >= 0)
                fftxtSource.Select(CurrentSelectionStart,
                    CurrentSelectionLength);
            Flickerfreertf._Paint = true;
            exith = false;
        }

        public void MakeColorSyntaxForCurrentLine()
        {
            //  Store current cursor position

            if (exith || string.IsNullOrEmpty(fftxtSource.Text)) return;
            Flickerfreertf._Paint = false;
            int CurrentSelectionStart = fftxtSource.SelectionStart;
            int CurrentSelectionLength = fftxtSource.SelectionLength;

            // find start of line
            int pos = CurrentSelectionStart;

            while ((pos > 0) && (fftxtSource.Text[pos - 1] != '\n'))
                pos--;
            ;
            // find end of line
            int pos2 = CurrentSelectionStart;
            while ((pos2 < fftxtSource.Text.Length) && (fftxtSource.Text[pos2] != '\n')) pos2++;
            fftxtSource.SelectionStart = pos;
            fftxtSource.SelectionLength = pos2 - pos;
            string st = fftxtSource.Text.Substring(pos, pos2 - pos).TrimStart();
            if (pos < fftxtSource.Text.Length && st.StartsWith(";"))
            {
                fftxtSource.SelectionColor = Color.Green;
                Flickerfreertf._Paint = true;
                if (CurrentSelectionStart >= 0)
                    fftxtSource.Select(CurrentSelectionStart,
                        CurrentSelectionLength);
                return;
            }
            else fftxtSource.SelectionColor = Color.Black;
            int l = pos;
            Color c;
            char ch;
            string ctok = string.Empty;
            while (l < pos2)
            {
                //if ("ABCDEFGHIJKLMNOPQRSTVUWXYZ01234567890_.".IndexOf(fftxtSource.Text.ToUpper()[l]) != -1)
                ch = fftxtSource.Text.ToUpper()[l];
                if (ch == '.' || ch == '.' || (ch >= 'A' && ch <= 'Z') || (ch >= '0' && ch <= '9'))
                {
                    ctok = ctok + ch;
                    l++;
                }
                else
                {
                    //ctok = ctok.ToUpper();
                    if (fftxtSource.Text[l] == ';')
                    {
                        int ss = l;
                        fftxtSource.SelectionStart = ss;
                        l++;
                        while (l < pos2 && fftxtSource.Text[l] != '\n') l++;
                        fftxtSource.SelectionLength = l - ss;
                        fftxtSource.SelectionColor = Color.Green;
                    }
                    else
                        if (ctok != string.Empty)
                        {
                            if (par.colorList.ContainsKey(ctok))
                            {
                                c = (Color)par.colorList[ctok];
                                fftxtSource.Select(l - ctok.Length, ctok.Length);
                                fftxtSource.SelectionColor = c;
                            } 
                            //else if (ctok.Length == 2 && ctok[0] == 'A' && ctok[1] > 47 && ctok[1] < 56)
                            //    {
                            //        fftxtSource.Select(l - ctok.Length, ctok.Length);
                            //        fftxtSource.SelectionColor = Color.DeepSkyBlue;
                            //    }
                            ctok = string.Empty;
                        }
                        else
                            if (fftxtSource.Text[l] == '\'')
                            {
                                int ss = l;
                                fftxtSource.SelectionStart = ss;
                                l++;
                                while (l < pos2 && fftxtSource.Text[l] != '\'' && fftxtSource.Text[l] != '\n') l++;
                                fftxtSource.SelectionLength = l - ss+1;
                                fftxtSource.SelectionColor = Color.DarkRed;
                            }
                            else
                                if (fftxtSource.Text[l] == '\"')
                                {
                                    int ss = l;
                                    fftxtSource.SelectionStart = ss;
                                    l++;
                                    while (l < pos2 && fftxtSource.Text[l] != '\"' && fftxtSource.Text[l] != '\n') l++;
                                    fftxtSource.SelectionLength = l - ss+1;
                                    fftxtSource.SelectionColor = Color.DarkRed;
                                }
                    l++;
                }
            }
            if (ctok != string.Empty)
            {
                if (par.colorList.ContainsKey(ctok))
                {
                    c = (Color)par.colorList[ctok];
                    fftxtSource.Select(l - ctok.Length, ctok.Length);
                    fftxtSource.SelectionColor = c;
                }
                ctok = string.Empty;
            }
            //  Restore Cursor
            if (CurrentSelectionStart >= 0)
                fftxtSource.Select(CurrentSelectionStart,
                                        CurrentSelectionLength);
            Flickerfreertf._Paint = true;
        }

        public void goto_line_o(int l)
        {
            int pos = 0, line = 0;
            while (pos < fftxtSource.Text.Length && line != l)
            {
                if (fftxtSource.Text[pos] == '\n') line++;
                pos++;
            }
            if (pos < fftxtSource.Text.Length && line == l)
            {
                fftxtSource.SelectionStart = pos;
                fftxtSource.SelectionLength = 1;
            }
        }

        public void goto_line(int st)
        {
            int l, i, le;
            l = 0;
            i = 0;
            le = fftxtSource.Text.Length;
            do
            {
                if (i < le) i = fftxtSource.Text.IndexOf("\n", i + 1);
                else i = -1;
                l++;
            } while (l < st && i != -1);
            if (i < le && l == st)
            {
                fftxtSource.SelectionStart = i + 1;
                fftxtSource.SelectionLength = 1;
            }
        }

        int find_line(int st)
        {
            int l, i, le;
            l = 0;
            i = 0;
            le = fftxtSource.Text.Length;
            do
            {
                if (i < le) i = fftxtSource.Text.IndexOf("\n", i + 1);
                else i = -1;
                l++;
            } while (i < st && i != -1);
            return l;
        }

        public void MarkLine(int l, Color c)
        {
            exith = true;
            Flickerfreertf._Paint = false;
            goto_line(l);
            int pos = fftxtSource.SelectionStart;
            while ((pos > 0) && (fftxtSource.Text[pos - 1] != '\n')) pos--;
            // find end of line
            int pos2 = fftxtSource.SelectionStart;
            while ((pos2 < fftxtSource.Text.Length) && (fftxtSource.Text[pos2] != '\n')) pos2++;
            fftxtSource.SelectionStart = pos;
            fftxtSource.SelectionLength = pos2 - pos;
            fftxtSource.SelectionColor = c;
            Flickerfreertf._Paint = true;
            exith = false;
        }

        public frmLionAsm(string[] args)
        {

            InitializeComponent();

            if (args.Length > 0)
            {
                fname = args[0];
                changed = true;
                if (args.Length > 0)
                {
                    fname = args[0]; string line, bufs;
                    fftxtSource.Text = string.Empty;
                    bufs = string.Empty;
                    string temp = string.Empty;

                    using (StreamReader sr = new StreamReader(fname, System.Text.Encoding.GetEncoding(1253)))
                    {
                        while ((line = sr.ReadLine()) != null)
                        {
                            temp = temp + line + "\r\n";
                        }
                        bufs = temp.Substring(0, temp.Length - 2);
                    }
                    fftxtSource.Text = bufs;
                    changed = true;
                }
            }
        }

        private void Lionasm_Load(object sender, EventArgs e)
        {
            par = new aparser(this);
            if (!changed) MakeColorSyntaxForAll();
            changed = false;
            comboBox1.Text = "COM3";
        }



        private void openToolStripMenuItem1_Click(object sender, EventArgs e)
        {
            DialogResult d;
            string line, bufs;
            DialogResult res;
            exith = true;
            if (changed) res = MessageBox.Show("Text has changed and not saved, are you sure", "Open", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
            else res = DialogResult.Yes;
            if (res == DialogResult.Yes)
            {
                openFileDialog1.FileName = fname; // Path.GetFileName(fname);
                d = openFileDialog1.ShowDialog();
                if (d == DialogResult.OK)
                {
                    fname = openFileDialog1.FileName;
                    fftxtSource.Text = string.Empty;
                    bufs = string.Empty;
                    string temp = string.Empty;
                    Cursor.Current = Cursors.WaitCursor;
                    using (StreamReader sr = new StreamReader(fname, System.Text.Encoding.GetEncoding(1253)))
                    {
                        while ((line = sr.ReadLine()) != null)
                        {
                            temp = temp + line + "\r\n";
                        }
                        bufs = temp.Substring(0, temp.Length - 2);
                        //fftxtSource.Text = fftxtSource.Text.Replace("\t", "      ");
                    }
                    fftxtSource.Text = bufs;
                    frmLionAsm.ActiveForm.Text = "frmLionAsm - " + fname;
                    // oldtext[0] = fftxtSource.Text;
                    //try
                    //{
                    //    fftxtSource.SuspendLayout();
                    //}
                    //catch { }
                    //MakeColorSyntaxForAll();
                    //try
                    //{
                    //    fftxtSource.ResumeLayout();
                    //}
                    //catch
                    //{
                    //}
                    changed = false;
                    Cursor.Current = Cursors.Default;
                }
            }
            exith = false;
        }



        private void source_TextChanged(object sender, EventArgs e)
        {
            if (fftxtSource.UndoActionName == "Typing")
            {
                //fftxtSource.Undo();
                //int i;
                //for (i = un - 1; i > 0; i--)
                //{
                //    oldtext[i] = oldtext[i - 1];
                //}
                //oldtext[0] = fftxtSource.Text;
                //fftxtSource.Redo();
                changed = true;
                MakeColorSyntaxForCurrentLine();
                //SLine=fftxtSource
            }

        }

        private void closeToolStripMenuItem_Click(object sender, EventArgs e)
        {
            //SAVE
            DialogResult d;
            saveFileDialog1.FileName = fname; // Path.GetFileName(fname); 
            d = saveFileDialog1.ShowDialog();
            if (d == DialogResult.OK)
            {
                fname = saveFileDialog1.FileName;
                using (StreamWriter sw = new StreamWriter(fname, false, System.Text.Encoding.GetEncoding(1253)))
                {
                    foreach (string cs in fftxtSource.Lines)
                    {
                        sw.WriteLine(cs);
                    }
                }
                //changed = false;
                frmLionAsm.ActiveForm.Text = "frmLionAsm - " + fname;
                changed = false;
            }
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DialogResult res;
            if (changed) res = MessageBox.Show("Text has changed and not saved, are you sure", "Open", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
            else res = DialogResult.Yes;
            if (res == DialogResult.Yes)
            {
                changed = false;
                this.Close();
            }
        }

        private void undoToolStripMenuItem_Click(object sender, EventArgs e)
        {
            //if (oldtext[0] != null && oldtext[0].Trim() != string.Empty && oldtext[0] != fftxtSource.Text)
            //{
            //    exith = true;
            //    Flickerfreertf._Paint = false;
            //    int ss = fftxtSource.SelectionStart;
            //    fftxtSource.Text = oldtext[0];
            //    int i;
            //    for (i = 0; i < un - 1; i++)
            //    {
            //        oldtext[i] = oldtext[i + 1];
            //    }
            //    if (ss < fftxtSource.Text.Length) fftxtSource.SelectionStart = ss;
            //    Flickerfreertf._Paint = true;
            //    exith = false;
            //    MakeColorSyntaxForAll();
            //}
        }

        private void buildObjectToolStripMenuItem_Click(object sender, EventArgs e)
        {
            par.parse();
        }

        private void VHDL_TextChanged(object sender, EventArgs e)
        {

        }

        private void openToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DialogResult res;
            if (changed) res = MessageBox.Show("Text has changed and not saved, are you sure", "NEW", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
            else res = DialogResult.Yes;
            if (res == DialogResult.Yes)
            {
                fftxtSource.Text = "        ORG     8192        ; RAM start";
                MakeColorSyntaxForAll();
                changed = false;

            }
        }

        private void source_SelectionChanged(object sender, EventArgs e)
        {
            SLine.Text = "Line:" + Convert.ToString(fftxtSource.GetLineFromCharIndex(fftxtSource.SelectionStart) + 1);
        }

        private void statusStrip1_ItemClicked(object sender, ToolStripItemClickedEventArgs e)
        {

        }

        private void printToolStripMenuItem_Click(object sender, EventArgs e)
        {

        }

        private void printDocument1_PrintPage(object sender, PrintPageEventArgs e)
        {

        }

        private void toolStripMenuItem1_Click(object sender, EventArgs e)
        {

        }

        private void menuStrip1_ItemClicked(object sender, ToolStripItemClickedEventArgs e)
        {

        }

        private void findToolStripMenuItem_Click(object sender, EventArgs e)
        {

            fftxtSource.Find(string.Empty);
        }

        private void source_KeyPress(object sender, KeyPressEventArgs e)
        {

        }

        private void btnFind_Click(object sender, EventArgs e)
        {
            try
            {
                fftxtSource.SelectionStart = fftxtSource.Find(txtSearch.Text, fstart, fftxtSource.TextLength - 1, 0);
                fftxtSource.SelectionLength = txtSearch.Text.Length - 1;
                fstart = fftxtSource.SelectionStart + 1;
                fftxtSource.ScrollToCaret();
            }
            catch
            {
                fftxtSource.SelectionStart = 0;
                fftxtSource.SelectionLength = 0;
                fftxtSource.ScrollToCaret();
                fstart = 1;
            }
        }

        private void btnU_Click(object sender, EventArgs e)
        {
            if (txtSearch.CanUndo == true)
            {
                // Undo the last operation.
                txtSearch.Undo();
                // Clear the undo buffer to prevent last action from being redone.
                txtSearch.ClearUndo();
            }
        }

        private void btnR_Click(object sender, EventArgs e)
        {
            fftxtSource.Redo();
        }

        private void txtSearch_TextChanged(object sender, EventArgs e)
        {

        }

        private void txtSearch_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == 13)
            {
                try
                {
                    fftxtSource.SelectionStart = fftxtSource.Find(txtSearch.Text, fstart, fftxtSource.TextLength - 1, 0);
                    fftxtSource.SelectionLength = txtSearch.Text.Length - 1;
                    fstart = fftxtSource.SelectionStart + 1;
                    fftxtSource.ScrollToCaret();
                }
                catch
                {
                    fftxtSource.SelectionStart = 0;
                    fftxtSource.SelectionLength = 0;
                    fftxtSource.ScrollToCaret();
                    fstart = 1;
                }
            }
        }

        private void Lionasm_FormClosing(object sender, FormClosingEventArgs e)
        {
            DialogResult res;
            if (changed) res = MessageBox.Show("Text has changed and not saved, are you sure", "Open", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
            else res = DialogResult.Yes;
            if (res == DialogResult.No)
            {
                e.Cancel = true;
            }
        }

        private void btnCopy_Click(object sender, EventArgs e)
        {
            VHDL.SelectAll();
            VHDL.Refresh();
            VHDL.Copy();
        }

        private void btnAssemble_Click(object sender, EventArgs e)
        {
            par.parse();
        }

        private void btnPaint_Click(object sender, EventArgs e)
        {
            Cursor.Current = Cursors.WaitCursor;
            try
            {
                fftxtSource.SuspendLayout();
            }
            catch { }
            MakeColorSyntaxForAll();
            try
            {
                fftxtSource.ResumeLayout();
            }
            catch
            {
            }
            Cursor.Current = Cursors.Default;
        }

        private void SSend_Click(object sender, EventArgs e)
        {
            BinaryReader br = null;
            byte[] bt = new byte[2];
            try
            {
                br = new BinaryReader(new FileStream(fname + ".bin", FileMode.Open));
            }
            catch (IOException ex)
            {
                errorbox.Text += "Can't open Binary File! \r\n";
                errorbox.Text += ex.Message + "\r\n";
                return;
            }
            try
            {
                serialPort1.Open();
            }
            catch (IOException ex)
            {
                errorbox.Text += "Can't open Serial Port \r\n";
                errorbox.Text += ex.Message + "\r\n";
                return;
            }
            serialPort1.Write("GCODE BTOP+2,"+BinSize.Text);
            bt[0] = 13;  serialPort1.Write(bt, 0, 1);
            for (int j = 0; j < 16; j++)  for (int i = 0; i < 300000; i++) { int k = i * 3; }
            while (true)
            {
                try
                {
                    bt[0] = br.ReadByte();
                }
                catch (IOException ex)
                { break; }
                serialPort1.Write(bt,0,1);
                for (int i = 0; i < 500000; i++) { int k = i * 3; }
            }
            br.Close();
            serialPort1.Close();
        }


        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            serialPort1.PortName = comboBox1.Text;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            byte[] bt = new byte[2];
            try
            {
                serialPort1.Open();
            }
            catch (IOException ex)
            {
                errorbox.Text += "Can't open Serial Port \r\n";
                errorbox.Text += ex.Message + "\r\n";
                return;
            }
            serialPort1.Write("RCODE BTOP+2");
            for (int i = 0; i < 500000; i++) { int k = i * 3; }
            bt[0] = 13; serialPort1.Write(bt, 0, 1);
            serialPort1.Close();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            byte[] bt = new byte[2];
            try
            {
                serialPort1.Open();
            }
            catch (IOException ex)
            {
                errorbox.Text += "Can't open Serial Port \r\n";
                errorbox.Text += ex.Message + "\r\n";
                return;
            }
            serialPort1.Write(scmnd.Text);
            for (int i = 0; i < 500000; i++) { int k = i * 3; }
            bt[0] = 13; serialPort1.Write(bt, 0, 1);
            serialPort1.Close();
        }
    }
}
