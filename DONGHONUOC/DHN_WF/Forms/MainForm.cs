using DHN_WF.Controls;

namespace DHN_WF.Forms
{
    public partial class MainForm : Form
    {
        public MainForm()
        {
            InitializeComponent();
            // Show user info in header
            lblUserName.Text = AppSession.CurrentUser?.HoTen ?? "Quản lý";
            lblVaiTro.Text = AppSession.CurrentUser?.VaiTro ?? "";

            // Hide TaiKhoan tab if not manager
            if (!AppSession.IsManager)
                tabControl.TabPages.Remove(tabTaiKhoan);
        }
    }
}
