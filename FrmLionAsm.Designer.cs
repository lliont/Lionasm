namespace Lion_assembler
{
    partial class frmLionAsm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmLionAsm));
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.openToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.openToolStripMenuItem1 = new System.Windows.Forms.ToolStripMenuItem();
            this.closeToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.printToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.exitToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.editToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.Displv = new System.Windows.Forms.ToolStripMenuItem();
            this.createBinaryToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.buildToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.buildObjectToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.helpToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.infoToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.aboutToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
            this.saveFileDialog1 = new System.Windows.Forms.SaveFileDialog();
            this.errorbox = new System.Windows.Forms.TextBox();
            this.VHDL = new System.Windows.Forms.TextBox();
            this.statusStrip1 = new System.Windows.Forms.StatusStrip();
            this.SLine = new System.Windows.Forms.ToolStripStatusLabel();
            this.printDocument1 = new System.Drawing.Printing.PrintDocument();
            this.printDialog1 = new System.Windows.Forms.PrintDialog();
            this.txtSearch = new System.Windows.Forms.TextBox();
            this.btnFind = new System.Windows.Forms.Button();
            this.btnU = new System.Windows.Forms.Button();
            this.btnR = new System.Windows.Forms.Button();
            this.btnCopy = new System.Windows.Forms.Button();
            this.btnAssemble = new System.Windows.Forms.Button();
            this.btnPaint = new System.Windows.Forms.Button();
            this.fftxtSource = new Lion_assembler.Flickerfreertf();
            this.menuStrip1.SuspendLayout();
            this.statusStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // menuStrip1
            // 
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem,
            this.editToolStripMenuItem,
            this.buildToolStripMenuItem,
            this.helpToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(1126, 24);
            this.menuStrip1.TabIndex = 1;
            this.menuStrip1.Text = "menuStrip1";
            this.menuStrip1.ItemClicked += new System.Windows.Forms.ToolStripItemClickedEventHandler(this.menuStrip1_ItemClicked);
            // 
            // fileToolStripMenuItem
            // 
            this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.openToolStripMenuItem,
            this.openToolStripMenuItem1,
            this.closeToolStripMenuItem,
            this.printToolStripMenuItem,
            this.exitToolStripMenuItem});
            this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
            this.fileToolStripMenuItem.Size = new System.Drawing.Size(37, 20);
            this.fileToolStripMenuItem.Text = "&File";
            // 
            // openToolStripMenuItem
            // 
            this.openToolStripMenuItem.Name = "openToolStripMenuItem";
            this.openToolStripMenuItem.Size = new System.Drawing.Size(103, 22);
            this.openToolStripMenuItem.Text = "New";
            this.openToolStripMenuItem.Click += new System.EventHandler(this.openToolStripMenuItem_Click);
            // 
            // openToolStripMenuItem1
            // 
            this.openToolStripMenuItem1.Name = "openToolStripMenuItem1";
            this.openToolStripMenuItem1.Size = new System.Drawing.Size(103, 22);
            this.openToolStripMenuItem1.Text = "Open";
            this.openToolStripMenuItem1.Click += new System.EventHandler(this.openToolStripMenuItem1_Click);
            // 
            // closeToolStripMenuItem
            // 
            this.closeToolStripMenuItem.Name = "closeToolStripMenuItem";
            this.closeToolStripMenuItem.Size = new System.Drawing.Size(103, 22);
            this.closeToolStripMenuItem.Text = "Save";
            this.closeToolStripMenuItem.Click += new System.EventHandler(this.closeToolStripMenuItem_Click);
            // 
            // printToolStripMenuItem
            // 
            this.printToolStripMenuItem.Name = "printToolStripMenuItem";
            this.printToolStripMenuItem.Size = new System.Drawing.Size(103, 22);
            this.printToolStripMenuItem.Text = "Print";
            this.printToolStripMenuItem.Click += new System.EventHandler(this.printToolStripMenuItem_Click);
            // 
            // exitToolStripMenuItem
            // 
            this.exitToolStripMenuItem.Name = "exitToolStripMenuItem";
            this.exitToolStripMenuItem.Size = new System.Drawing.Size(103, 22);
            this.exitToolStripMenuItem.Text = "Exit";
            this.exitToolStripMenuItem.Click += new System.EventHandler(this.exitToolStripMenuItem_Click);
            // 
            // editToolStripMenuItem
            // 
            this.editToolStripMenuItem.CheckOnClick = true;
            this.editToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.Displv,
            this.createBinaryToolStripMenuItem});
            this.editToolStripMenuItem.Name = "editToolStripMenuItem";
            this.editToolStripMenuItem.Size = new System.Drawing.Size(39, 20);
            this.editToolStripMenuItem.Text = "Edit";
            // 
            // Displv
            // 
            this.Displv.CheckOnClick = true;
            this.Displv.Name = "Displv";
            this.Displv.Size = new System.Drawing.Size(176, 22);
            this.Displv.Text = "List labels-variables";
            this.Displv.Click += new System.EventHandler(this.toolStripMenuItem1_Click);
            // 
            // createBinaryToolStripMenuItem
            // 
            this.createBinaryToolStripMenuItem.Checked = true;
            this.createBinaryToolStripMenuItem.CheckState = System.Windows.Forms.CheckState.Checked;
            this.createBinaryToolStripMenuItem.Name = "createBinaryToolStripMenuItem";
            this.createBinaryToolStripMenuItem.Size = new System.Drawing.Size(176, 22);
            this.createBinaryToolStripMenuItem.Text = "Create Binary";
            // 
            // buildToolStripMenuItem
            // 
            this.buildToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.buildObjectToolStripMenuItem});
            this.buildToolStripMenuItem.Name = "buildToolStripMenuItem";
            this.buildToolStripMenuItem.Size = new System.Drawing.Size(46, 20);
            this.buildToolStripMenuItem.Text = "Build";
            // 
            // buildObjectToolStripMenuItem
            // 
            this.buildObjectToolStripMenuItem.Name = "buildObjectToolStripMenuItem";
            this.buildObjectToolStripMenuItem.Size = new System.Drawing.Size(125, 22);
            this.buildObjectToolStripMenuItem.Text = "Assemble";
            this.buildObjectToolStripMenuItem.Click += new System.EventHandler(this.buildObjectToolStripMenuItem_Click);
            // 
            // helpToolStripMenuItem
            // 
            this.helpToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.infoToolStripMenuItem,
            this.aboutToolStripMenuItem});
            this.helpToolStripMenuItem.Name = "helpToolStripMenuItem";
            this.helpToolStripMenuItem.Size = new System.Drawing.Size(44, 20);
            this.helpToolStripMenuItem.Text = "Help";
            // 
            // infoToolStripMenuItem
            // 
            this.infoToolStripMenuItem.Name = "infoToolStripMenuItem";
            this.infoToolStripMenuItem.Size = new System.Drawing.Size(107, 22);
            this.infoToolStripMenuItem.Text = "Info";
            // 
            // aboutToolStripMenuItem
            // 
            this.aboutToolStripMenuItem.Name = "aboutToolStripMenuItem";
            this.aboutToolStripMenuItem.Size = new System.Drawing.Size(107, 22);
            this.aboutToolStripMenuItem.Text = "About";
            // 
            // openFileDialog1
            // 
            this.openFileDialog1.DefaultExt = "asm";
            this.openFileDialog1.FileName = "openFileDialog1";
            this.openFileDialog1.Filter = "asm|*.asm|All|*.*";
            // 
            // saveFileDialog1
            // 
            this.saveFileDialog1.DefaultExt = "asm";
            this.saveFileDialog1.Filter = "asm|*.asm|All|*.*";
            // 
            // errorbox
            // 
            this.errorbox.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.errorbox.BackColor = System.Drawing.SystemColors.Info;
            this.errorbox.Font = new System.Drawing.Font("Courier New", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(161)));
            this.errorbox.Location = new System.Drawing.Point(0, 631);
            this.errorbox.Multiline = true;
            this.errorbox.Name = "errorbox";
            this.errorbox.ReadOnly = true;
            this.errorbox.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.errorbox.Size = new System.Drawing.Size(640, 94);
            this.errorbox.TabIndex = 2;
            // 
            // VHDL
            // 
            this.VHDL.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.VHDL.CausesValidation = false;
            this.VHDL.Font = new System.Drawing.Font("Courier New", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(161)));
            this.VHDL.Location = new System.Drawing.Point(646, 33);
            this.VHDL.MaxLength = 0;
            this.VHDL.Multiline = true;
            this.VHDL.Name = "VHDL";
            this.VHDL.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.VHDL.Size = new System.Drawing.Size(480, 723);
            this.VHDL.TabIndex = 4;
            this.VHDL.WordWrap = false;
            this.VHDL.TextChanged += new System.EventHandler(this.VHDL_TextChanged);
            // 
            // statusStrip1
            // 
            this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.SLine});
            this.statusStrip1.Location = new System.Drawing.Point(0, 728);
            this.statusStrip1.Name = "statusStrip1";
            this.statusStrip1.Size = new System.Drawing.Size(1126, 22);
            this.statusStrip1.TabIndex = 5;
            this.statusStrip1.Text = "statusStrip1";
            this.statusStrip1.ItemClicked += new System.Windows.Forms.ToolStripItemClickedEventHandler(this.statusStrip1_ItemClicked);
            // 
            // SLine
            // 
            this.SLine.Name = "SLine";
            this.SLine.Size = new System.Drawing.Size(35, 17);
            this.SLine.Text = "Line: ";
            // 
            // printDocument1
            // 
            this.printDocument1.PrintPage += new System.Drawing.Printing.PrintPageEventHandler(this.printDocument1_PrintPage);
            // 
            // printDialog1
            // 
            this.printDialog1.Document = this.printDocument1;
            this.printDialog1.UseEXDialog = true;
            // 
            // txtSearch
            // 
            this.txtSearch.Location = new System.Drawing.Point(263, 8);
            this.txtSearch.Name = "txtSearch";
            this.txtSearch.Size = new System.Drawing.Size(143, 18);
            this.txtSearch.TabIndex = 6;
            this.txtSearch.TextChanged += new System.EventHandler(this.txtSearch_TextChanged);
            this.txtSearch.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtSearch_KeyPress);
            // 
            // btnFind
            // 
            this.btnFind.Location = new System.Drawing.Point(213, 5);
            this.btnFind.Name = "btnFind";
            this.btnFind.Size = new System.Drawing.Size(44, 21);
            this.btnFind.TabIndex = 7;
            this.btnFind.Text = "Find";
            this.btnFind.UseVisualStyleBackColor = true;
            this.btnFind.Click += new System.EventHandler(this.btnFind_Click);
            // 
            // btnU
            // 
            this.btnU.Location = new System.Drawing.Point(426, 5);
            this.btnU.Name = "btnU";
            this.btnU.Size = new System.Drawing.Size(25, 21);
            this.btnU.TabIndex = 8;
            this.btnU.Text = "U";
            this.btnU.UseVisualStyleBackColor = true;
            this.btnU.Visible = false;
            this.btnU.Click += new System.EventHandler(this.btnU_Click);
            // 
            // btnR
            // 
            this.btnR.Location = new System.Drawing.Point(457, 5);
            this.btnR.Name = "btnR";
            this.btnR.Size = new System.Drawing.Size(25, 21);
            this.btnR.TabIndex = 9;
            this.btnR.Text = "R";
            this.btnR.UseVisualStyleBackColor = true;
            this.btnR.Visible = false;
            this.btnR.Click += new System.EventHandler(this.btnR_Click);
            // 
            // btnCopy
            // 
            this.btnCopy.Location = new System.Drawing.Point(646, 5);
            this.btnCopy.Name = "btnCopy";
            this.btnCopy.Size = new System.Drawing.Size(71, 21);
            this.btnCopy.TabIndex = 10;
            this.btnCopy.Text = "Copy VHDL";
            this.btnCopy.UseVisualStyleBackColor = true;
            this.btnCopy.Click += new System.EventHandler(this.btnCopy_Click);
            // 
            // btnAssemble
            // 
            this.btnAssemble.Location = new System.Drawing.Point(488, 5);
            this.btnAssemble.Name = "btnAssemble";
            this.btnAssemble.Size = new System.Drawing.Size(60, 21);
            this.btnAssemble.TabIndex = 11;
            this.btnAssemble.Text = "Assemble";
            this.btnAssemble.UseVisualStyleBackColor = true;
            this.btnAssemble.Click += new System.EventHandler(this.btnAssemble_Click);
            // 
            // btnPaint
            // 
            this.btnPaint.Location = new System.Drawing.Point(554, 5);
            this.btnPaint.Name = "btnPaint";
            this.btnPaint.Size = new System.Drawing.Size(74, 21);
            this.btnPaint.TabIndex = 12;
            this.btnPaint.Text = "Paint Source";
            this.btnPaint.UseVisualStyleBackColor = true;
            this.btnPaint.Click += new System.EventHandler(this.btnPaint_Click);
            // 
            // fftxtSource
            // 
            this.fftxtSource.AcceptsTab = true;
            this.fftxtSource.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.fftxtSource.AutoWordSelection = true;
            this.fftxtSource.CausesValidation = false;
            this.fftxtSource.DetectUrls = false;
            this.fftxtSource.EnableAutoDragDrop = true;
            this.fftxtSource.Font = new System.Drawing.Font("Courier New", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(161)));
            this.fftxtSource.Location = new System.Drawing.Point(0, 32);
            this.fftxtSource.MaxLength = 0;
            this.fftxtSource.Name = "fftxtSource";
            this.fftxtSource.Size = new System.Drawing.Size(640, 600);
            this.fftxtSource.TabIndex = 0;
            this.fftxtSource.Text = resources.GetString("fftxtSource.Text");
            this.fftxtSource.WordWrap = false;
            this.fftxtSource.SelectionChanged += new System.EventHandler(this.source_SelectionChanged);
            this.fftxtSource.TextChanged += new System.EventHandler(this.source_TextChanged);
            this.fftxtSource.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.source_KeyPress);
            // 
            // frmLionAsm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.ClientSize = new System.Drawing.Size(1126, 750);
            this.Controls.Add(this.btnPaint);
            this.Controls.Add(this.btnAssemble);
            this.Controls.Add(this.btnCopy);
            this.Controls.Add(this.btnR);
            this.Controls.Add(this.btnU);
            this.Controls.Add(this.btnFind);
            this.Controls.Add(this.txtSearch);
            this.Controls.Add(this.statusStrip1);
            this.Controls.Add(this.VHDL);
            this.Controls.Add(this.errorbox);
            this.Controls.Add(this.fftxtSource);
            this.Controls.Add(this.menuStrip1);
            this.Font = new System.Drawing.Font("Microsoft Sans Serif", 6.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(161)));
            this.Location = new System.Drawing.Point(10, 10);
            this.MainMenuStrip = this.menuStrip1;
            this.Name = "frmLionAsm";
            this.SizeGripStyle = System.Windows.Forms.SizeGripStyle.Show;
            this.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            this.Text = "frmLionAsm";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.Lionasm_FormClosing);
            this.Load += new System.EventHandler(this.Lionasm_Load);
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.statusStrip1.ResumeLayout(false);
            this.statusStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        public Lion_assembler.Flickerfreertf fftxtSource;
        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem openToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem openToolStripMenuItem1;
        private System.Windows.Forms.ToolStripMenuItem closeToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem printToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem exitToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem buildToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem buildObjectToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem helpToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem infoToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem aboutToolStripMenuItem;
        private System.Windows.Forms.OpenFileDialog openFileDialog1;
        private System.Windows.Forms.SaveFileDialog saveFileDialog1;
        public System.Windows.Forms.TextBox errorbox;
        private System.Windows.Forms.ToolStripMenuItem editToolStripMenuItem;
        public System.Windows.Forms.TextBox VHDL;
        private System.Windows.Forms.StatusStrip statusStrip1;
        private System.Windows.Forms.ToolStripStatusLabel SLine;
        private System.Drawing.Printing.PrintDocument printDocument1;
        private System.Windows.Forms.PrintDialog printDialog1;
        public System.Windows.Forms.ToolStripMenuItem Displv;
        private System.Windows.Forms.TextBox txtSearch;
        private System.Windows.Forms.Button btnFind;
        private System.Windows.Forms.Button btnU;
        private System.Windows.Forms.Button btnR;
        private System.Windows.Forms.Button btnCopy;
        private System.Windows.Forms.Button btnAssemble;
        private System.Windows.Forms.Button btnPaint;
        private System.Windows.Forms.ToolStripMenuItem createBinaryToolStripMenuItem;
    }
}

