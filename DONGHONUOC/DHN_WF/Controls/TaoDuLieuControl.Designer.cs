namespace DHN_WF.Controls
{
    partial class TaoDuLieuControl
    {
        private System.ComponentModel.IContainer components = null;
        protected override void Dispose(bool disposing)
        {
            if (disposing && components != null) components.Dispose();
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            this.panelTop = new Panel();
            this.lblDuongDan = new Label();
            this.txtFilePath = new TextBox();
            this.btnChonFile = new DHN_WF.CustomUI.ModernButton();
            this.btnThemFile = new DHN_WF.CustomUI.ModernButton();
            this.lblUploadMsg = new Label();
            this.grpThongTin = new GroupBox();
            this.panelFilter = new Panel();
            this.lblTheoKy = new Label();
            this.cboKy = new ComboBox();
            this.btnXem = new DHN_WF.CustomUI.ModernButton();
            this.lblThongKe = new Label();
            this.dgvData = new DataGridView();
            this.panelTop.SuspendLayout();
            this.grpThongTin.SuspendLayout();
            this.panelFilter.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)this.dgvData).BeginInit();
            this.SuspendLayout();

            // panelTop
            this.panelTop.Dock = DockStyle.Top;
            this.panelTop.Height = 60;
            this.panelTop.Padding = new Padding(10);
            this.panelTop.Controls.Add(this.lblDuongDan);
            this.panelTop.Controls.Add(this.txtFilePath);
            this.panelTop.Controls.Add(this.btnChonFile);
            this.panelTop.Controls.Add(this.btnThemFile);

            // lblDuongDan
            this.lblDuongDan.Text = "Đường Dẫn:";
            this.lblDuongDan.Font = new Font("Segoe UI", 9, FontStyle.Regular);
            this.lblDuongDan.ForeColor = Color.FromArgb(55, 65, 81);
            this.lblDuongDan.AutoSize = false;
            this.lblDuongDan.Size = new Size(90, 30);
            this.lblDuongDan.Location = new Point(0, 3);
            this.lblDuongDan.TextAlign = ContentAlignment.MiddleLeft;

            // txtFilePath
            this.txtFilePath.ReadOnly = true;
            this.txtFilePath.PlaceholderText = "Chưa chọn file...";
            this.txtFilePath.BackColor = Color.FromArgb(249, 250, 251);
            this.txtFilePath.Font = new Font("Segoe UI", 9);
            this.txtFilePath.Size = new Size(280, 28);
            this.txtFilePath.Location = new Point(96, 4);

            // btnChonFile
            this.btnChonFile.Text = "Chọn File Biến Động";
            this.btnChonFile.Location = new Point(390, 4);
            this.btnChonFile.BackColor = DHN_WF.CustomUI.UIConstants.SurfaceColor;
            this.btnChonFile.ForeColor = DHN_WF.CustomUI.UIConstants.PrimaryColor;
            this.btnChonFile.HoverColor = Color.FromArgb(240, 240, 240);
            this.btnChonFile.PressedColor = Color.FromArgb(220, 220, 220);
            this.btnChonFile.Cursor = Cursors.Hand;
            this.btnChonFile.Click += new EventHandler(this.BtnChonFile_Click);

            // btnThemFile
            this.btnThemFile.Text = "Thêm File Biến Động";
            this.btnThemFile.Location = new Point(560, 4);
            this.btnThemFile.BackColor = DHN_WF.CustomUI.UIConstants.PrimaryColor;
            this.btnThemFile.HoverColor = DHN_WF.CustomUI.UIConstants.PrimaryHover;
            this.btnThemFile.PressedColor = DHN_WF.CustomUI.UIConstants.PrimaryPressed;
            this.btnThemFile.Cursor = Cursors.Hand;
            this.btnThemFile.Enabled = false;
            this.btnThemFile.Click += new EventHandler(this.BtnThemFile_Click);

            // lblUploadMsg
            this.lblUploadMsg.Text = "";
            this.lblUploadMsg.Font = new Font("Segoe UI", 9);
            this.lblUploadMsg.AutoSize = false;
            this.lblUploadMsg.Dock = DockStyle.Top;
            this.lblUploadMsg.Height = 0;
            this.lblUploadMsg.Padding = new Padding(4, 2, 0, 2);
            this.lblUploadMsg.Visible = false;

            // grpThongTin
            this.grpThongTin.Text = "Thông Tin Đồng Hồ Nước";
            this.grpThongTin.Font = new Font("Segoe UI", 9);
            this.grpThongTin.ForeColor = Color.FromArgb(75, 85, 99);
            this.grpThongTin.Dock = DockStyle.Fill;
            this.grpThongTin.Padding = new Padding(8);
            this.grpThongTin.Controls.Add(this.dgvData);
            this.grpThongTin.Controls.Add(this.panelFilter);

            // panelFilter
            this.panelFilter.Dock = DockStyle.Top;
            this.panelFilter.Height = 50;
            this.panelFilter.Padding = new Padding(0, 10, 0, 10);
            this.panelFilter.Controls.Add(this.lblTheoKy);
            this.panelFilter.Controls.Add(this.cboKy);
            this.panelFilter.Controls.Add(this.btnXem);
            this.panelFilter.Controls.Add(this.lblThongKe);

            // lblTheoKy
            this.lblTheoKy.Text = "Theo Kỳ Đọc:";
            this.lblTheoKy.Font = new Font("Segoe UI", 9);
            this.lblTheoKy.ForeColor = Color.FromArgb(55, 65, 81);
            this.lblTheoKy.AutoSize = false;
            this.lblTheoKy.Size = new Size(90, 28);
            this.lblTheoKy.Location = new Point(0, 4);
            this.lblTheoKy.TextAlign = ContentAlignment.MiddleLeft;

            // cboKy
            this.cboKy.DropDownStyle = ComboBoxStyle.DropDownList;
            this.cboKy.Font = new Font("Segoe UI", 9);
            this.cboKy.Size = new Size(180, 28);
            this.cboKy.Location = new Point(96, 4);

            // btnXem
            this.btnXem.Text = "Xem Dữ Liệu";
            this.btnXem.Location = new Point(284, 4);
            this.btnXem.Size = new Size(120, 32);
            this.btnXem.BackColor = DHN_WF.CustomUI.UIConstants.SurfaceColor;
            this.btnXem.ForeColor = DHN_WF.CustomUI.UIConstants.PrimaryColor;
            this.btnXem.HoverColor = Color.FromArgb(240, 240, 240);
            this.btnXem.PressedColor = Color.FromArgb(220, 220, 220);
            this.btnXem.Cursor = Cursors.Hand;
            this.btnXem.Click += new EventHandler(this.BtnXem_Click);

            // lblThongKe
            this.lblThongKe.Text = "";
            this.lblThongKe.Font = new Font("Segoe UI", 9);
            this.lblThongKe.ForeColor = Color.FromArgb(75, 85, 99);
            this.lblThongKe.BackColor = Color.FromArgb(243, 244, 246);
            this.lblThongKe.AutoSize = false;
            this.lblThongKe.Size = new Size(350, 28);
            this.lblThongKe.Location = new Point(402, 4);
            this.lblThongKe.TextAlign = ContentAlignment.MiddleLeft;
            this.lblThongKe.Padding = new Padding(8, 0, 0, 0);

            // dgvData
            this.dgvData.Dock = DockStyle.Fill;
            this.dgvData.BackgroundColor = Color.White;
            this.dgvData.BorderStyle = BorderStyle.None;
            this.dgvData.AllowUserToAddRows = false;
            this.dgvData.AllowUserToDeleteRows = false;
            this.dgvData.ReadOnly = true;
            this.dgvData.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            this.dgvData.RowHeadersVisible = false;
            this.dgvData.Font = new Font("Segoe UI", 9);
            this.dgvData.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            this.dgvData.ColumnHeadersDefaultCellStyle.BackColor = Color.FromArgb(243, 244, 246);
            this.dgvData.ColumnHeadersDefaultCellStyle.Font = new Font("Segoe UI", 9, FontStyle.Regular);
            this.dgvData.ColumnHeadersDefaultCellStyle.ForeColor = Color.FromArgb(55, 65, 81);
            this.dgvData.EnableHeadersVisualStyles = false;
            this.dgvData.RowTemplate.Height = 28;
            this.dgvData.GridColor = Color.FromArgb(229, 231, 235);

            // Columns
            this.dgvData.Columns.Add(new DataGridViewTextBoxColumn { Name = "colMark", HeaderText = "", FillWeight = 3, ReadOnly = true, DefaultCellStyle = new DataGridViewCellStyle { BackColor = Color.FromArgb(243, 244, 246), ForeColor = Color.FromArgb(33, 150, 243) } });
            this.dgvData.Columns.Add(new DataGridViewTextBoxColumn { Name = "colDot", HeaderText = "Đợt", FillWeight = 6, DefaultCellStyle = new DataGridViewCellStyle { Alignment = DataGridViewContentAlignment.MiddleCenter, Font = new Font("Segoe UI", 9, FontStyle.Bold), ForeColor = Color.FromArgb(33, 150, 243) } });
            this.dgvData.Columns.Add(new DataGridViewTextBoxColumn { Name = "colHDKT", HeaderText = "Tổng HĐ Kỳ Trước", FillWeight = 15, DefaultCellStyle = new DataGridViewCellStyle { Alignment = DataGridViewContentAlignment.MiddleRight } });
            this.dgvData.Columns.Add(new DataGridViewTextBoxColumn { Name = "colBD", HeaderText = "Tổng BĐ", FillWeight = 10, DefaultCellStyle = new DataGridViewCellStyle { Alignment = DataGridViewContentAlignment.MiddleRight } });
            this.dgvData.Columns.Add(new DataGridViewTextBoxColumn { Name = "colTD", HeaderText = "Tổng TĐ", FillWeight = 10, DefaultCellStyle = new DataGridViewCellStyle { Alignment = DataGridViewContentAlignment.MiddleRight, ForeColor = Color.FromArgb(37, 99, 235) } });
            this.dgvData.Columns.Add(new DataGridViewTextBoxColumn { Name = "colNgayBD", HeaderText = "Ngày Lập BĐ", FillWeight = 12 });
            this.dgvData.Columns.Add(new DataGridViewTextBoxColumn { Name = "colNgayTD", HeaderText = "Ngày Lập TĐ", FillWeight = 12 });

            // Row hover color
            this.dgvData.CellFormatting += (s, e) =>
            {
                if (e.RowIndex < 0) return;
                var row = dgvData.Rows[e.RowIndex];
                if (!row.Selected)
                    row.DefaultCellStyle.BackColor = Color.White;
            };
            this.dgvData.SelectionChanged += (s, e) =>
            {
                foreach (DataGridViewRow r in dgvData.Rows)
                    r.DefaultCellStyle.BackColor = r.Selected ? Color.FromArgb(227, 242, 253) : Color.White;
            };

            // TaoDuLieuControl
            this.AutoScaleDimensions = new SizeF(7F, 15F);
            this.AutoScaleMode = AutoScaleMode.Font;
            this.BackColor = Color.White;
            this.Controls.Add(this.grpThongTin);
            this.Controls.Add(this.lblUploadMsg);
            this.Controls.Add(this.panelTop);
            this.Font = new Font("Segoe UI", 9);
            this.Padding = new Padding(4);

            this.panelTop.ResumeLayout(false);
            this.panelFilter.ResumeLayout(false);
            this.grpThongTin.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)this.dgvData).EndInit();
            this.ResumeLayout(false);
        }

        private Panel panelTop;
        private Label lblDuongDan;
        private TextBox txtFilePath;
        private DHN_WF.CustomUI.ModernButton btnChonFile;
        private DHN_WF.CustomUI.ModernButton btnThemFile;
        private Label lblUploadMsg;
        private GroupBox grpThongTin;
        private Panel panelFilter;
        private Label lblTheoKy;
        private ComboBox cboKy;
        private DHN_WF.CustomUI.ModernButton btnXem;
        private Label lblThongKe;
        private DataGridView dgvData;
    }
}
