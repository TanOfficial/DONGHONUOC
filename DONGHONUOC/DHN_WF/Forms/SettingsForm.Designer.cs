namespace DHN_WF.Forms
{
    partial class SettingsForm
    {
        private System.ComponentModel.IContainer components = null;

        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null)) components.Dispose();
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            this.lblInfo = new Label();
            this.txtUrl = new TextBox();
            this.btnSave = new DHN_WF.CustomUI.ModernButton();
            this.btnCancel = new DHN_WF.CustomUI.ModernButton();
            this.SuspendLayout();

            // lblInfo
            this.lblInfo.Text = "Địa chỉ API (IPv4/Domain):";
            this.lblInfo.Location = new Point(20, 20);
            this.lblInfo.Size = new Size(260, 20);
            this.lblInfo.Font = new Font("Segoe UI", 9, FontStyle.Bold);

            // txtUrl
            this.txtUrl.Location = new Point(20, 45);
            this.txtUrl.Size = new Size(340, 25);
            this.txtUrl.Font = new Font("Segoe UI", 10);
            this.txtUrl.PlaceholderText = "Ví dụ: 192.168.1.169:5000";

            // btnSave
            this.btnSave.Text = "Lưu cấu hình";
            this.btnSave.Location = new Point(200, 90);
            this.btnSave.Size = new Size(160, 35);
            this.btnSave.BackColor = Color.FromArgb(33, 150, 243);
            this.btnSave.ForeColor = Color.White;
            this.btnSave.Font = new Font("Segoe UI", 9, FontStyle.Bold);
            this.btnSave.Cursor = Cursors.Hand;
            this.btnSave.Click += new EventHandler(this.BtnSave_Click);

            // btnCancel
            this.btnCancel.Text = "Hủy";
            this.btnCancel.Location = new Point(110, 90);
            this.btnCancel.Size = new Size(80, 35);
            this.btnCancel.BackColor = Color.FromArgb(156, 163, 175);
            this.btnCancel.ForeColor = Color.White;
            this.btnSave.Font = new Font("Segoe UI", 9);
            this.btnCancel.Cursor = Cursors.Hand;
            this.btnCancel.Click += new EventHandler(this.BtnCancel_Click);

            // SettingsForm
            this.ClientSize = new Size(380, 145);
            this.Text = "Cài đặt Kết nối API";
            this.FormBorderStyle = FormBorderStyle.FixedDialog;
            this.StartPosition = FormStartPosition.CenterParent;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.BackColor = Color.White;
            this.Controls.Add(this.lblInfo);
            this.Controls.Add(this.txtUrl);
            this.Controls.Add(this.btnSave);
            this.Controls.Add(this.btnCancel);
            this.ResumeLayout(false);
            this.PerformLayout();
        }

        private Label lblInfo;
        private TextBox txtUrl;
        private DHN_WF.CustomUI.ModernButton btnSave;
        private DHN_WF.CustomUI.ModernButton btnCancel;
    }
}
