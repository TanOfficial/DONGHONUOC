namespace DHN_WF.Forms
{
    partial class LoginForm
    {
        private System.ComponentModel.IContainer components = null;

        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null)) components.Dispose();
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            this.panelMain = new Panel();
            this.panelCard = new Panel();
            this.panelLogo = new Panel();
            this.lblTitle = new Label();
            this.lblSubtitle = new Label();
            this.lblError = new Label();
            this.lblUsername = new Label();
            this.txtUsername = new TextBox();
            this.lblPassword = new Label();
            this.txtPassword = new TextBox();
            this.btnLogin = new Button();

            this.panelMain.SuspendLayout();
            this.panelCard.SuspendLayout();
            this.SuspendLayout();

            // panelMain (background)
            this.panelMain.BackColor = Color.FromArgb(227, 242, 253);
            this.panelMain.Dock = DockStyle.Fill;
            this.panelMain.Controls.Add(this.panelCard);

            // panelCard (white card)
            this.panelCard.BackColor = Color.White;
            this.panelCard.BorderStyle = BorderStyle.FixedSingle;
            this.panelCard.Size = new Size(380, 420);
            this.panelCard.Location = new Point(70, 70);
            this.panelCard.Anchor = AnchorStyles.Top | AnchorStyles.Left;
            this.panelCard.Padding = new Padding(32);
            this.panelCard.Controls.Add(this.panelLogo);
            this.panelCard.Controls.Add(this.lblTitle);
            this.panelCard.Controls.Add(this.lblSubtitle);
            this.panelCard.Controls.Add(this.lblError);
            this.panelCard.Controls.Add(this.lblUsername);
            this.panelCard.Controls.Add(this.txtUsername);
            this.panelCard.Controls.Add(this.lblPassword);
            this.panelCard.Controls.Add(this.txtPassword);
            this.panelCard.Controls.Add(this.btnLogin);

            // panelLogo (blue circle)
            this.panelLogo.Size = new Size(64, 64);
            this.panelLogo.BackColor = Color.FromArgb(33, 150, 243);
            this.panelLogo.Location = new Point(158, 28);

            // lblTitle
            this.lblTitle.Text = "Quản Lý Đọc Số";
            this.lblTitle.Font = new Font("Segoe UI", 16, FontStyle.Bold);
            this.lblTitle.ForeColor = Color.FromArgb(33, 33, 33);
            this.lblTitle.AutoSize = false;
            this.lblTitle.TextAlign = ContentAlignment.MiddleCenter;
            this.lblTitle.Size = new Size(314, 36);
            this.lblTitle.Location = new Point(33, 104);

            // lblSubtitle
            this.lblSubtitle.Text = "Hệ thống Water Management";
            this.lblSubtitle.Font = new Font("Segoe UI", 9);
            this.lblSubtitle.ForeColor = Color.Gray;
            this.lblSubtitle.AutoSize = false;
            this.lblSubtitle.TextAlign = ContentAlignment.MiddleCenter;
            this.lblSubtitle.Size = new Size(314, 24);
            this.lblSubtitle.Location = new Point(33, 140);

            // lblError
            this.lblError.Text = "";
            this.lblError.Font = new Font("Segoe UI", 8.5f);
            this.lblError.ForeColor = Color.FromArgb(183, 28, 28);
            this.lblError.BackColor = Color.FromArgb(255, 235, 238);
            this.lblError.AutoSize = false;
            this.lblError.Size = new Size(314, 0);
            this.lblError.Location = new Point(33, 172);
            this.lblError.Padding = new Padding(10, 5, 10, 5);
            this.lblError.Visible = false;
            this.lblError.TextAlign = ContentAlignment.TopLeft;

            // lblUsername
            this.lblUsername.Text = "Tài khoản";
            this.lblUsername.Font = new Font("Segoe UI", 9, FontStyle.Regular);
            this.lblUsername.ForeColor = Color.FromArgb(55, 65, 81);
            this.lblUsername.AutoSize = false;
            this.lblUsername.Size = new Size(314, 20);
            this.lblUsername.Location = new Point(33, 180);

            // txtUsername
            this.txtUsername.Font = new Font("Segoe UI", 10);
            this.txtUsername.Size = new Size(314, 30);
            this.txtUsername.Location = new Point(33, 202);
            this.txtUsername.PlaceholderText = "Nhập tên đăng nhập";

            // lblPassword
            this.lblPassword.Text = "Mật khẩu";
            this.lblPassword.Font = new Font("Segoe UI", 9);
            this.lblPassword.ForeColor = Color.FromArgb(55, 65, 81);
            this.lblPassword.AutoSize = false;
            this.lblPassword.Size = new Size(314, 20);
            this.lblPassword.Location = new Point(33, 244);

            // txtPassword
            this.txtPassword.Font = new Font("Segoe UI", 10);
            this.txtPassword.Size = new Size(314, 30);
            this.txtPassword.Location = new Point(33, 266);
            this.txtPassword.UseSystemPasswordChar = true;
            this.txtPassword.PlaceholderText = "Nhập mật khẩu";

            // btnLogin
            this.btnLogin.Text = "Đăng Nhập";
            this.btnLogin.Font = new Font("Segoe UI", 10, FontStyle.Regular);
            this.btnLogin.BackColor = Color.FromArgb(33, 150, 243);
            this.btnLogin.ForeColor = Color.White;
            this.btnLogin.FlatStyle = FlatStyle.Flat;
            this.btnLogin.FlatAppearance.BorderColor = Color.FromArgb(30, 136, 229);
            this.btnLogin.Size = new Size(314, 40);
            this.btnLogin.Location = new Point(33, 322);
            this.btnLogin.Cursor = Cursors.Hand;
            this.btnLogin.Click += new EventHandler(this.BtnLogin_Click);

            // LoginForm
            this.Text = "Đăng Nhập – Quản Lý Đọc Số";
            this.ClientSize = new Size(520, 560);
            this.StartPosition = FormStartPosition.CenterScreen;
            this.FormBorderStyle = FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.BackColor = Color.FromArgb(227, 242, 253);
            this.Font = new Font("Segoe UI", 9);
            this.Controls.Add(this.panelMain);
            this.AcceptButton = this.btnLogin;
            this.KeyPreview = true;

            this.panelCard.ResumeLayout(false);
            this.panelMain.ResumeLayout(false);
            this.ResumeLayout(false);
        }

        private Panel panelMain;
        private Panel panelCard;
        private Panel panelLogo;
        private Label lblTitle;
        private Label lblSubtitle;
        private Label lblError;
        private Label lblUsername;
        private TextBox txtUsername;
        private Label lblPassword;
        private TextBox txtPassword;
        private Button btnLogin;
    }
}
