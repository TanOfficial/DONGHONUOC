using DHN_WF.Models;
using DHN_WF.Services;

namespace DHN_WF.Controls
{
    public partial class XuLyDuLieuControl : UserControl
    {
        private readonly ApiService _api = new ApiService();
        private List<DocSoItemResponse> _currentData = new();
        private List<KyDocModel> _kyDocs = new();

        public XuLyDuLieuControl()
        {
            InitializeComponent();
            SetupGrid();
            DHN_WF.CustomUI.UIConstants.StyleModernGrid(this.dgvData);
            this.Load += async (s, e) => await LoadKyDocs();
        }

        private void SetupGrid()
        {
            dgvData.AutoGenerateColumns = false;
            dgvData.Columns.Clear();

            dgvData.Columns.Add(new DataGridViewTextBoxColumn { HeaderText = "Danh Bộ", DataPropertyName = "MaDanhBo", Width = 110 });
            dgvData.Columns.Add(new DataGridViewTextBoxColumn { HeaderText = "Khách Hàng", DataPropertyName = "HoTen", Width = 160 });
            dgvData.Columns.Add(new DataGridViewTextBoxColumn { HeaderText = "CS Cũ", DataPropertyName = "ChiSoCu", Width = 70 });
            dgvData.Columns.Add(new DataGridViewTextBoxColumn { HeaderText = "CS Mới", DataPropertyName = "ChiSoMoi", Width = 70 });
            dgvData.Columns.Add(new DataGridViewTextBoxColumn { HeaderText = "Tiêu Thụ", DataPropertyName = "TieuThu", Width = 80 });
            dgvData.Columns.Add(new DataGridViewTextBoxColumn { HeaderText = "Định Mức", DataPropertyName = "DM", Width = 80 });
            dgvData.Columns.Add(new DataGridViewTextBoxColumn { HeaderText = "Giá Biểu", DataPropertyName = "GB", Width = 80 });
            dgvData.Columns.Add(new DataGridViewTextBoxColumn { HeaderText = "Tiền Nước", DataPropertyName = "TienNuoc", Width = 100, DefaultCellStyle = new DataGridViewCellStyle { Format = "N0" } });
            dgvData.Columns.Add(new DataGridViewTextBoxColumn { HeaderText = "Tổng Tiền", DataPropertyName = "TongCong", Width = 120, DefaultCellStyle = new DataGridViewCellStyle { Format = "N0" } });
            dgvData.Columns.Add(new DataGridViewTextBoxColumn { HeaderText = "Trạng Thái", DataPropertyName = "TrangThai", Width = 100 });
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
                MessageBox.Show("Lỗi tải kỳ đọc: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private async void BtnXem_Click(object sender, EventArgs e)
        {
            if (cboKy.SelectedItem is not KyDocModel ky) return;
            
            btnXem.Enabled = false;
            btnXem.Text = "Đang tải...";
            
            try
            {
                _currentData = await _api.GetDocSoByKyAsync(ky.MaKyDoc);
                dgvData.DataSource = _currentData;
                UpdateThongKe();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tải dữ liệu: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                btnXem.Enabled = true;
                btnXem.Text = "Tải Dữ Liệu";
            }
        }

        private async void BtnChot_Click(object sender, EventArgs e)
        {
            if (cboKy.SelectedItem is not KyDocModel ky) return;

            var confirmResult = MessageBox.Show(
                $"Bạn có chắc chắn muốn CHỐT HÓA ĐƠN TIỀN NƯỚC cho {ky}?\nHệ thống sẽ tính toán tiền ứng với các khách hàng Đã Đọc Số.",
                "Xác nhận Chốt Hóa Đơn", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);

            if (confirmResult != DialogResult.Yes) return;

            btnChot.Enabled = false;
            btnChot.Text = "Đang chốt...";

            try
            {
                var result = await _api.ChotHoaDonThangAsync(ky.MaKyDoc);
                MessageBox.Show($"Thành công!\n{result.message}\nTổng tiền: {result.tongTien:N0} VNĐ", "Hoàn Tất", MessageBoxButtons.OK, MessageBoxIcon.Information);
                
                // Reload data to see changes
                BtnXem_Click(this, EventArgs.Empty);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi khi chốt số: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                btnChot.Enabled = true;
                btnChot.Text = "Chốt Hóa Đơn Kỳ Này";
            }
        }

        private void UpdateThongKe()
        {
            if (_currentData == null || !_currentData.Any())
            {
                lblThongKe.Text = "Chưa có dữ liệu...";
                return;
            }

            int total = _currentData.Count;
            int daDoc = _currentData.Count(d => d.TrangThai >= 1);
            double tongTieuThu = _currentData.Sum(d => d.TieuThu ?? 0);
            double tongTien = _currentData.Sum(d => d.TongCong);

            lblThongKe.Text = $"Tổng Danh Bộ: {total} | Đã Ghi Số: {daDoc} | Tiêu Thụ Tổng: {tongTieuThu} m3 | TỔNG DOANH THU KỲ: {tongTien:N0} VNĐ";
        }

        private void DgvData_RowPrePaint(object sender, DataGridViewRowPrePaintEventArgs e)
        {
            if (e.RowIndex < 0 || e.RowIndex >= dgvData.Rows.Count) return;

            if (dgvData.Rows[e.RowIndex].DataBoundItem is DocSoItemResponse item)
            {
                if (item.TrangThai >= 1)
                {
                    // Green text if read
                    dgvData.Rows[e.RowIndex].DefaultCellStyle.ForeColor = Color.FromArgb(16, 185, 129);
                }
                else
                {
                    // Red text if not read
                    dgvData.Rows[e.RowIndex].DefaultCellStyle.ForeColor = Color.FromArgb(239, 68, 68);
                }
            }
        }
    }
}
