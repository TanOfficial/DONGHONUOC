namespace DHN_WF.Controls
{
    partial class XuLyDuLieuControl
    {
        private System.ComponentModel.IContainer components = null;
        private System.Windows.Forms.Panel panelTop;
        private System.Windows.Forms.Label lblTitle;
        private System.Windows.Forms.ComboBox cboKy;
        private System.Windows.Forms.Label lblKy;
        private DHN_WF.CustomUI.ModernButton btnXem;
        private DHN_WF.CustomUI.ModernButton btnChot;
        private System.Windows.Forms.DataGridView dgvData;
        private System.Windows.Forms.Panel panelBottom;
        private System.Windows.Forms.Label lblThongKe;

        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null)) components.Dispose();
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            this.panelTop = new System.Windows.Forms.Panel();
            this.btnChot = new DHN_WF.CustomUI.ModernButton();
            this.btnXem = new DHN_WF.CustomUI.ModernButton();
            this.lblKy = new System.Windows.Forms.Label();
            this.cboKy = new System.Windows.Forms.ComboBox();
            this.lblTitle = new System.Windows.Forms.Label();
            this.dgvData = new System.Windows.Forms.DataGridView();
            this.panelBottom = new System.Windows.Forms.Panel();
            this.lblThongKe = new System.Windows.Forms.Label();
            this.panelTop.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvData)).BeginInit();
            this.panelBottom.SuspendLayout();
            this.SuspendLayout();
            // 
            // panelTop
            // 
            this.panelTop.BackColor = System.Drawing.Color.White;
            this.panelTop.Controls.Add(this.btnChot);
            this.panelTop.Controls.Add(this.btnXem);
            this.panelTop.Controls.Add(this.lblKy);
            this.panelTop.Controls.Add(this.cboKy);
            this.panelTop.Controls.Add(this.lblTitle);
            this.panelTop.Dock = System.Windows.Forms.DockStyle.Top;
            this.panelTop.Location = new System.Drawing.Point(0, 0);
            this.panelTop.Name = "panelTop";
            this.panelTop.Size = new System.Drawing.Size(950, 60);
            this.panelTop.TabIndex = 0;
            // 
            // btnChot
            // 
            this.btnChot.BackColor = DHN_WF.CustomUI.UIConstants.SuccessColor;
            this.btnChot.ForeColor = System.Drawing.Color.White;
            this.btnChot.HoverColor = DHN_WF.CustomUI.UIConstants.SuccessHover;
            this.btnChot.PressedColor = DHN_WF.CustomUI.UIConstants.SuccessPressed;
            this.btnChot.BorderRadius = 8;
            this.btnChot.Font = new System.Drawing.Font("Segoe UI", 9.5F, System.Drawing.FontStyle.Bold);
            this.btnChot.Location = new System.Drawing.Point(740, 12);
            this.btnChot.Name = "btnChot";
            this.btnChot.Size = new System.Drawing.Size(180, 36);
            this.btnChot.TabIndex = 4;
            this.btnChot.Text = "Chốt Hóa Đơn Kỳ Này";
            this.btnChot.Click += new System.EventHandler(this.BtnChot_Click);
            // 
            // btnXem
            // 
            this.btnXem.BackColor = System.Drawing.Color.FromArgb(245, 247, 250);
            this.btnXem.ForeColor = DHN_WF.CustomUI.UIConstants.PrimaryColor;
            this.btnXem.HoverColor = System.Drawing.Color.FromArgb(227, 242, 253);
            this.btnXem.PressedColor = System.Drawing.Color.FromArgb(187, 222, 251);
            this.btnXem.BorderRadius = 8;
            this.btnXem.Font = new System.Drawing.Font("Segoe UI", 9.5F, System.Drawing.FontStyle.Bold);
            this.btnXem.Location = new System.Drawing.Point(610, 12);
            this.btnXem.Name = "btnXem";
            this.btnXem.Size = new System.Drawing.Size(120, 36);
            this.btnXem.TabIndex = 3;
            this.btnXem.Text = "Tải Dữ Liệu";
            this.btnXem.Click += new System.EventHandler(this.BtnXem_Click);
            // 
            // lblKy
            // 
            this.lblKy.AutoSize = true;
            this.lblKy.Font = new System.Drawing.Font("Segoe UI", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point);
            this.lblKy.Location = new System.Drawing.Point(320, 20);
            this.lblKy.Name = "lblKy";
            this.lblKy.Size = new System.Drawing.Size(55, 19);
            this.lblKy.TabIndex = 2;
            this.lblKy.Text = "Kỳ Đọc:";
            // 
            // cboKy
            // 
            this.cboKy.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboKy.Font = new System.Drawing.Font("Segoe UI", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point);
            this.cboKy.FormattingEnabled = true;
            this.cboKy.Location = new System.Drawing.Point(390, 16);
            this.cboKy.Name = "cboKy";
            this.cboKy.Size = new System.Drawing.Size(200, 28);
            this.cboKy.TabIndex = 1;
            // 
            // lblTitle
            // 
            this.lblTitle.AutoSize = true;
            this.lblTitle.Font = new System.Drawing.Font("Segoe UI", 16F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point);
            this.lblTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(31)))), ((int)(((byte)(41)))), ((int)(((byte)(55)))));
            this.lblTitle.Location = new System.Drawing.Point(20, 14);
            this.lblTitle.Name = "lblTitle";
            this.lblTitle.Size = new System.Drawing.Size(252, 30);
            this.lblTitle.TabIndex = 0;
            this.lblTitle.Text = "XỬ LÝ DỮ LIỆU ĐỌC SỐ";
            // 
            // dgvData
            // 
            this.dgvData.AllowUserToAddRows = false;
            this.dgvData.AllowUserToDeleteRows = false;
            this.dgvData.BackgroundColor = System.Drawing.Color.FromArgb(((int)(((byte)(249)))), ((int)(((byte)(250)))), ((int)(((byte)(251)))));
            this.dgvData.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dgvData.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvData.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvData.Location = new System.Drawing.Point(0, 60);
            this.dgvData.Name = "dgvData";
            this.dgvData.ReadOnly = true;
            this.dgvData.RowTemplate.Height = 30;
            this.dgvData.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvData.Size = new System.Drawing.Size(950, 480);
            this.dgvData.TabIndex = 1;
            this.dgvData.RowPrePaint += new System.Windows.Forms.DataGridViewRowPrePaintEventHandler(this.DgvData_RowPrePaint);
            // 
            // panelBottom
            // 
            this.panelBottom.BackColor = System.Drawing.Color.White;
            this.panelBottom.Controls.Add(this.lblThongKe);
            this.panelBottom.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.panelBottom.Location = new System.Drawing.Point(0, 550);
            this.panelBottom.Name = "panelBottom";
            this.panelBottom.Size = new System.Drawing.Size(950, 50);
            this.panelBottom.TabIndex = 2;
            // 
            // lblThongKe
            // 
            this.lblThongKe.AutoSize = true;
            this.lblThongKe.Font = new System.Drawing.Font("Segoe UI", 11F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point);
            this.lblThongKe.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(17)))), ((int)(((byte)(24)))), ((int)(((byte)(39)))));
            this.lblThongKe.Location = new System.Drawing.Point(20, 15);
            this.lblThongKe.Name = "lblThongKe";
            this.lblThongKe.Size = new System.Drawing.Size(0, 20);
            this.lblThongKe.TabIndex = 0;
            // 
            // XuLyDuLieuControl
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.dgvData);
            this.Controls.Add(this.panelTop);
            this.Controls.Add(this.panelBottom);
            this.Name = "XuLyDuLieuControl";
            this.Size = new System.Drawing.Size(950, 600);
            this.panelTop.ResumeLayout(false);
            this.panelTop.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvData)).EndInit();
            this.panelBottom.ResumeLayout(false);
            this.panelBottom.PerformLayout();
            this.ResumeLayout(false);

        }
    }
}
