using System;
using System.Drawing;
using System.Windows.Forms;
using System.Drawing.Printing;
using System.IO;
using Glos;

namespace WindowsFormsApplication1
{
    public partial class Lionasm : Form
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
            int CurrentSelectionStart = source.SelectionStart;
            int CurrentSelectionLength = source.SelectionLength;
            int pos = 0;
            int pos2 = source.Text.Length - 1;
            source.SelectAll();
            source.SelectionColor = Color.Black;
            int l = pos;
            Color c;
            string ctok = "";
            while (l < pos2)
            {
                if ("ABCDEFGHIJKLMNOPQRSTVUWXYZ01234567890_.".IndexOf(source.Text.ToUpper()[l]) != -1)
                {
                    ctok = ctok + source.Text[l];
                    l++;
                }
                else
                {
                    if (ctok != "")
                    {
                        ctok = ctok.ToUpper();
                        if (par.clist.ContainsKey(ctok.ToUpper()))
                        {
                            c = (Color)par.clist[ctok];
                            source.Select(l - ctok.Length, ctok.Length);
                            source.SelectionColor = c;
                            //source.ClearUndo();
                        }
                        ctok = "";
                    }
                    if (source.Text[l] == '\'')
                    {
                        l++;
                        while (l < pos2 && source.Text[l] != '\'' && source.Text[l] != '\n') l++;
                    }
                    if (source.Text[l] == ';')
                    {
                        int ss = l;
                        source.SelectionStart = ss;
                        l++;
                        while (l < pos2 && source.Text[l] != '\n') l++;
                        source.SelectionLength = l - ss;
                        source.SelectionColor = Color.Green;
                    }
                    l++;
                }
            }
            if (ctok != "")
            {
                ctok = ctok.ToUpper();
                if (par.clist.ContainsKey(ctok))
                {
                    c = (Color)par.clist[ctok];
                    source.Select(l - ctok.Length, ctok.Length);
                    source.SelectionColor = c;
                }
                ctok = "";
            }
            //  Restore Cursor
            if (CurrentSelectionStart >= 0)
                source.Select(CurrentSelectionStart,
                    CurrentSelectionLength);
            Flickerfreertf._Paint = true;
            exith = false;
        }

        public void MakeColorSyntaxForCurrentLine()
        {
            //  Store current cursor position

            if (exith || source.Text == "") return;
            Flickerfreertf._Paint = false;
            int CurrentSelectionStart = source.SelectionStart;
            int CurrentSelectionLength = source.SelectionLength;

            // find start of line
            int pos = CurrentSelectionStart;

            while ((pos > 0) && (source.Text[pos - 1] != '\n'))
                pos--;
            ;
            // find end of line
            int pos2 = CurrentSelectionStart;
            while ((pos2 < source.Text.Length) && (source.Text[pos2] != '\n')) pos2++;
            source.SelectionStart = pos;
            source.SelectionLength = pos2 - pos;
            string st = source.Text.Substring(pos, pos2 - pos).TrimStart();
            if (pos < source.Text.Length && st.StartsWith(";"))
            {
                source.SelectionColor = Color.Green;
                Flickerfreertf._Paint = true;
                if (CurrentSelectionStart >= 0)
                    source.Select(CurrentSelectionStart,
                        CurrentSelectionLength);
                return;
            }
            else source.SelectionColor = Color.Black;
            int l = pos;
            Color c;
            string ctok = "";
            while (l < pos2)
            {
                if ("ABCDEFGHIJKLMNOPQRSTVUWXYZ0123456789._".IndexOf(source.Text.ToUpper()[l]) != -1)
                {
                    ctok = ctok + source.Text[l];
                }
                else
                {
                    if (ctok != "")
                    {
                        ctok = ctok.ToUpper();
                        if (par.clist.ContainsKey(ctok))
                        {
                            c = (Color)par.clist[ctok];
                            source.Select(l - ctok.Length, ctok.Length);
                            source.SelectionColor = c;
                        }
                        ctok = "";
                    }
                    if (source.Text[l] == '\'')
                    {
                        l++;
                        while (l < pos2 && source.Text[l] != '\'') l++;
                    }
                }
                l++;
            }
            if (ctok != "")
            {
                ctok = ctok.ToUpper();
                if (par.clist.ContainsKey(ctok))
                {
                    c = (Color)par.clist[ctok];
                    source.Select(l - ctok.Length, ctok.Length);
                    source.SelectionColor = c;
                }
                ctok = "";
            }
            //  Restore Cursor
            if (CurrentSelectionStart >= 0)
                source.Select(CurrentSelectionStart,
                                        CurrentSelectionLength);
            Flickerfreertf._Paint = true;
        }

        public void goto_line_o(int l)
        {
            int pos = 0, line = 0;
            while (pos < source.Text.Length && line != l)
            {
                if (source.Text[pos] == '\n') line++;
                pos++;
            }
            if (pos < source.Text.Length && line == l)
            {
                source.SelectionStart = pos;
                source.SelectionLength = 1;
            }
        }

        public void goto_line(int st)
        {
            int l, i, le;
            l = 0;
            i = 0;
            le = source.Text.Length;
            do
            {
                if (i < le) i = source.Text.IndexOf("\n", i + 1);
                else i = -1;
                l++;
            } while (l < st && i != -1);
            if (i < le && l == st)
            {
                source.SelectionStart = i + 1;
                source.SelectionLength = 1;
            }
        }

        int find_line(int st)
        {
            int l, i, le;
            l = 0;
            i = 0;
            le = source.Text.Length;
            do
            {
                if (i < le) i = source.Text.IndexOf("\n", i + 1);
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
            int pos = source.SelectionStart;
            while ((pos > 0) && (source.Text[pos - 1] != '\n')) pos--;
            // find end of line
            int pos2 = source.SelectionStart;
            while ((pos2 < source.Text.Length) && (source.Text[pos2] != '\n')) pos2++;
            source.SelectionStart = pos;
            source.SelectionLength = pos2 - pos;
            source.SelectionColor = c;
            Flickerfreertf._Paint = true;
            exith = false;
        }

        public Lionasm(string[] args)
        {
            
            InitializeComponent();
            if (args.Length > 0)
            {
                fname = args[0];
                if (args.Length > 0)
            {
                fname = args[0]; string line, bufs;
                    source.Text = "";
                    bufs = "";
                    string temp = "";

                    using (StreamReader sr = new StreamReader(fname, System.Text.Encoding.GetEncoding(1253)))
                    {
                        while ((line = sr.ReadLine()) != null)
                        {
                            temp = temp + line + "\r\n";
                        }
                        bufs = temp.Substring(0, temp.Length - 2);
                        //source.Text = source.Text.Replace("\t", "      ");
                    }
                    source.Text = bufs;
                    //Lionasm.ActiveForm.Text = "Lionasm - " + fname;
                    //try
                    //{
                    //    source.SuspendLayout();
                    //}
                    //catch { }
                    //MakeColorSyntaxForAll();
                    //try
                    //{
                    //    source.ResumeLayout();
                    //}
                    //catch
                    //{
                    //}
                    changed = false;
            }
            }
        }

        private void Lionasm_Load(object sender, EventArgs e)
        {
            par = new aparser(this);
        }



        private void openToolStripMenuItem1_Click(object sender, EventArgs e)
        {
            DialogResult d;
            string line,bufs;
            DialogResult res;
            exith = true;
            if (changed) res = MessageBox.Show("Text has changed and not saved, are you sure", "Open", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
            else res = DialogResult.Yes;
            if (res == DialogResult.Yes)
            {
                openFileDialog1.FileName = fname;
                d = openFileDialog1.ShowDialog();
                if (d == DialogResult.OK)
                {
                    fname = openFileDialog1.FileName;
                    source.Text = "";
                    bufs = "";
                    string temp = "";
                    Cursor.Current = Cursors.WaitCursor;
                    using (StreamReader sr = new StreamReader(fname, System.Text.Encoding.GetEncoding(1253)))
                    {
                        while ((line = sr.ReadLine()) != null)
                        {
                            temp = temp + line + "\r\n";
                        }
                        bufs = temp.Substring(0, temp.Length - 2);
                        //source.Text = source.Text.Replace("\t", "      ");
                    }
                    source.Text = bufs;
                    Lionasm.ActiveForm.Text = "Lionasm - " + fname;
                    // oldtext[0] = source.Text;
                    //try
                    //{
                    //    source.SuspendLayout();
                    //}
                    //catch { }
                    //MakeColorSyntaxForAll();
                    //try
                    //{
                    //    source.ResumeLayout();
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
            if (source.UndoActionName == "Typing")
            {
                //source.Undo();
                //int i;
                //for (i = un - 1; i > 0; i--)
                //{
                //    oldtext[i] = oldtext[i - 1];
                //}
                //oldtext[0] = source.Text;
                //source.Redo();
                changed = true;
                MakeColorSyntaxForCurrentLine();
                //SLine=source
            }
            
        }

        private void closeToolStripMenuItem_Click(object sender, EventArgs e)
        {
            //SAVE
            DialogResult d;
            saveFileDialog1.FileName = fname;
            d = saveFileDialog1.ShowDialog();
            if (d == DialogResult.OK)
            {
                fname = saveFileDialog1.FileName;
                using (StreamWriter sw = new StreamWriter(fname, false, System.Text.Encoding.GetEncoding(1253)))
                {
                    foreach (string cs in source.Lines)
                    {
                        sw.WriteLine(cs);
                    }
                }
                //changed = false;
                Lionasm.ActiveForm.Text = "Lionasm - " + fname;
                changed = false;
            }
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DialogResult  res;
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
            //if (oldtext[0] != null && oldtext[0].Trim() != "" && oldtext[0] != source.Text)
            //{
            //    exith = true;
            //    Flickerfreertf._Paint = false;
            //    int ss = source.SelectionStart;
            //    source.Text = oldtext[0];
            //    int i;
            //    for (i = 0; i < un - 1; i++)
            //    {
            //        oldtext[i] = oldtext[i + 1];
            //    }
            //    if (ss < source.Text.Length) source.SelectionStart = ss;
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
                source.Text = "        ORG     8192        ; RAM start";
                MakeColorSyntaxForAll();
                changed = false;
                
            }
        }

        private void source_SelectionChanged(object sender, EventArgs e)
        {
            SLine.Text = "Line:" + Convert.ToString(source.GetLineFromCharIndex(source.SelectionStart) + 1);
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
            
            source.Find("");
        }

        private void source_KeyPress(object sender, KeyPressEventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {
            try
            {
                source.SelectionStart = source.Find(textBox1.Text, fstart, source.TextLength - 1, 0);
                source.SelectionLength = textBox1.Text.Length - 1;
                fstart = source.SelectionStart + 1;
                source.ScrollToCaret();
            }
            catch
            {
                source.SelectionStart = 0;
                source.SelectionLength = 0;
                source.ScrollToCaret();
                fstart = 1;
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            if (textBox1.CanUndo == true)
            {
                // Undo the last operation.
                textBox1.Undo();
                // Clear the undo buffer to prevent last action from being redone.
                textBox1.ClearUndo();
            }
        }

        private void button3_Click(object sender, EventArgs e)
        {
            source.Redo();
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox1_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == 13)
            {
                try
                {
                    source.SelectionStart = source.Find(textBox1.Text, fstart, source.TextLength - 1, 0);
                    source.SelectionLength = textBox1.Text.Length - 1;
                    fstart = source.SelectionStart + 1;
                    source.ScrollToCaret();
                }
                catch
                {
                    source.SelectionStart = 0;
                    source.SelectionLength = 0;
                    source.ScrollToCaret();
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

        private void button4_Click(object sender, EventArgs e)
        {
            VHDL.SelectAll();
            VHDL.Refresh();
            VHDL.Copy();
        }

        private void button5_Click(object sender, EventArgs e)
        {
            par.parse();
        }

        private void button6_Click(object sender, EventArgs e)
        {
            Cursor.Current = Cursors.WaitCursor;
            try
            {
                source.SuspendLayout();
            }
            catch { }
            MakeColorSyntaxForAll();
            try
            {
                source.ResumeLayout();
            }
            catch
            {
            }
            Cursor.Current = Cursors.Default;
        }

    }
}
