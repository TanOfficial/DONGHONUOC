namespace DHN_WF.Controls
{
    partial class TaiKhoanControl
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
            
            // Left Content
            this.panelFormWrapper = new Panel();
            this.lblFormTitle = new Label();
            this.lblError = new Label();
            this.lblSuccess = new Label();
            
            this.lblUsernameL = new Label();
            this.pnlUsername = new Panel();
            this.txtUsername = new TextBox();
            
            this.lblPasswordL = new Label();
            this.pnlPassword = new Panel();
            this.txtPassword = new TextBox();
            
            this.lblHoTenL = new Label();
            this.pnlHoTen = new Panel();
            this.txtHoTen = new TextBox();
            
            this.lblVaiTroL = new Label();
            this.pnlVaiTro = new Panel();
            this.cboVaiTro = new ComboBox();
            
            this.panelButtons = new Panel();
            this.btnHuy = new DHN_WF.CustomUI.ModernButton();
            this.btnLuu = new DHN_WF.CustomUI.ModernButton();
            
            // Right Content
            this.panelGridHeader = new Panel();
            this.lblGridHeader = new Label();
            this.dgvUsers = new DataGridView();

            ((System.ComponentModel.ISupportInitialize)this.splitMain).BeginInit();
            this.splitMain.Panel1.SuspendLayout();
            this.splitMain.Panel2.SuspendLayout();
            this.splitMain.SuspendLayout();
            
            this.panelFormWrapper.SuspendLayout();
            this.pnlUsername.SuspendLayout();
            this.pnlPassword.SuspendLayout();
            this.pnlHoTen.SuspendLayout();
            this.pnlVaiTro.SuspendLayout();
            this.panelButtons.SuspendLayout();
            this.panelGridHeader.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)this.dgvUsers).BeginInit();
            this.SuspendLayout();

            // splitMain
            this.splitMain.Dock = DockStyle.Fill;
            this.splitMain.SplitterDistance = 320;
            this.splitMain.Panel1.BackColor = Color.FromArgb(249, 250, 251); 
            this.splitMain.Panel1.Padding = new Padding(15);
            this.splitMain.Panel1.Controls.Add(this.panelFormWrapper);
            
            this.splitMain.Panel2.Controls.Add(this.dgvUsers);
            this.splitMain.Panel2.Controls.Add(this.panelGridHeader);

            // panelFormWrapper (acts as the modern card)
            this.panelFormWrapper.BackColor = Color.White;
            this.panelFormWrapper.Dock = DockStyle.Top;
            this.panelFormWrapper.Padding = new Padding(20);
            this.panelFormWrapper.AutoSize = true;

            int y = 20;

            // Form Title
            this.lblFormTitle.Text = "TẠO MỚI TÀI KHOẢN";
            this.lblFormTitle.Font = new Font("Segoe UI", 12, FontStyle.Bold);
            this.lblFormTitle.ForeColor = Color.FromArgb(16, 185, 129); // Emerald 500
            this.lblFormTitle.Location = new Point(20, y);
            this.lblFormTitle.AutoSize = true;
            y += 35;

            // Messages
            this.lblError.ForeColor = Color.FromArgb(185, 28, 28);
            this.lblError.BackColor = Color.FromArgb(254, 226, 226);
            this.lblError.Font = new Font("Segoe UI", 9);
            this.lblError.Location = new Point(20, y);
            this.lblError.Size = new Size(280, 40);
            this.lblError.Padding = new Padding(8);
            this.lblError.Visible = false;
            
            this.lblSuccess.ForeColor = Color.FromArgb(6, 95, 70);
            this.lblSuccess.BackColor = Color.FromArgb(209, 250, 229);
            this.lblSuccess.Font = new Font("Segoe UI", 9);
            this.lblSuccess.Location = new Point(20, y);
            this.lblSuccess.Size = new Size(280, 40);
            this.lblSuccess.Padding = new Padding(8);
            this.lblSuccess.Visible = false;
            y += 45;

            // Generator functions for fields
            void MakeLabel(Label l, string t, int ly) 
            { 
                l.Text = t; l.Font = new Font("Segoe UI", 9, FontStyle.Bold); 
                l.ForeColor = Color.FromArgb(55, 65, 81); l.Location = new Point(20, ly); 
                l.AutoSize = true; 
            }
            
            void MakeInput(Panel p, Control input, int py)
            {
                p.BackColor = Color.FromArgb(209, 213, 219); // Default gray border
                p.Size = new Size(280, 36);
                p.Location = new Point(20, py);
                p.Padding = new Padding(1); // 1px border visually
                
                input.Dock = DockStyle.Fill;
                input.Font = new Font("Segoe UI", 10);
                input.Margin = new Padding(0);
                if (input is TextBox t)
                {
                    t.BorderStyle = BorderStyle.None;
                    var innerPanel = new Panel { BackColor = Color.White, Dock = DockStyle.Fill, Padding = new Padding(8, 6, 8, 8) };
                    innerPanel.Controls.Add(t);
                    p.Controls.Add(innerPanel);
                }
                else if (input is ComboBox c)
                {
                    c.FlatStyle = FlatStyle.Flat;
                    var innerPanel = new Panel { BackColor = Color.White, Dock = DockStyle.Fill, Padding = new Padding(5) };
                    innerPanel.Controls.Add(c);
                    p.Controls.Add(innerPanel);
                }
            }

            MakeLabel(lblUsernameL, "Tài khoản (Tên đăng nhập)", y); y += 22;
            txtUsername.PlaceholderText = "Nhập tài khoản...";
            MakeInput(pnlUsername, txtUsername, y); y += 45;

            MakeLabel(lblPasswordL, "Mật khẩu (Bỏ trống nếu không đổi)", y); y += 22;
            txtPassword.UseSystemPasswordChar = true;
            MakeInput(pnlPassword, txtPassword, y); y += 45;

            MakeLabel(lblHoTenL, "Họ và Tên", y); y += 22;
            txtHoTen.PlaceholderText = "Nhập họ tên...";
            MakeInput(pnlHoTen, txtHoTen, y); y += 45;

            MakeLabel(lblVaiTroL, "Vai Trò", y); y += 22;
            cboVaiTro.DropDownStyle = ComboBoxStyle.DropDownList;
            cboVaiTro.Items.AddRange(new object[] { "Nhân Viên", "Quản Lý" });
            cboVaiTro.SelectedIndex = 0;
            MakeInput(pnlVaiTro, cboVaiTro, y); y += 50;

            // panelButtons
            this.panelButtons.Location = new Point(20, y); 
            this.panelButtons.Size = new Size(280, 40); 
            
            this.btnHuy.Text = "Hủy"; this.btnHuy.Font = new Font("Segoe UI", 9, FontStyle.Bold);
            this.btnHuy.BorderRadius = 8;
            this.btnHuy.BackColor = Color.White; this.btnHuy.ForeColor = Color.FromArgb(107, 114, 128);
            this.btnHuy.HoverColor = Color.FromArgb(243, 244, 246);
            this.btnHuy.PressedColor = Color.FromArgb(229, 231, 235);
            this.btnHuy.Size = new Size(80, 36); this.btnHuy.Location = new Point(0, 0); this.btnHuy.Cursor = Cursors.Hand;
            this.btnHuy.Visible = false; this.btnHuy.Click += new EventHandler(this.BtnHuy_Click);
            
            this.btnLuu.Text = "Tạo Tài Khoản"; this.btnLuu.Font = new Font("Segoe UI", 10, FontStyle.Bold);
            this.btnLuu.BorderRadius = 8;
            this.btnLuu.BackColor = DHN_WF.CustomUI.UIConstants.PrimaryColor; this.btnLuu.ForeColor = Color.White;
            this.btnLuu.HoverColor = DHN_WF.CustomUI.UIConstants.PrimaryHover;
            this.btnLuu.PressedColor = DHN_WF.CustomUI.UIConstants.PrimaryPressed;
            this.btnLuu.Size = new Size(190, 36); this.btnLuu.Location = new Point(90, 0); this.btnLuu.Cursor = Cursors.Hand;
            this.btnLuu.Click += new EventHandler(this.BtnLuu_Click);
            this.panelButtons.Controls.AddRange(new Control[] { btnHuy, btnLuu });
            y += 50;

            this.panelFormWrapper.Controls.AddRange(new Control[] {
                lblFormTitle, lblError, lblSuccess, 
                lblUsernameL, pnlUsername,
                lblPasswordL, pnlPassword, 
                lblHoTenL, pnlHoTen,
                lblVaiTroL, pnlVaiTro, 
                panelButtons
            });
            this.panelFormWrapper.Height = y + 20;

            // Custom border for panelFormWrapper
            this.panelFormWrapper.Paint += (s, e) => {
                ControlPaint.DrawBorder(e.Graphics, panelFormWrapper.ClientRectangle,
                                      Color.FromArgb(229, 231, 235), 1, ButtonBorderStyle.Solid,
                                      Color.FromArgb(229, 231, 235), 1, ButtonBorderStyle.Solid,
                                      Color.FromArgb(229, 231, 235), 1, ButtonBorderStyle.Solid,
                                      Color.FromArgb(229, 231, 235), 1, ButtonBorderStyle.Solid);
            };

            // Grid Header
            this.panelGridHeader.Dock = DockStyle.Top; this.panelGridHeader.Height = 40;
            this.panelGridHeader.BackColor = Color.White;
            this.panelGridHeader.Controls.Add(this.lblGridHeader);
            
            this.lblGridHeader.Text = "DANH SÁCH TÀI KHOẢN";
            this.lblGridHeader.Font = new Font("Segoe UI", 10, FontStyle.Bold); 
            this.lblGridHeader.ForeColor = Color.FromArgb(55, 65, 81);
            this.lblGridHeader.Dock = DockStyle.Fill; this.lblGridHeader.TextAlign = ContentAlignment.MiddleLeft;
            this.lblGridHeader.Padding = new Padding(15, 0, 0, 0);

            // dgvUsers
            this.dgvUsers.Dock = DockStyle.Fill;
            this.dgvUsers.BackgroundColor = Color.FromArgb(249, 250, 251); 
            this.dgvUsers.BorderStyle = BorderStyle.None;
            this.dgvUsers.AllowUserToAddRows = false; this.dgvUsers.AllowUserToDeleteRows = false;
            this.dgvUsers.RowHeadersVisible = false; this.dgvUsers.Font = new Font("Segoe UI", 10);
            this.dgvUsers.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            this.dgvUsers.ColumnHeadersHeight = 40;
            this.dgvUsers.ColumnHeadersDefaultCellStyle.BackColor = Color.FromArgb(243, 244, 246);
            this.dgvUsers.ColumnHeadersDefaultCellStyle.ForeColor = Color.FromArgb(75, 85, 99);
            this.dgvUsers.ColumnHeadersDefaultCellStyle.Font = new Font("Segoe UI", 9, FontStyle.Bold);
            this.dgvUsers.EnableHeadersVisualStyles = false;
            this.dgvUsers.RowTemplate.Height = 36; this.dgvUsers.GridColor = Color.FromArgb(229, 231, 235);
            this.dgvUsers.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            this.dgvUsers.DefaultCellStyle.SelectionBackColor = Color.FromArgb(239, 246, 255);
            this.dgvUsers.DefaultCellStyle.SelectionForeColor = Color.FromArgb(17, 24, 39);

            this.dgvUsers.Columns.Add(new DataGridViewTextBoxColumn { Name = "colUsername", HeaderText = "TÀI KHOẢN", ReadOnly = true, FillWeight = 25 });
            this.dgvUsers.Columns.Add(new DataGridViewTextBoxColumn { Name = "colHoTen", HeaderText = "HỌ VÀ TÊN", ReadOnly = true, FillWeight = 35 });
            this.dgvUsers.Columns.Add(new DataGridViewTextBoxColumn { Name = "colVaiTro", HeaderText = "VAI TRÒ", ReadOnly = true, FillWeight = 20, DefaultCellStyle = new DataGridViewCellStyle { Alignment = DataGridViewContentAlignment.MiddleCenter, Font = new Font("Segoe UI", 9, FontStyle.Bold), ForeColor = Color.FromArgb(37, 99, 235) } });
            this.colEdit = new DataGridViewButtonColumn { Name = "colEdit", HeaderText = "THAO TÁC", Text = "Chỉnh Sửa", UseColumnTextForButtonValue = true, FillWeight = 20, FlatStyle = FlatStyle.Flat };
            this.colEdit.DefaultCellStyle.BackColor = Color.FromArgb(243, 244, 246);
            this.dgvUsers.Columns.Add(this.colEdit);
            this.dgvUsers.CellContentClick += new DataGridViewCellEventHandler(this.DgvUsers_CellContentClick);

            // TaiKhoanControl
            this.AutoScaleDimensions = new SizeF(7F, 15F);
            this.AutoScaleMode = AutoScaleMode.Font;
            this.BackColor = Color.White;
            this.Controls.Add(this.splitMain);
            this.Font = new Font("Segoe UI", 9);

            ((System.ComponentModel.ISupportInitialize)this.splitMain).EndInit();
            this.splitMain.Panel1.ResumeLayout(false);
            this.splitMain.Panel1.PerformLayout();
            this.splitMain.Panel2.ResumeLayout(false);
            this.splitMain.ResumeLayout(false);
            this.panelFormWrapper.ResumeLayout(false);
            this.panelFormWrapper.PerformLayout();
            this.pnlUsername.ResumeLayout(false);
            this.pnlUsername.PerformLayout();
            this.pnlPassword.ResumeLayout(false);
            this.pnlPassword.PerformLayout();
            this.pnlHoTen.ResumeLayout(false);
            this.pnlHoTen.PerformLayout();
            this.pnlVaiTro.ResumeLayout(false);
            this.panelButtons.ResumeLayout(false);
            this.panelGridHeader.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)this.dgvUsers).EndInit();
            this.ResumeLayout(false);
        }

        private SplitContainer splitMain;
        private Panel panelFormWrapper;
        private Label lblFormTitle;
        private Label lblError, lblSuccess;
        
        private Label lblUsernameL; private Panel pnlUsername; private TextBox txtUsername;
        private Label lblPasswordL; private Panel pnlPassword; private TextBox txtPassword;
        private Label lblHoTenL; private Panel pnlHoTen; private TextBox txtHoTen;
        private Label lblVaiTroL; private Panel pnlVaiTro; private ComboBox cboVaiTro;
        
        private Panel panelButtons; private DHN_WF.CustomUI.ModernButton btnHuy, btnLuu;
        private Panel panelGridHeader; private Label lblGridHeader;
        private DataGridView dgvUsers;
        private DataGridViewButtonColumn colEdit;
    }
}
