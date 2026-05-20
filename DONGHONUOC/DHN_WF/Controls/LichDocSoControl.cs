using DHN_WF.Models;
using DHN_WF.Services;
using DHN_WF.CustomUI;

namespace DHN_WF.Controls
{
    public partial class LichDocSoControl : UserControl
    {
        private readonly ApiService _api = new ApiService();
        private List<KyDocModel> _kyDocs = new();
        private KyDocModel? _selectedKy;

        public LichDocSoControl()
        {
            InitializeComponent();
            DHN_WF.CustomUI.UIConstants.StyleModernGrid(this.dgvKyList);
            DHN_WF.CustomUI.UIConstants.StyleModernGrid(this.dgvChiTiet);
            this.Load += async (s, e) => await LoadKyDocs();
        }

        private async Task LoadKyDocs()
        {
            try
            {
                _kyDocs = await _api.GetKyDocAsync();
                dgvKyList.Rows.Clear();
                foreach (var k in _kyDocs)
                {
                    dgvKyList.Rows.Add("►", k.Ky.ToString("D2"), k.Nam, k.TenKyDoc ?? $"Tháng {k.Ky}/{k.Nam}");
                    dgvKyList.Rows[dgvKyList.RowCount - 1].Tag = k;
                }
                // Select first
                if (dgvKyList.Rows.Count > 0)
                {
                    dgvKyList.ClearSelection();
                    dgvKyList.Rows[0].Selected = true;
                    SelectKy(_kyDocs[0], 0);
                }
            }
            catch (Exception ex)
            {
                NotificationManager.Show("Lỗi", "Lỗi tải danh sách kỳ: " + ex.Message, NotificationType.Error);
            }
        }

        private void SelectKy(KyDocModel ky, int rowIndex)
        {
            _selectedKy = ky;
            nudKy.Value = ky.Ky;
            nudNam.Value = ky.Nam;
            dtpTuNgay.Value = DateTime.TryParse(ky.TuNgay, out var d1) ? d1 : DateTime.Today;
            dtpDenNgay.Value = DateTime.TryParse(ky.DenNgay, out var d2) ? d2 : DateTime.Today;
            chkTuNgay.Checked = !string.IsNullOrEmpty(ky.TuNgay);
            chkDenNgay.Checked = !string.IsNullOrEmpty(ky.DenNgay);

            // highlight selected row
            for (int i = 0; i < dgvKyList.Rows.Count; i++)
            {
                bool sel = i == rowIndex;
                dgvKyList.Rows[i].DefaultCellStyle.BackColor = sel ? Color.FromArgb(33, 150, 243) : Color.White;
                dgvKyList.Rows[i].DefaultCellStyle.ForeColor = sel ? Color.White : Color.FromArgb(31, 41, 55);
                dgvKyList.Rows[i].DefaultCellStyle.SelectionBackColor = sel ? Color.FromArgb(33, 150, 243) : Color.FromArgb(227, 242, 253);
                dgvKyList.Rows[i].DefaultCellStyle.SelectionForeColor = sel ? Color.White : Color.Black;
            }

            _ = LoadChiTietDot(ky.MaKyDoc);
        }

        private async Task LoadChiTietDot(int maKyDoc)
        {
            dgvChiTiet.Rows.Clear();
            try
            {
                var dots = await _api.GetChiTietDotAsync(maKyDoc);
                foreach (var d in dots)
                    dgvChiTiet.Rows.Add(d.Dot, d.NgayDoc, d.NgayKiemSoat, d.NgayChuyenListing, d.NgayThuTien, d.KiemTraNgayDoc);
            }
            catch (Exception ex)
            {
                NotificationManager.Show("Lỗi", "Lỗi tải chi tiết đợt: " + ex.Message, NotificationType.Error);
            }
        }

        private void DgvKyList_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex < 0) return;
            var tag = dgvKyList.Rows[e.RowIndex].Tag as KyDocModel;
            if (tag != null) SelectKy(tag, e.RowIndex);
        }

        private async void BtnThem_Click(object sender, EventArgs e)
        {
            if (nudKy.Value < 1 || nudNam.Value < 2000) { NotificationManager.Show("Thông báo", "Vui lòng nhập Kỳ và Năm hợp lệ!", NotificationType.Warning); return; }
            string? tuNgay = chkTuNgay.Checked ? dtpTuNgay.Value.ToString("yyyy-MM-dd") : null;
            string? denNgay = chkDenNgay.Checked ? dtpDenNgay.Value.ToString("yyyy-MM-dd") : null;
            if (tuNgay != null && denNgay != null && tuNgay.CompareTo(denNgay) > 0)
            { NotificationManager.Show("Thông báo", "Từ Ngày phải nhỏ hơn hoặc bằng Đến Ngày!", NotificationType.Warning); return; }
            try
            {
                await _api.CreateKyDocAsync((int)nudKy.Value, (int)nudNam.Value, tuNgay, denNgay);
                NotificationManager.Show("Thành công", "Thêm kỳ đọc thành công!", NotificationType.Success);
                await LoadKyDocs();
            }
            catch (Exception ex) { NotificationManager.Show("Lỗi", "Lỗi khi thêm: " + ex.Message, NotificationType.Error); }
        }

        private async void BtnSua_Click(object sender, EventArgs e)
        {
            if (_selectedKy == null) { NotificationManager.Show("Thông báo", "Vui lòng chọn một kỳ để sửa!", NotificationType.Warning); return; }
            string? tuNgay = chkTuNgay.Checked ? dtpTuNgay.Value.ToString("yyyy-MM-dd") : null;
            string? denNgay = chkDenNgay.Checked ? dtpDenNgay.Value.ToString("yyyy-MM-dd") : null;
            if (tuNgay != null && denNgay != null && tuNgay.CompareTo(denNgay) > 0)
            { NotificationManager.Show("Thông báo", "Từ Ngày phải nhỏ hơn hoặc bằng Đến Ngày!", NotificationType.Warning); return; }
            try
            {
                await _api.UpdateKyDocAsync(_selectedKy.MaKyDoc, (int)nudKy.Value, (int)nudNam.Value, tuNgay, denNgay);
                NotificationManager.Show("Thành công", "Cập nhật kỳ đọc thành công!", NotificationType.Success);
                await LoadKyDocs();
            }
            catch (Exception ex) { NotificationManager.Show("Lỗi", "Lỗi khi cập nhật: " + ex.Message, NotificationType.Error); }
        }

        private async void BtnXoa_Click(object sender, EventArgs e)
        {
            if (_selectedKy == null) { NotificationManager.Show("Thông báo", "Vui lòng chọn một kỳ để xóa!", NotificationType.Warning); return; }
            if (NotificationManager.Confirm("Xác nhận xóa", "Bạn có chắc chắn muốn xóa kỳ đọc này?\nToàn bộ dữ liệu đọc số trong kỳ này có thể bị ảnh hưởng.",
                MessageBoxButtons.YesNo, NotificationType.Warning) != DialogResult.Yes) return;
            try
            {
                await _api.DeleteKyDocAsync(_selectedKy.MaKyDoc);
                NotificationManager.Show("Thành công", "Xóa thành công!", NotificationType.Success);
                _selectedKy = null;
                dgvChiTiet.Rows.Clear();
                await LoadKyDocs();
            }
            catch (Exception ex) { NotificationManager.Show("Lỗi", "Lỗi khi xóa: " + ex.Message, NotificationType.Error); }
        }

        private void BtnMoi_Click(object sender, EventArgs e)
        {
            _selectedKy = null;
            nudKy.Value = 1;
            nudNam.Value = DateTime.Today.Year;
            chkTuNgay.Checked = false;
            chkDenNgay.Checked = false;
            dtpTuNgay.Value = DateTime.Today;
            dtpDenNgay.Value = DateTime.Today;
            dgvKyList.ClearSelection();
        }
    }
}
