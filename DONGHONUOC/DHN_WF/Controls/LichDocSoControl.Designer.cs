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
            this.btnThem = new DHN_WF.CustomUI.ModernButton();
            this.lblNam = new Label();
            this.nudNam = new NumericUpDown();
            this.btnXoa = new DHN_WF.CustomUI.ModernButton();
            this.lblTuNgay = new Label();
            this.chkTuNgay = new CheckBox();
            this.dtpTuNgay = new DateTimePicker();
            this.btnSua = new DHN_WF.CustomUI.ModernButton();
            this.lblDenNgay = new Label();
            this.chkDenNgay = new CheckBox();
            this.dtpDenNgay = new DateTimePicker();
            this.btnMoi = new DHN_WF.CustomUI.ModernButton();
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

            // =============================================
            // splitMain - left for ky management, right for dot details
            // =============================================
            this.splitMain.Dock = DockStyle.Fill;
            this.splitMain.SplitterDistance = 420;
            this.splitMain.SplitterWidth = 5;
            this.splitMain.Panel1.Controls.Add(this.dgvKyList);
            this.splitMain.Panel1.Controls.Add(this.panelKyHeader);
            this.splitMain.Panel1.Controls.Add(this.grpQuanLyKy);
            this.splitMain.Panel2.Controls.Add(this.dgvChiTiet);
            this.splitMain.Panel2.Controls.Add(this.panelChiTietHeader);

            // =============================================
            // grpQuanLyKy - Form to add/edit/delete Ky
            // =============================================
            this.grpQuanLyKy.Text = "Quản Lý Kỳ";
            this.grpQuanLyKy.ForeColor = Color.FromArgb(56, 142, 60);
            this.grpQuanLyKy.Font = new Font("Segoe UI", 9.5F, FontStyle.Bold);
            this.grpQuanLyKy.BackColor = Color.FromArgb(245, 250, 245);
            this.grpQuanLyKy.Dock = DockStyle.Top;
            this.grpQuanLyKy.Height = 195;
            this.grpQuanLyKy.Padding = new Padding(12);

            // --- Row 1: Kỳ + Thêm ---
            int row1Y = 28;
            this.lblKy.Text = "Kỳ:";
            this.lblKy.Font = new Font("Segoe UI", 9.5F);
            this.lblKy.ForeColor = Color.FromArgb(55, 65, 81);
            this.lblKy.AutoSize = false;
            this.lblKy.Size = new Size(70, 28);
            this.lblKy.Location = new Point(15, row1Y);
            this.lblKy.TextAlign = ContentAlignment.MiddleLeft;

            this.nudKy.Minimum = 1;
            this.nudKy.Maximum = 12;
            this.nudKy.Value = 1;
            this.nudKy.Font = new Font("Segoe UI", 10F);
            this.nudKy.Size = new Size(70, 28);
            this.nudKy.Location = new Point(90, row1Y);

            this.btnThem.Text = "Thêm";
            this.btnThem.BorderRadius = 8;
            this.btnThem.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
            this.btnThem.Location = new Point(180, row1Y);
            this.btnThem.Size = new Size(90, 30);
            this.btnThem.BackColor = DHN_WF.CustomUI.UIConstants.SuccessColor;
            this.btnThem.ForeColor = Color.White;
            this.btnThem.HoverColor = DHN_WF.CustomUI.UIConstants.SuccessHover;
            this.btnThem.PressedColor = DHN_WF.CustomUI.UIConstants.SuccessPressed;
            this.btnThem.Cursor = Cursors.Hand;
            this.btnThem.Click += new EventHandler(this.BtnThem_Click);

            this.btnXoa.Text = "Xóa";
            this.btnXoa.BorderRadius = 8;
            this.btnXoa.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
            this.btnXoa.Location = new Point(280, row1Y);
            this.btnXoa.Size = new Size(90, 30);
            this.btnXoa.BackColor = Color.White;
            this.btnXoa.ForeColor = DHN_WF.CustomUI.UIConstants.DangerColor;
            this.btnXoa.HoverColor = Color.FromArgb(254, 226, 226);
            this.btnXoa.PressedColor = Color.FromArgb(252, 165, 165);
            this.btnXoa.Cursor = Cursors.Hand;
            this.btnXoa.Click += new EventHandler(this.BtnXoa_Click);

            // --- Row 2: Năm + Sửa + Mới ---
            int row2Y = 65;
            this.lblNam.Text = "Năm:";
            this.lblNam.Font = new Font("Segoe UI", 9.5F);
            this.lblNam.ForeColor = Color.FromArgb(55, 65, 81);
            this.lblNam.AutoSize = false;
            this.lblNam.Size = new Size(70, 28);
            this.lblNam.Location = new Point(15, row2Y);
            this.lblNam.TextAlign = ContentAlignment.MiddleLeft;

            this.nudNam.Minimum = 2000;
            this.nudNam.Maximum = 2100;
            this.nudNam.Value = DateTime.Today.Year;
            this.nudNam.Font = new Font("Segoe UI", 10F);
            this.nudNam.Size = new Size(70, 28);
            this.nudNam.Location = new Point(90, row2Y);

            this.btnSua.Text = "Sửa";
            this.btnSua.BorderRadius = 8;
            this.btnSua.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
            this.btnSua.Location = new Point(180, row2Y);
            this.btnSua.Size = new Size(90, 30);
            this.btnSua.BackColor = Color.White;
            this.btnSua.ForeColor = DHN_WF.CustomUI.UIConstants.PrimaryColor;
            this.btnSua.HoverColor = Color.FromArgb(227, 242, 253);
            this.btnSua.PressedColor = Color.FromArgb(187, 222, 251);
            this.btnSua.Cursor = Cursors.Hand;
            this.btnSua.Click += new EventHandler(this.BtnSua_Click);

            this.btnMoi.Text = "Mới";
            this.btnMoi.BorderRadius = 8;
            this.btnMoi.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
            this.btnMoi.Location = new Point(280, row2Y);
            this.btnMoi.Size = new Size(90, 30);
            this.btnMoi.BackColor = Color.FromArgb(236, 239, 241);
            this.btnMoi.ForeColor = Color.FromArgb(55, 65, 81);
            this.btnMoi.HoverColor = Color.FromArgb(207, 216, 220);
            this.btnMoi.PressedColor = Color.FromArgb(176, 190, 197);
            this.btnMoi.Cursor = Cursors.Hand;
            this.btnMoi.Click += new EventHandler(this.BtnMoi_Click);

            // --- Row 3: Từ Ngày ---
            int row3Y = 105;
            this.lblTuNgay.Text = "Từ Ngày:";
            this.lblTuNgay.Font = new Font("Segoe UI", 9.5F);
            this.lblTuNgay.ForeColor = Color.FromArgb(55, 65, 81);
            this.lblTuNgay.AutoSize = false;
            this.lblTuNgay.Size = new Size(70, 28);
            this.lblTuNgay.Location = new Point(15, row3Y);
            this.lblTuNgay.TextAlign = ContentAlignment.MiddleLeft;

            this.chkTuNgay.AutoSize = false;
            this.chkTuNgay.Size = new Size(18, 18);
            this.chkTuNgay.Location = new Point(90, row3Y + 5);

            this.dtpTuNgay.Format = DateTimePickerFormat.Custom;
            this.dtpTuNgay.CustomFormat = "dd/MM/yyyy";
            this.dtpTuNgay.Font = new Font("Segoe UI", 9.5F);
            this.dtpTuNgay.Size = new Size(140, 28);
            this.dtpTuNgay.Location = new Point(115, row3Y);

            // --- Row 4: Đến Ngày ---
            int row4Y = 142;
            this.lblDenNgay.Text = "Đến Ngày:";
            this.lblDenNgay.Font = new Font("Segoe UI", 9.5F);
            this.lblDenNgay.ForeColor = Color.FromArgb(55, 65, 81);
            this.lblDenNgay.AutoSize = false;
            this.lblDenNgay.Size = new Size(70, 28);
            this.lblDenNgay.Location = new Point(15, row4Y);
            this.lblDenNgay.TextAlign = ContentAlignment.MiddleLeft;

            this.chkDenNgay.AutoSize = false;
            this.chkDenNgay.Size = new Size(18, 18);
            this.chkDenNgay.Location = new Point(90, row4Y + 5);

            this.dtpDenNgay.Format = DateTimePickerFormat.Custom;
            this.dtpDenNgay.CustomFormat = "dd/MM/yyyy";
            this.dtpDenNgay.Font = new Font("Segoe UI", 9.5F);
            this.dtpDenNgay.Size = new Size(140, 28);
            this.dtpDenNgay.Location = new Point(115, row4Y);

            this.grpQuanLyKy.Controls.AddRange(new Control[] {
                lblKy, nudKy, btnThem, btnXoa,
                lblNam, nudNam, btnSua, btnMoi,
                lblTuNgay, chkTuNgay, dtpTuNgay,
                lblDenNgay, chkDenNgay, dtpDenNgay
            });

            // =============================================
            // panelKyHeader
            // =============================================
            this.panelKyHeader.Dock = DockStyle.Top;
            this.panelKyHeader.Height = 36;
            this.panelKyHeader.BackColor = Color.FromArgb(245, 247, 250);
            this.panelKyHeader.BorderStyle = BorderStyle.None;
            this.panelKyHeader.Controls.Add(this.lblKyHeader);
            this.panelKyHeader.Paint += (s, e) => {
                using var pen = new Pen(Color.FromArgb(224, 224, 224));
                e.Graphics.DrawLine(pen, 0, e.ClipRectangle.Height - 1, e.ClipRectangle.Width, e.ClipRectangle.Height - 1);
            };

            this.lblKyHeader.Text = "Danh Sách Kỳ";
            this.lblKyHeader.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
            this.lblKyHeader.ForeColor = Color.FromArgb(75, 85, 99);
            this.lblKyHeader.Dock = DockStyle.Fill;
            this.lblKyHeader.TextAlign = ContentAlignment.MiddleLeft;
            this.lblKyHeader.Padding = new Padding(10, 0, 0, 0);

            // =============================================
            // dgvKyList
            // =============================================
            this.dgvKyList.Dock = DockStyle.Fill;
            this.dgvKyList.BackgroundColor = Color.White;
            this.dgvKyList.BorderStyle = BorderStyle.None;
            this.dgvKyList.AllowUserToAddRows = false;
            this.dgvKyList.AllowUserToDeleteRows = false;
            this.dgvKyList.ReadOnly = true;
            this.dgvKyList.RowHeadersVisible = false;
            this.dgvKyList.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            this.dgvKyList.Font = new Font("Segoe UI", 9.5F);
            this.dgvKyList.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            this.dgvKyList.ColumnHeadersDefaultCellStyle.BackColor = Color.FromArgb(245, 247, 250);
            this.dgvKyList.ColumnHeadersDefaultCellStyle.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
            this.dgvKyList.ColumnHeadersDefaultCellStyle.ForeColor = Color.FromArgb(75, 85, 99);
            this.dgvKyList.ColumnHeadersDefaultCellStyle.SelectionBackColor = Color.FromArgb(245, 247, 250);
            this.dgvKyList.EnableHeadersVisualStyles = false;
            this.dgvKyList.ColumnHeadersHeight = 36;
            this.dgvKyList.RowTemplate.Height = 32;
            this.dgvKyList.GridColor = Color.FromArgb(230, 230, 230);
            this.dgvKyList.DefaultCellStyle.SelectionBackColor = Color.FromArgb(33, 150, 243);
            this.dgvKyList.DefaultCellStyle.SelectionForeColor = Color.White;
            this.dgvKyList.Columns.Add(new DataGridViewTextBoxColumn { Name = "colMark", HeaderText = "", FillWeight = 5 });
            this.dgvKyList.Columns.Add(new DataGridViewTextBoxColumn { Name = "colKy", HeaderText = "Kỳ", FillWeight = 15, DefaultCellStyle = new DataGridViewCellStyle { Alignment = DataGridViewContentAlignment.MiddleCenter } });
            this.dgvKyList.Columns.Add(new DataGridViewTextBoxColumn { Name = "colNam", HeaderText = "Năm", FillWeight = 20, DefaultCellStyle = new DataGridViewCellStyle { Alignment = DataGridViewContentAlignment.MiddleCenter } });
            this.dgvKyList.Columns.Add(new DataGridViewTextBoxColumn { Name = "colTen", HeaderText = "Tên Kỳ", FillWeight = 60 });
            this.dgvKyList.CellClick += new DataGridViewCellEventHandler(this.DgvKyList_CellClick);

            // =============================================
            // Right - Chi Tiet panel header
            // =============================================
            this.panelChiTietHeader.Dock = DockStyle.Top;
            this.panelChiTietHeader.Height = 36;
            this.panelChiTietHeader.BackColor = Color.FromArgb(245, 247, 250);
            this.panelChiTietHeader.BorderStyle = BorderStyle.None;
            this.panelChiTietHeader.Controls.Add(this.lblChiTietHeader);
            this.panelChiTietHeader.Paint += (s, e) => {
                using var pen = new Pen(Color.FromArgb(224, 224, 224));
                e.Graphics.DrawLine(pen, 0, e.ClipRectangle.Height - 1, e.ClipRectangle.Width, e.ClipRectangle.Height - 1);
            };

            this.lblChiTietHeader.Text = "Chi Tiết 15 Đợt Trong Kỳ";
            this.lblChiTietHeader.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
            this.lblChiTietHeader.ForeColor = Color.FromArgb(75, 85, 99);
            this.lblChiTietHeader.Dock = DockStyle.Fill;
            this.lblChiTietHeader.TextAlign = ContentAlignment.MiddleLeft;
            this.lblChiTietHeader.Padding = new Padding(10, 0, 0, 0);

            // =============================================
            // dgvChiTiet
            // =============================================
            this.dgvChiTiet.Dock = DockStyle.Fill;
            this.dgvChiTiet.BackgroundColor = Color.White;
            this.dgvChiTiet.BorderStyle = BorderStyle.None;
            this.dgvChiTiet.AllowUserToAddRows = false;
            this.dgvChiTiet.AllowUserToDeleteRows = false;
            this.dgvChiTiet.ReadOnly = true;
            this.dgvChiTiet.RowHeadersVisible = false;
            this.dgvChiTiet.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            this.dgvChiTiet.Font = new Font("Segoe UI", 9F);
            this.dgvChiTiet.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            this.dgvChiTiet.ColumnHeadersDefaultCellStyle.BackColor = Color.FromArgb(245, 247, 250);
            this.dgvChiTiet.ColumnHeadersDefaultCellStyle.Font = new Font("Segoe UI", 8.5F, FontStyle.Bold);
            this.dgvChiTiet.ColumnHeadersDefaultCellStyle.ForeColor = Color.FromArgb(75, 85, 99);
            this.dgvChiTiet.ColumnHeadersDefaultCellStyle.SelectionBackColor = Color.FromArgb(245, 247, 250);
            this.dgvChiTiet.ColumnHeadersDefaultCellStyle.WrapMode = DataGridViewTriState.True;
            this.dgvChiTiet.EnableHeadersVisualStyles = false;
            this.dgvChiTiet.ColumnHeadersHeight = 40;
            this.dgvChiTiet.RowTemplate.Height = 30;
            this.dgvChiTiet.GridColor = Color.FromArgb(230, 230, 230);
            this.dgvChiTiet.DefaultCellStyle.SelectionBackColor = Color.FromArgb(227, 242, 253);
            this.dgvChiTiet.DefaultCellStyle.SelectionForeColor = Color.Black;
            this.dgvChiTiet.DefaultCellStyle.Font = new Font("Segoe UI", 8.5F);
            this.dgvChiTiet.Columns.Add(new DataGridViewTextBoxColumn { Name = "cDot", HeaderText = "Đợt", FillWeight = 10, DefaultCellStyle = new DataGridViewCellStyle { Alignment = DataGridViewContentAlignment.MiddleCenter } });
            this.dgvChiTiet.Columns.Add(new DataGridViewTextBoxColumn { Name = "cNgayDoc", HeaderText = "Ngày Đọc", FillWeight = 20 });
            this.dgvChiTiet.Columns.Add(new DataGridViewTextBoxColumn { Name = "cKiemSoat", HeaderText = "Ngày KS", FillWeight = 20 });
            this.dgvChiTiet.Columns.Add(new DataGridViewTextBoxColumn { Name = "cChuyenListing", HeaderText = "Chuyển Listing", FillWeight = 22 });
            this.dgvChiTiet.Columns.Add(new DataGridViewTextBoxColumn { Name = "cThuTien", HeaderText = "Thu Tiền", FillWeight = 18 });
            this.dgvChiTiet.Columns.Add(new DataGridViewCheckBoxColumn { Name = "cKiemTra", HeaderText = "KT", FillWeight = 10 });

            // =============================================
            // LichDocSoControl
            // =============================================
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
        private Label lblKy; private NumericUpDown nudKy; private DHN_WF.CustomUI.ModernButton btnThem;
        private Label lblNam; private NumericUpDown nudNam; private DHN_WF.CustomUI.ModernButton btnXoa;
        private Label lblTuNgay; private CheckBox chkTuNgay; private DateTimePicker dtpTuNgay; private DHN_WF.CustomUI.ModernButton btnSua;
        private Label lblDenNgay; private CheckBox chkDenNgay; private DateTimePicker dtpDenNgay; private DHN_WF.CustomUI.ModernButton btnMoi;
        private Panel panelKyHeader; private Label lblKyHeader;
        private DataGridView dgvKyList;
        private Panel panelChiTietHeader; private Label lblChiTietHeader;
        private DataGridView dgvChiTiet;
    }
}
