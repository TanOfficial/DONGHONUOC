using DHN_WF.Controls;

namespace DHN_WF.Forms
{
    partial class MainForm
    {
        private System.ComponentModel.IContainer components = null;
        protected override void Dispose(bool disposing)
        {
            if (disposing && components != null) components.Dispose();
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            this.panelHeader = new Panel();
            this.tabControl = new TabControl();
            this.tabTaoDuLieu = new TabPage();
            this.tabLichDocSo = new TabPage();
            this.tabXuLyDuLieu = new TabPage();
            this.tabTaiKhoan = new TabPage();
            this.lblUserName = new Label();
            this.lblVaiTro = new Label();
            this.btnDangXuat = new DHN_WF.CustomUI.ModernButton();
            this.panelUserInfo = new Panel();
            this.taoDuLieuControl = new TaoDuLieuControl();
            this.lichDocSoControl = new LichDocSoControl();
            this.taiKhoanControl = new TaiKhoanControl();
            this.xuLyDuLieuControl = new XuLyDuLieuControl();

            this.panelHeader.SuspendLayout();
            this.tabControl.SuspendLayout();
            this.tabTaoDuLieu.SuspendLayout();
            this.tabLichDocSo.SuspendLayout();
            this.tabTaiKhoan.SuspendLayout();
            this.panelUserInfo.SuspendLayout();
            this.SuspendLayout();

            // panelHeader
            this.panelHeader.Dock = DockStyle.Top;
            this.panelHeader.Height = 50;
            this.panelHeader.BackColor = Color.White;
            this.panelHeader.BorderStyle = BorderStyle.None;
            this.panelHeader.Padding = new Padding(4, 6, 4, 0);
            this.panelHeader.Controls.Add(this.panelUserInfo);
            this.panelHeader.Controls.Add(this.tabControl);

            // tabControl (tabs only in header)
            this.tabControl.Dock = DockStyle.Fill;
            this.tabControl.SizeMode = TabSizeMode.Fixed;
            this.tabControl.ItemSize = new Size(160, 34);
            this.tabControl.Alignment = TabAlignment.Top;
            this.tabControl.DrawMode = TabDrawMode.OwnerDrawFixed;
            this.tabControl.Font = new Font("Segoe UI", 9, FontStyle.Regular);
            this.tabControl.TabPages.Add(this.tabTaoDuLieu);
            this.tabControl.TabPages.Add(this.tabLichDocSo);
            this.tabControl.TabPages.Add(this.tabXuLyDuLieu);
            this.tabControl.TabPages.Add(this.tabTaiKhoan);
            this.tabControl.DrawItem += new DrawItemEventHandler(this.TabControl_DrawItem);

            // tabTaoDuLieu
            this.tabTaoDuLieu.Text = "Tạo Dữ Liệu Đọc Số";
            this.tabTaoDuLieu.BackColor = Color.White;

            // tabLichDocSo
            this.tabLichDocSo.Text = "Lịch Đọc Số";
            this.tabLichDocSo.BackColor = Color.White;

            // tabXuLyDuLieu
            this.tabXuLyDuLieu.Text = "Xử Lý Dữ Liệu";
            this.tabXuLyDuLieu.BackColor = Color.White;

            // tabTaiKhoan
            this.tabTaiKhoan.Text = "Tài Khoản";
            this.tabTaiKhoan.BackColor = Color.White;

            // panelUserInfo
            this.panelUserInfo.Dock = DockStyle.Right;
            this.panelUserInfo.Width = 220;
            this.panelUserInfo.BackColor = Color.White;
            this.panelUserInfo.Controls.Add(this.btnDangXuat);
            this.panelUserInfo.Controls.Add(this.lblUserName);
            this.panelUserInfo.Controls.Add(this.lblVaiTro);

            // lblUserName
            this.lblUserName.Text = "";
            this.lblUserName.Font = new Font("Segoe UI", 9, FontStyle.Bold);
            this.lblUserName.ForeColor = Color.FromArgb(31, 41, 55);
            this.lblUserName.AutoSize = false;
            this.lblUserName.Size = new Size(120, 16);
            this.lblUserName.Location = new Point(4, 4);
            this.lblUserName.TextAlign = ContentAlignment.MiddleRight;

            // lblVaiTro
            this.lblVaiTro.Text = "";
            this.lblVaiTro.Font = new Font("Segoe UI", 8);
            this.lblVaiTro.ForeColor = Color.Gray;
            this.lblVaiTro.AutoSize = false;
            this.lblVaiTro.Size = new Size(120, 14);
            this.lblVaiTro.Location = new Point(4, 20);
            this.lblVaiTro.TextAlign = ContentAlignment.MiddleRight;

            // btnDangXuat
            this.btnDangXuat.Text = "Đăng xuất";
            this.btnDangXuat.BorderRadius = 8;
            this.btnDangXuat.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
            this.btnDangXuat.BackColor = DHN_WF.CustomUI.UIConstants.DangerColor;
            this.btnDangXuat.ForeColor = Color.White;
            this.btnDangXuat.HoverColor = DHN_WF.CustomUI.UIConstants.DangerHover;
            this.btnDangXuat.PressedColor = DHN_WF.CustomUI.UIConstants.DangerPressed;
            this.btnDangXuat.Size = new Size(88, 32);
            this.btnDangXuat.Location = new Point(128, 8);
            this.btnDangXuat.Cursor = Cursors.Hand;
            this.btnDangXuat.Click += (s, e) => { this.Close(); };

            // Content panel that hosts the user controls
            var panelContent = new Panel();
            panelContent.Dock = DockStyle.Fill;
            panelContent.BackColor = Color.White;
            panelContent.BorderStyle = BorderStyle.FixedSingle;
            panelContent.Padding = new Padding(8);

            // UserControls
            this.taoDuLieuControl.Dock = DockStyle.Fill;
            this.lichDocSoControl.Dock = DockStyle.Fill;
            this.taiKhoanControl.Dock = DockStyle.Fill;
            this.xuLyDuLieuControl.Dock = DockStyle.Fill;

            panelContent.Controls.Add(this.taoDuLieuControl);
            panelContent.Controls.Add(this.lichDocSoControl);
            panelContent.Controls.Add(this.taiKhoanControl);
            panelContent.Controls.Add(this.xuLyDuLieuControl);

            // Wire tab switching
            this.tabControl.SelectedIndexChanged += (s, e) =>
            {
                var sel = tabControl.SelectedTab;
                taoDuLieuControl.Visible = sel == tabTaoDuLieu;
                lichDocSoControl.Visible = sel == tabLichDocSo;
                taiKhoanControl.Visible = sel == tabTaiKhoan;
                xuLyDuLieuControl.Visible = sel == tabXuLyDuLieu;
            };
            // Default
            taoDuLieuControl.Visible = true;
            lichDocSoControl.Visible = false;
            taiKhoanControl.Visible = false;
            xuLyDuLieuControl.Visible = false;

            // MainForm
            this.Text = "Quản Lý Đọc Số – DHN_WF";
            this.ClientSize = new Size(1100, 680);
            this.StartPosition = FormStartPosition.CenterScreen;
            this.MinimumSize = new Size(900, 550);
            this.Font = new Font("Segoe UI", 9);
            this.BackColor = Color.FromArgb(243, 244, 246);
            this.Controls.Add(panelContent);
            this.Controls.Add(this.panelHeader);

            this.panelHeader.ResumeLayout(false);
            this.tabControl.ResumeLayout(false);
            this.tabTaoDuLieu.ResumeLayout(false);
            this.tabLichDocSo.ResumeLayout(false);
            this.tabTaiKhoan.ResumeLayout(false);
            this.panelUserInfo.ResumeLayout(false);
            this.ResumeLayout(false);
        }

        private void TabControl_DrawItem(object sender, DrawItemEventArgs e)
        {
            var tab = tabControl.TabPages[e.Index];
            bool isSelected = (tabControl.SelectedIndex == e.Index);

            var backColor = isSelected ? Color.FromArgb(227, 242, 253) : Color.FromArgb(249, 250, 251);
            var borderColor = isSelected ? Color.FromArgb(33, 150, 243) : Color.FromArgb(209, 213, 219);
            var textColor = isSelected ? Color.FromArgb(25, 118, 210) : Color.FromArgb(75, 85, 99);

            using var bgBrush = new SolidBrush(backColor);
            using var borderPen = new Pen(borderColor, 1.5f);
            using var textBrush = new SolidBrush(textColor);

            var rect = e.Bounds;
            e.Graphics.FillRectangle(bgBrush, rect);
            e.Graphics.DrawRectangle(borderPen, rect.X, rect.Y, rect.Width - 1, rect.Height - 1);

            if (isSelected)
            {
                using var accentBrush = new SolidBrush(Color.FromArgb(33, 150, 243));
                e.Graphics.FillRectangle(accentBrush, rect.X + 1, rect.Y, rect.Width - 2, 3);
            }

            var font = isSelected
                ? new Font("Segoe UI", 9, FontStyle.Bold)
                : new Font("Segoe UI", 9);

            var sf = new StringFormat { Alignment = StringAlignment.Center, LineAlignment = StringAlignment.Center };
            e.Graphics.DrawString(tab.Text, font, textBrush, rect, sf);
        }

        private Panel panelHeader;
        private Panel panelUserInfo;
        private TabControl tabControl;
        private TabPage tabTaoDuLieu;
        private TabPage tabLichDocSo;
        private TabPage tabTaiKhoan;
        private TabPage tabXuLyDuLieu;
        private Label lblUserName;
        private Label lblVaiTro;
        private DHN_WF.CustomUI.ModernButton btnDangXuat;
        private TaoDuLieuControl taoDuLieuControl;
        private LichDocSoControl lichDocSoControl;
        private TaiKhoanControl taiKhoanControl;
        private XuLyDuLieuControl xuLyDuLieuControl;
    }
}
