using DHN_WF.Models;
using DHN_WF.Services;
using DHN_WF.CustomUI;

namespace DHN_WF.Controls
{
    public partial class TaoDuLieuControl : UserControl
    {
        private readonly ApiService _api = new ApiService();
        private List<KyDocModel> _kyDocs = new();
        private string? _selectedFilePath;

        public TaoDuLieuControl()
        {
            InitializeComponent();
            DHN_WF.CustomUI.UIConstants.StyleModernGrid(this.dgvData);
            this.Load += async (s, e) => await LoadKyDocs();
        }

        private async Task LoadKyDocs()
        {
            try
            {
                _kyDocs = await _api.GetKyDocAsync();
                cboKy.Items.Clear();
                foreach (var k in _kyDocs)
                    cboKy.Items.Add(k);
                if (cboKy.Items.Count > 0)
                    cboKy.SelectedIndex = 0;
            }
            catch (Exception ex)
            {
                NotificationManager.Show("Lỗi", "Lỗi tải kỳ đọc: " + ex.Message, NotificationType.Error);
            }
        }

        private void BtnChonFile_Click(object sender, EventArgs e)
        {
            using var dlg = new OpenFileDialog
            {
                Filter = "Excel/CSV files|*.xlsx;*.xls;*.csv",
                Title = "Chọn File Biến Động"
            };
            if (dlg.ShowDialog() == DialogResult.OK)
            {
                _selectedFilePath = dlg.FileName;
                txtFilePath.Text = Path.GetFileName(_selectedFilePath);
                lblUploadMsg.Text = $"Đã chọn: {Path.GetFileName(_selectedFilePath)}";
                lblUploadMsg.ForeColor = Color.FromArgb(46, 125, 50);
                lblUploadMsg.Visible = true;
                btnThemFile.Enabled = true;
            }
        }

        private async void BtnThemFile_Click(object sender, EventArgs e)
        {
            if (_selectedFilePath == null) { NotificationManager.Show("Thông báo", "Vui lòng chọn file trước!", NotificationType.Warning); return; }
            if (cboKy.SelectedItem is not KyDocModel ky) { NotificationManager.Show("Thông báo", "Vui lòng chọn kỳ đọc!", NotificationType.Warning); return; }

            btnThemFile.Enabled = false;
            btnThemFile.Text = "Đang import...";
            try
            {
                var msg = await _api.UploadBienDongAsync(_selectedFilePath, ky.MaKyDoc);
                lblUploadMsg.Text = "✅ " + msg;
                lblUploadMsg.ForeColor = Color.FromArgb(46, 125, 50);
                lblUploadMsg.Visible = true;
                _selectedFilePath = null;
                txtFilePath.Text = "";
                await XemDuLieu();
            }
            catch (Exception ex)
            {
                lblUploadMsg.Text = "❌ Lỗi: " + ex.Message;
                lblUploadMsg.ForeColor = Color.FromArgb(183, 28, 28);
                lblUploadMsg.Visible = true;
            }
            finally
            {
                btnThemFile.Text = "Thêm File Biến Động";
                btnThemFile.Enabled = _selectedFilePath != null;
            }
        }

        private async void BtnXem_Click(object sender, EventArgs e)
        {
            await XemDuLieu();
        }

        private async Task XemDuLieu()
        {
            if (cboKy.SelectedItem is not KyDocModel ky) return;
            btnXem.Text = "Đang tải...";
            btnXem.Enabled = false;
            dgvData.Rows.Clear();
            lblThongKe.Text = "";

            try
            {
                var dotTask = _api.GetThongKeDotAsync(ky.MaKyDoc);
                var tkTask = _api.GetThongKeAsync(ky.MaKyDoc);
                await Task.WhenAll(dotTask, tkTask);

                var dots = await dotTask;
                var tk = await tkTask;

                // Populate grid
                dgvData.Rows.Clear();
                foreach (var row in dots)
                {
                    dgvData.Rows.Add(
                        "▶",
                        row.MaDot,
                        row.TongHDKyTruoc.ToString("N0"),
                        row.TongBD.ToString("N0"),
                        row.TongTD.ToString("N0"),
                        row.NgayLapBD ?? "-",
                        row.NgayLapTD ?? "-"
                    );
                }

                // Thong ke label
                if (tk != null)
                    lblThongKe.Text = $"Tổng Số: {tk.TongSo}  |  Đã Đọc: {tk.DaDoc}  |  Chưa Đọc: {tk.ChuaDoc}";
            }
            catch (Exception ex)
            {
                NotificationManager.Show("Lỗi", "Lỗi tải dữ liệu: " + ex.Message, NotificationType.Error);
            }
            finally
            {
                btnXem.Text = "Xem Dữ Liệu";
                btnXem.Enabled = true;
            }
        }
    }
}
