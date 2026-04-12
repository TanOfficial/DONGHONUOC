namespace DHN_WF.Controls
{
    partial class LichDocSoControl
    {
        private System.ComponentModel.IContainer components = null;
        protected override void Dispose(bool disposing)
        {
            if (disposing && components != null) components.Dispose();
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            this.splitMain = new SplitContainer();
            // --- Left panel ---
            this.grpQuanLyKy = new GroupBox();
            this.tableLeft = new TableLayoutPanel();
            this.lblKy = new Label();
            this.nudKy = new NumericUpDown();
            this.btnThem = new Button();
            this.lblNam = new Label();
            this.nudNam = new NumericUpDown();
            this.btnXoa = new Button();
            this.lblTuNgay = new Label();
            this.chkTuNgay = new CheckBox();
            this.dtpTuNgay = new DateTimePicker();
            this.btnSua = new Button();
            this.lblDenNgay = new Label();
            this.chkDenNgay = new CheckBox();
            this.dtpDenNgay = new DateTimePicker();
            this.btnMoi = new Button();
            this.panelKyHeader = new Panel();
            this.lblKyHeader = new Label();
            this.dgvKyList = new DataGridView();
            // --- Right panel ---
            this.panelChiTietHeader = new Panel();
            this.lblChiTietHeader = new Label();
            this.dgvChiTiet = new DataGridView();

            ((System.ComponentModel.ISupportInitialize)this.splitMain).BeginInit();
            this.splitMain.Panel1.SuspendLayout();
            this.splitMain.Panel2.SuspendLayout();
            this.splitMain.SuspendLayout();
            this.grpQuanLyKy.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)this.nudKy).BeginInit();
            ((System.ComponentModel.ISupportInitialize)this.nudNam).BeginInit();
            ((System.ComponentModel.ISupportInitialize)this.dgvKyList).BeginInit();
            ((System.ComponentModel.ISupportInitialize)this.dgvChiTiet).BeginInit();
            this.SuspendLayout();

            // splitMain
            this.splitMain.Dock = DockStyle.Fill;
            this.splitMain.SplitterDistance = 290;
            this.splitMain.Panel1.Controls.Add(this.dgvKyList);
            this.splitMain.Panel1.Controls.Add(this.panelKyHeader);
            this.splitMain.Panel1.Controls.Add(this.grpQuanLyKy);
            this.splitMain.Panel2.Controls.Add(this.dgvChiTiet);
            this.splitMain.Panel2.Controls.Add(this.panelChiTietHeader);

            // grpQuanLyKy
            this.grpQuanLyKy.Text = "Quản Lý Kỳ";
            this.grpQuanLyKy.ForeColor = Color.FromArgb(124, 179, 66);
            this.grpQuanLyKy.Font = new Font("Segoe UI", 9, FontStyle.Bold);
            this.grpQuanLyKy.BackColor = Color.FromArgb(241, 248, 233);
            this.grpQuanLyKy.Dock = DockStyle.Top;
            this.grpQuanLyKy.Height = 148;
            this.grpQuanLyKy.Padding = new Padding(8, 4, 8, 4);

            // Layout rows inside grpQuanLyKy manually
            // Row 1: Kỳ + Thêm
            this.lblKy.Text = "Kỳ"; this.lblKy.Font = new Font("Segoe UI", 9, FontStyle.Regular);
            this.lblKy.ForeColor = Color.FromArgb(55, 65, 81); this.lblKy.AutoSize = false;
            this.lblKy.Size = new Size(60, 26); this.lblKy.Location = new Point(10, 26); this.lblKy.TextAlign = ContentAlignment.MiddleLeft;
            this.nudKy.Size = new Size(70, 26); this.nudKy.Location = new Point(72, 26); this.nudKy.Minimum = 1; this.nudKy.Maximum = 12; this.nudKy.Font = new Font("Segoe UI", 9);
            this.btnThem.Text = "Thêm"; this.btnThem.Font = new Font("Segoe UI", 9);
            this.btnThem.BackColor = Color.FromArgb(139, 195, 74); this.btnThem.ForeColor = Color.White;
            this.btnThem.FlatStyle = FlatStyle.Flat; this.btnThem.FlatAppearance.BorderColor = Color.FromArgb(124, 179, 66);
            this.btnThem.Size = new Size(80, 26); this.btnThem.Location = new Point(148, 26); this.btnThem.Cursor = Cursors.Hand;
            this.btnThem.Click += new EventHandler(this.BtnThem_Click);
            // Row 2: Năm + Xóa
            this.lblNam.Text = "Năm"; this.lblNam.Font = new Font("Segoe UI", 9, FontStyle.Regular);
            this.lblNam.ForeColor = Color.FromArgb(55, 65, 81); this.lblNam.AutoSize = false;
            this.lblNam.Size = new Size(60, 26); this.lblNam.Location = new Point(10, 58); this.lblNam.TextAlign = ContentAlignment.MiddleLeft;
            this.nudNam.Size = new Size(70, 26); this.nudNam.Location = new Point(72, 58); this.nudNam.Minimum = 2000; this.nudNam.Maximum = 2100; this.nudNam.Value = DateTime.Today.Year; this.nudNam.Font = new Font("Segoe UI", 9);
            this.btnXoa.Text = "Xóa"; this.btnXoa.Font = new Font("Segoe UI", 9);
            this.btnXoa.BackColor = Color.White; this.btnXoa.ForeColor = Color.FromArgb(239, 68, 68);
            this.btnXoa.FlatStyle = FlatStyle.Flat; this.btnXoa.FlatAppearance.BorderColor = Color.FromArgb(248, 113, 113);
            this.btnXoa.Size = new Size(80, 26); this.btnXoa.Location = new Point(148, 58); this.btnXoa.Cursor = Cursors.Hand;
            this.btnXoa.Click += new EventHandler(this.BtnXoa_Click);
            // Row 3: Từ Ngày + Sửa
            this.lblTuNgay.Text = "Từ Ngày"; this.lblTuNgay.Font = new Font("Segoe UI", 9, FontStyle.Regular);
            this.lblTuNgay.ForeColor = Color.FromArgb(55, 65, 81); this.lblTuNgay.AutoSize = false;
            this.lblTuNgay.Size = new Size(60, 26); this.lblTuNgay.Location = new Point(10, 90); this.lblTuNgay.TextAlign = ContentAlignment.MiddleLeft;
            this.chkTuNgay.AutoSize = false; this.chkTuNgay.Size = new Size(16, 16); this.chkTuNgay.Location = new Point(71, 95);
            this.dtpTuNgay.Format = DateTimePickerFormat.Short; this.dtpTuNgay.Size = new Size(100, 26); this.dtpTuNgay.Location = new Point(90, 90); this.dtpTuNgay.Font = new Font("Segoe UI", 8);
            this.btnSua.Text = "Sửa"; this.btnSua.Font = new Font("Segoe UI", 9);
            this.btnSua.BackColor = Color.White; this.btnSua.ForeColor = Color.FromArgb(33, 150, 243);
            this.btnSua.FlatStyle = FlatStyle.Flat; this.btnSua.FlatAppearance.BorderColor = Color.FromArgb(33, 150, 243);
            this.btnSua.Size = new Size(80, 26); this.btnSua.Location = new Point(194, 90); this.btnSua.Cursor = Cursors.Hand; this.btnSua.Anchor = AnchorStyles.Right;
            this.btnSua.Click += new EventHandler(this.BtnSua_Click);
            // Row 4: Đến Ngày + Mới
            this.lblDenNgay.Text = "Đến Ngày"; this.lblDenNgay.Font = new Font("Segoe UI", 9, FontStyle.Regular);
            this.lblDenNgay.ForeColor = Color.FromArgb(55, 65, 81); this.lblDenNgay.AutoSize = false;
            this.lblDenNgay.Size = new Size(60, 26); this.lblDenNgay.Location = new Point(10, 118); this.lblDenNgay.TextAlign = ContentAlignment.MiddleLeft;
            this.chkDenNgay.AutoSize = false; this.chkDenNgay.Size = new Size(16, 16); this.chkDenNgay.Location = new Point(71, 123);
            this.dtpDenNgay.Format = DateTimePickerFormat.Short; this.dtpDenNgay.Size = new Size(100, 26); this.dtpDenNgay.Location = new Point(90, 118); this.dtpDenNgay.Font = new Font("Segoe UI", 8);
            this.btnMoi.Text = "Mới"; this.btnMoi.Font = new Font("Segoe UI", 9);
            this.btnMoi.BackColor = Color.FromArgb(243, 244, 246); this.btnMoi.ForeColor = Color.FromArgb(75, 85, 99);
            this.btnMoi.FlatStyle = FlatStyle.Flat; this.btnMoi.FlatAppearance.BorderColor = Color.FromArgb(209, 213, 219);
            this.btnMoi.Size = new Size(80, 26); this.btnMoi.Location = new Point(194, 118); this.btnMoi.Cursor = Cursors.Hand;
            this.btnMoi.Click += new EventHandler(this.BtnMoi_Click);

            this.grpQuanLyKy.Controls.AddRange(new Control[] {
                lblKy, nudKy, btnThem, lblNam, nudNam, btnXoa,
                lblTuNgay, chkTuNgay, dtpTuNgay, btnSua,
                lblDenNgay, chkDenNgay, dtpDenNgay, btnMoi
            });

            // panelKyHeader
            this.panelKyHeader.Dock = DockStyle.Top;
            this.panelKyHeader.Height = 28;
            this.panelKyHeader.BackColor = Color.FromArgb(249, 250, 251);
            this.panelKyHeader.BorderStyle = BorderStyle.FixedSingle;
            this.panelKyHeader.Controls.Add(this.lblKyHeader);

            this.lblKyHeader.Text = "Danh Sách Kỳ";
            this.lblKyHeader.Font = new Font("Segoe UI", 9, FontStyle.Regular);
            this.lblKyHeader.ForeColor = Color.FromArgb(75, 85, 99);
            this.lblKyHeader.Dock = DockStyle.Fill;
            this.lblKyHeader.TextAlign = ContentAlignment.MiddleLeft;
            this.lblKyHeader.Padding = new Padding(8, 0, 0, 0);

            // dgvKyList
            this.dgvKyList.Dock = DockStyle.Fill;
            this.dgvKyList.BackgroundColor = Color.White;
            this.dgvKyList.BorderStyle = BorderStyle.None;
            this.dgvKyList.AllowUserToAddRows = false; this.dgvKyList.AllowUserToDeleteRows = false;
            this.dgvKyList.ReadOnly = true; this.dgvKyList.RowHeadersVisible = false;
            this.dgvKyList.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            this.dgvKyList.Font = new Font("Segoe UI", 9);
            this.dgvKyList.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            this.dgvKyList.ColumnHeadersDefaultCellStyle.BackColor = Color.FromArgb(243, 244, 246);
            this.dgvKyList.ColumnHeadersDefaultCellStyle.Font = new Font("Segoe UI", 9);
            this.dgvKyList.EnableHeadersVisualStyles = false;
            this.dgvKyList.RowTemplate.Height = 26;
            this.dgvKyList.GridColor = Color.FromArgb(229, 231, 235);
            this.dgvKyList.Columns.Add(new DataGridViewTextBoxColumn { Name = "colMark", HeaderText = "", FillWeight = 5, DefaultCellStyle = new DataGridViewCellStyle { BackColor = Color.FromArgb(243,244,246) } });
            this.dgvKyList.Columns.Add(new DataGridViewTextBoxColumn { Name = "colKy", HeaderText = "Kỳ", FillWeight = 15, DefaultCellStyle = new DataGridViewCellStyle { Alignment = DataGridViewContentAlignment.MiddleCenter } });
            this.dgvKyList.Columns.Add(new DataGridViewTextBoxColumn { Name = "colNam", HeaderText = "Năm", FillWeight = 20, DefaultCellStyle = new DataGridViewCellStyle { Alignment = DataGridViewContentAlignment.MiddleCenter } });
            this.dgvKyList.Columns.Add(new DataGridViewTextBoxColumn { Name = "colTen", HeaderText = "Tên Kỳ", FillWeight = 60 });
            this.dgvKyList.CellClick += new DataGridViewCellEventHandler(this.DgvKyList_CellClick);

            // Right - Chi Tiet panel
            this.panelChiTietHeader.Dock = DockStyle.Top;
            this.panelChiTietHeader.Height = 28;
            this.panelChiTietHeader.BackColor = Color.FromArgb(249, 250, 251);
            this.panelChiTietHeader.BorderStyle = BorderStyle.FixedSingle;
            this.panelChiTietHeader.Controls.Add(this.lblChiTietHeader);
            this.lblChiTietHeader.Text = "Chi Tiết 15 Đợt Trong Kỳ";
            this.lblChiTietHeader.Font = new Font("Segoe UI", 9, FontStyle.Regular);
            this.lblChiTietHeader.ForeColor = Color.FromArgb(75, 85, 99);
            this.lblChiTietHeader.Dock = DockStyle.Fill;
            this.lblChiTietHeader.TextAlign = ContentAlignment.MiddleLeft;
            this.lblChiTietHeader.Padding = new Padding(8, 0, 0, 0);

            // dgvChiTiet
            this.dgvChiTiet.Dock = DockStyle.Fill;
            this.dgvChiTiet.BackgroundColor = Color.White;
            this.dgvChiTiet.BorderStyle = BorderStyle.None;
            this.dgvChiTiet.AllowUserToAddRows = false; this.dgvChiTiet.AllowUserToDeleteRows = false;
            this.dgvChiTiet.ReadOnly = true; this.dgvChiTiet.RowHeadersVisible = false;
            this.dgvChiTiet.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            this.dgvChiTiet.Font = new Font("Segoe UI", 9);
            this.dgvChiTiet.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            this.dgvChiTiet.ColumnHeadersDefaultCellStyle.BackColor = Color.FromArgb(243, 244, 246);
            this.dgvChiTiet.ColumnHeadersDefaultCellStyle.Font = new Font("Segoe UI", 9);
            this.dgvChiTiet.EnableHeadersVisualStyles = false;
            this.dgvChiTiet.RowTemplate.Height = 26;
            this.dgvChiTiet.GridColor = Color.FromArgb(229, 231, 235);
            this.dgvChiTiet.Columns.Add(new DataGridViewTextBoxColumn { Name = "cMark", HeaderText = "", FillWeight = 4, DefaultCellStyle = new DataGridViewCellStyle { BackColor = Color.FromArgb(243,244,246) } });
            this.dgvChiTiet.Columns.Add(new DataGridViewTextBoxColumn { Name = "cDot", HeaderText = "Đợt", FillWeight = 8, DefaultCellStyle = new DataGridViewCellStyle { Alignment = DataGridViewContentAlignment.MiddleCenter } });
            this.dgvChiTiet.Columns.Add(new DataGridViewTextBoxColumn { Name = "cNgayDoc", HeaderText = "Ngày Đọc", FillWeight = 18 });
            this.dgvChiTiet.Columns.Add(new DataGridViewTextBoxColumn { Name = "cKiemSoat", HeaderText = "Ngày Kiểm Soát", FillWeight = 18 });
            this.dgvChiTiet.Columns.Add(new DataGridViewTextBoxColumn { Name = "cChuyenListing", HeaderText = "Ngày Chuyển Listing", FillWeight = 22 });
            this.dgvChiTiet.Columns.Add(new DataGridViewTextBoxColumn { Name = "cThuTien", HeaderText = "Ngày Thu Tiền", FillWeight = 18 });
            this.dgvChiTiet.Columns.Add(new DataGridViewCheckBoxColumn { Name = "cKiemTra", HeaderText = "Kiểm Tra Ngày Đọc", FillWeight = 12 });
            this.dgvChiTiet.DefaultCellStyle.SelectionBackColor = Color.FromArgb(227, 242, 253);
            this.dgvChiTiet.DefaultCellStyle.SelectionForeColor = Color.Black;

            // LichDocSoControl
            this.AutoScaleDimensions = new SizeF(7F, 15F);
            this.AutoScaleMode = AutoScaleMode.Font;
            this.BackColor = Color.White;
            this.Controls.Add(this.splitMain);
            this.Font = new Font("Segoe UI", 9);

            ((System.ComponentModel.ISupportInitialize)this.splitMain).EndInit();
            this.splitMain.Panel1.ResumeLayout(false);
            this.splitMain.Panel2.ResumeLayout(false);
            this.splitMain.ResumeLayout(false);
            this.grpQuanLyKy.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)this.nudKy).EndInit();
            ((System.ComponentModel.ISupportInitialize)this.nudNam).EndInit();
            ((System.ComponentModel.ISupportInitialize)this.dgvKyList).EndInit();
            ((System.ComponentModel.ISupportInitialize)this.dgvChiTiet).EndInit();
            this.ResumeLayout(false);
        }

        private SplitContainer splitMain;
        private GroupBox grpQuanLyKy;
        private TableLayoutPanel tableLeft;
        private Label lblKy; private NumericUpDown nudKy; private Button btnThem;
        private Label lblNam; private NumericUpDown nudNam; private Button btnXoa;
        private Label lblTuNgay; private CheckBox chkTuNgay; private DateTimePicker dtpTuNgay; private Button btnSua;
        private Label lblDenNgay; private CheckBox chkDenNgay; private DateTimePicker dtpDenNgay; private Button btnMoi;
        private Panel panelKyHeader; private Label lblKyHeader;
        private DataGridView dgvKyList;
        private Panel panelChiTietHeader; private Label lblChiTietHeader;
        private DataGridView dgvChiTiet;
    }
}
