using DHN_WF.Services;

namespace DHN_WF.Forms
{
    public partial class LoginForm : Form
    {
        private readonly ApiService _api = new ApiService();

        public LoginForm()
        {
            InitializeComponent();
            this.Load += (s, e) => { PaintLogo(); };
        }

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            CenterCard();
        }

        protected override void OnResize(EventArgs e)
        {
            base.OnResize(e);
            CenterCard();
        }

        private void CenterCard()
        {
            if (panelCard != null)
            {
                panelCard.Left = (this.ClientSize.Width - panelCard.Width) / 2;
                panelCard.Top = (this.ClientSize.Height - panelCard.Height) / 2;
            }
        }



        private void PaintLogo()
        {
            // Make logo circle via Region
            System.Drawing.Drawing2D.GraphicsPath path = new();
            path.AddEllipse(0, 0, panelLogo.Width, panelLogo.Height);
            panelLogo.Region = new Region(path);

            // Draw water drop icon on panelLogo
            panelLogo.Paint += (s, e) =>
            {
                e.Graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
                using var pen = new Pen(Color.White, 2.5f);
                // Simple water drop: circle bottom, tapering top
                var g = e.Graphics;
                g.FillEllipse(Brushes.White, 18, 32, 28, 22);
                var pts = new PointF[] { new(32, 8), new(18, 32), new(46, 32) };
                g.FillPolygon(Brushes.White, pts);
            };
            panelLogo.Invalidate();
        }

        private void ShowError(string msg)
        {
            if (string.IsNullOrEmpty(msg))
            {
                lblError.Visible = false;
                lblError.Height = 0;
                // Shift fields up to default
                lblUsername.Top = 180;
                txtUsername.Top = 202;
                lblPassword.Top = 244;
                txtPassword.Top = 266;
                btnLogin.Top = 322;
            }
            else
            {
                lblError.Text = msg;
                // Calculate required height for text
                Size size = TextRenderer.MeasureText(msg, lblError.Font, new Size(lblError.Width, 1000), TextFormatFlags.WordBreak);
                lblError.Height = size.Height + 12; 
                lblError.Visible = true;

                // Shift fields down based on error height
                int offset = lblError.Height + 10;
                lblUsername.Top = 150 + offset;
                txtUsername.Top = 172 + offset;
                lblPassword.Top = 214 + offset;
                txtPassword.Top = 236 + offset;
                btnLogin.Top = 292 + offset;
            }
        }

        private async void BtnLogin_Click(object sender, EventArgs e)
        {
            ShowError("");
            btnLogin.Text = "Đang xác thực...";
            btnLogin.Enabled = false;

            try
            {
                var result = await _api.LoginAsync(txtUsername.Text.Trim(), txtPassword.Text);
                if (result == null)
                {
                    ShowError("Lỗi kết nối đến máy chủ.");
                    return;
                }
                if (result.Success)
                {
                    AppSession.CurrentUser = result;
                    var main = new MainForm();
                    main.Show();
                    this.Hide();
                    main.FormClosed += (_, _) => { this.Show(); AppSession.Clear(); txtPassword.Clear(); ShowError(""); btnLogin.Text = "Đăng Nhập"; };
                }
                else
                {
                    ShowError(result.Message ?? "Đăng nhập thất bại.");
                }
            }
            catch (Exception ex)
            {
                ShowError("Lỗi kết nối. Hãy đảm bảo DONGHONUOC_API đang chạy.\n" + ex.Message);
            }
            finally
            {
                btnLogin.Text = "Đăng Nhập";
                btnLogin.Enabled = true;
            }
        }
    }
}
