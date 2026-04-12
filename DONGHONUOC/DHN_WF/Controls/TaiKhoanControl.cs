using DHN_WF.Models;
using DHN_WF.Services;

namespace DHN_WF.Controls
{
    public partial class TaiKhoanControl : UserControl
    {
        private readonly ApiService _api = new ApiService();
        private bool _isEdit = false;
        private string? _editUsername;

        public TaiKhoanControl()
        {
            InitializeComponent();
            DHN_WF.CustomUI.UIConstants.StyleModernGrid(this.dgvUsers);
            this.Load += async (s, e) => await LoadUsers();

            // Modern text box focus effects
            WireFocusEffects(pnlUsername, txtUsername);
            WireFocusEffects(pnlPassword, txtPassword);
            WireFocusEffects(pnlHoTen, txtHoTen);
            WireFocusEffects(pnlVaiTro, cboVaiTro);
        }

        private void WireFocusEffects(Panel pnl, Control ctrl)
        {
            ctrl.Enter += (s, e) => { pnl.BackColor = Color.FromArgb(59, 130, 246); }; // Blue border
            ctrl.Leave += (s, e) => { pnl.BackColor = Color.FromArgb(209, 213, 219); }; // Gray border
        }

        private async Task LoadUsers()
        {
            try
            {
                var users = await _api.GetUsersAsync();
                dgvUsers.Rows.Clear();
                foreach (var u in users)
                    dgvUsers.Rows.Add(u.Username ?? "", u.HoTen ?? "",
                        (u.VaiTro == "QuanLy" ? "Quản Lý" : u.VaiTro == "NhanVien" ? "Nhân Viên" : u.VaiTro) ?? "");
            }
            catch (Exception ex)
            {
                lblError.Text = "Lỗi tải danh sách: " + ex.Message;
                lblError.Visible = true;
            }
        }

        private void SetEditMode(bool isEdit, string? username = null, string? hoTen = null, string? vaiTro = null)
        {
            _isEdit = isEdit;
            _editUsername = username;
            
            lblFormTitle.Text = isEdit ? "CẬP NHẬT TÀI KHOẢN" : "TẠO MỚI TÀI KHOẢN";
            lblFormTitle.ForeColor = isEdit ? Color.FromArgb(245, 158, 11) : Color.FromArgb(16, 185, 129); // Amber or Emerald

            txtUsername.Text = username ?? "";
            txtUsername.ReadOnly = isEdit;
            txtUsername.BackColor = isEdit ? Color.FromArgb(243, 244, 246) : Color.White;
            txtPassword.Text = "";
            txtHoTen.Text = hoTen ?? "";
            cboVaiTro.SelectedIndex = vaiTro == "QuanLy" ? 1 : 0;
            
            btnHuy.Visible = isEdit;
            btnLuu.Text = isEdit ? "Lưu Cập Nhật" : "Tạo Tài Khoản";
            
            lblError.Visible = false;
            lblSuccess.Visible = false;
        }

        private async void BtnLuu_Click(object sender, EventArgs e)
        {
            lblError.Visible = false;
            lblSuccess.Visible = false;
            string vaiTro = cboVaiTro.SelectedIndex == 1 ? "QuanLy" : "NhanVien";

            if (_isEdit)
            {
                try
                {
                    await _api.UpdateUserAsync(_editUsername!, txtPassword.Text, txtHoTen.Text, vaiTro);
                    ShowMessage("Cập nhật tài khoản thành công!", true);
                    await LoadUsers();
                    SetEditMode(false);
                }
                catch (Exception ex) { ShowMessage("Lỗi kết nối khi lưu: " + ex.Message, false); }
            }
            else
            {
                if (string.IsNullOrWhiteSpace(txtUsername.Text) || string.IsNullOrWhiteSpace(txtPassword.Text) || string.IsNullOrWhiteSpace(txtHoTen.Text))
                { ShowMessage("Vui lòng điền đủ thông tin bắt buộc.", false); return; }
                
                try
                {
                    var (success, msg) = await _api.RegisterUserAsync(txtUsername.Text.Trim(), txtPassword.Text, txtHoTen.Text, vaiTro);
                    if (!success) { ShowMessage(msg, false); return; }
                    
                    ShowMessage("Tạo tài khoản mới thành công!", true);
                    await LoadUsers();
                    SetEditMode(false);
                }
                catch (Exception ex) { ShowMessage("Lỗi kết nối: " + ex.Message, false); }
            }
        }

        private void ShowMessage(string msg, bool success)
        {
            var lbl = success ? lblSuccess : lblError;
            lbl.Text = msg;
            lbl.Visible = true;
        }

        private void BtnHuy_Click(object sender, EventArgs e) => SetEditMode(false);

        private void DgvUsers_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == colEdit.Index && e.RowIndex >= 0)
            {
                var row = dgvUsers.Rows[e.RowIndex];
                string username = row.Cells[0].Value?.ToString() ?? "";
                string hoTen = row.Cells[1].Value?.ToString() ?? "";
                string vaiTroDisplay = row.Cells[2].Value?.ToString() ?? "";
                string vaiTro = vaiTroDisplay == "Quản Lý" ? "QuanLy" : "NhanVien";
                SetEditMode(true, username, hoTen, vaiTro);
            }
        }
    }
}
