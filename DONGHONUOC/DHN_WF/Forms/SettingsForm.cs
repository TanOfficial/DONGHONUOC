using DHN_WF.Services;
using DHN_WF.CustomUI;

namespace DHN_WF.Forms
{
    public partial class SettingsForm : Form
    {
        public SettingsForm()
        {
            InitializeComponent();
            txtUrl.Text = ApiService.GetBaseUrl();
        }

        private void BtnSave_Click(object sender, EventArgs e)
        {
            string url = txtUrl.Text.Trim();
            if (string.IsNullOrEmpty(url))
            {
                NotificationManager.Show("Lỗi", "Vui lòng nhập URL API.", NotificationType.Error);
                return;
            }

            try
            {
                // Validate URL format
                if (!url.StartsWith("http://") && !url.StartsWith("https://"))
                {
                   url = "http://" + url;
                }
                
                new Uri(url); // Test if valid URI
                
                ApiService.UpdateBaseUrl(url);
                NotificationManager.Show("Thành công", "Đã cập nhật cấu hình API.", NotificationType.Success);
                this.DialogResult = DialogResult.OK;
                this.Close();
            }
            catch (Exception ex)
            {
                NotificationManager.Show("Lỗi", "URL không hợp lệ: " + ex.Message, NotificationType.Error);
            }
        }

        private void BtnCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}
