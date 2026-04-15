using DHN_WF.Models;
using DHN_WF.Services;
using DHN_WF.CustomUI;

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
                NotificationManager.Show("Lỗi", "Lỗi tải kỳ đọc: " + ex.Message, NotificationType.Error);
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
                NotificationManager.Show("Lỗi", "Lỗi tải dữ liệu: " + ex.Message, NotificationType.Error);
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

            var confirmResult = NotificationManager.Confirm(
                "Xác nhận Chốt Hóa Đơn",
                $"Bạn có chắc chắn muốn CHỐT HÓA ĐƠN TIỀN NƯỚC cho {ky}?\nHệ thống sẽ tính toán tiền ứng với các khách hàng Đã Đọc Số.",
                MessageBoxButtons.YesNo, NotificationType.Warning);

            if (confirmResult != DialogResult.Yes) return;

            btnChot.Enabled = false;
            btnChot.Text = "Đang chốt...";

            try
            {
                var result = await _api.ChotHoaDonThangAsync(ky.MaKyDoc);
                NotificationManager.Show("Hoàn Tất", $"Thành công!\n{result.message}\nTổng tiền: {result.tongTien:N0} VNĐ", NotificationType.Success);
                
                // Reload data to see changes
                BtnXem_Click(this, EventArgs.Empty);
            }
            catch (Exception ex)
            {
                NotificationManager.Show("Lỗi", "Lỗi khi chốt số: " + ex.Message, NotificationType.Error);
            }
            finally
            {
                btnChot.Enabled = true;
                btnChot.Text = "Chốt Hóa Đơn Kỳ Này";
            }
        }

        private async void BtnAI_Click(object sender, EventArgs e)
        {
            if (dgvData.SelectedRows.Count == 0)
            {
                NotificationManager.Show("Thông báo", "Vui lòng chọn một dòng để phân tích!", NotificationType.Warning);
                return;
            }

            if (dgvData.SelectedRows[0].DataBoundItem is DocSoItemResponse row)
            {
                if (string.IsNullOrEmpty(row.HinhAnh))
                {
                    NotificationManager.Show("Lỗi", "Khách hàng này chưa có hình ảnh để phân tích AI.", NotificationType.Error);
                    return;
                }

                btnAI.Enabled = false;
                btnAI.Text = "Đang phân tích...";

                try
                {
                    string? result = await _api.DocSoAIAsync(row.HinhAnh);
                    if (result != null)
                    {
                        NotificationManager.Show("Kết quả AI", 
                            $"Số đọc được từ hình ảnh là: {result}\nChỉ số hiện tại trên hệ thống: {(row.ChiSoMoi?.ToString() ?? "Chưa nhập")}", 
                            NotificationType.Success);
                    }
                    else
                    {
                        NotificationManager.Show("AI thất bại", "AI không thể đọc được số từ hình ảnh này hoặc server AI chưa bật.", NotificationType.Warning);
                    }
                }
                catch (Exception ex)
                {
                    NotificationManager.Show("Lỗi Hệ Thống", "Lỗi khi gọi AI: " + ex.Message, NotificationType.Error);
                }
                finally
                {
                    btnAI.Enabled = true;
                    btnAI.Text = "Phân tích AI";
                }
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
