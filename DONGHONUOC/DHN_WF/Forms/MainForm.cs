using DHN_WF.Controls;
using DHN_WF.CustomUI;

namespace DHN_WF.Forms
{
    public partial class MainForm : Form
    {
        public MainForm()
        {
            InitializeComponent();
            
            this.Shown += (s, e) => {
                // Show welcome notification on MainForm AFTER it is physically visible
                NotificationManager.Show("Thành công", $"Chào mừng {AppSession.CurrentUser?.HoTen ?? "bạn"}! Đăng nhập thành công.", NotificationType.Success);
            };

            this.FormClosed += (s, e) => {
                Application.Exit(); // Ensure terminal closes when app closes
            };

            // Show user info in header
            lblUserName.Text = AppSession.CurrentUser?.HoTen ?? "Quản lý";
            lblVaiTro.Text = AppSession.CurrentUser?.VaiTro ?? "";

            // Hide TaiKhoan tab if not manager
            if (!AppSession.IsManager)
                tabControl.TabPages.Remove(tabTaiKhoan);
        }
    }
}
