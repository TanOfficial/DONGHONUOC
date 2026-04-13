using DHN_WF.Services;
using DHN_WF.CustomUI;
using System.Drawing.Drawing2D;

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
            // Update labels for branding
            lblTitle.Text = ""; 
            lblTitle.Height = 0;
            lblSubtitle.Text = "Hệ thống Quản Lý Đọc Số";
            
            panelLogo.Size = new Size(110, 110);
            if (panelCard != null) panelLogo.Left = (panelCard.Width - panelLogo.Width) / 2;
            panelLogo.BackColor = Color.White;
            panelLogo.BorderStyle = BorderStyle.None;
            panelLogo.Region = null;

            // Search for logo in multiple possible locations
            string[] possiblePaths = {
                Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Resources", "logo.png"),
                Path.Combine(Directory.GetCurrentDirectory(), "Resources", "logo.png"),
                Path.Combine(Directory.GetCurrentDirectory(), "DHN_WF", "Resources", "logo.png"),
                "D:\\ThucTap\\Hinh\\Logo\\logo.png" 
            };

            string? finalPath = null;
            foreach (var path in possiblePaths) {
                if (File.Exists(path)) {
                    finalPath = path;
                    break;
                }
            }

            // Draw circular border and image
            panelLogo.Paint += (s, e) =>
            {
                var g = e.Graphics;
                g.SmoothingMode = SmoothingMode.AntiAlias;
                
                // Draw soft circular border
                using (var pen = new Pen(Color.FromArgb(40, Color.SteelBlue), 2f))
                {
                    g.DrawEllipse(pen, 1, 1, panelLogo.Width - 3, panelLogo.Height - 3);
                }

                if (finalPath != null && File.Exists(finalPath))
                {
                    using (var img = Image.FromFile(finalPath))
                    {
                        // Draw image centered in the circle with less padding
                        float ratio = Math.Min((float)(panelLogo.Width - 6) / img.Width, (float)(panelLogo.Height - 6) / img.Height);
                        int nw = (int)(img.Width * ratio);
                        int nh = (int)(img.Height * ratio);
                        g.DrawImage(img, (panelLogo.Width - nw) / 2, (panelLogo.Height - nh) / 2, nw, nh);
                    }
                }
                else
                {
                    // Fallback
                    g.FillEllipse(Brushes.LightSteelBlue, 15, 15, panelLogo.Width - 30, panelLogo.Height - 30);
                }
            };

            panelLogo.Invalidate();
        }

        private void ShowError(string msg)
        {
            if (string.IsNullOrEmpty(msg))
            {
                lblError.Visible = false;
                lblError.Height = 0;
            }
            else
            {
                NotificationManager.Show("Lỗi", msg, NotificationType.Error);
            }
        }

        private async void BtnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                ShowError("Vui lòng nhập đầy đủ tài khoản và mật khẩu.");
                return;
            }

            try
            {
                btnLogin.Enabled = false;
                btnLogin.Text = "Đang xử lý...";

                var result = await _api.LoginAsync(username, password);

                if (result != null && result.Success)
                {
                    AppSession.CurrentUser = result;
                    var main = new MainForm();
                    main.Show();
                    this.Hide();
                }
                else
                {
                    ShowError("Sai tài khoản hoặc mật khẩu.");
                }
            }
            catch (Exception ex)
            {
                ShowError("Lỗi kết nối: " + ex.Message);
            }
            finally
            {
                btnLogin.Enabled = true;
                btnLogin.Text = "Đăng Nhập";
            }
        }
    }
}
