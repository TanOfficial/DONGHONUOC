using System;
using System.Drawing;
using System.Windows.Forms;

namespace DHN_WF.CustomUI
{
    public static class UIConstants
    {
        // Colors
        public static readonly Color PrimaryColor = Color.FromArgb(33, 150, 243);      // MUI Blue 500
        public static readonly Color PrimaryHover = Color.FromArgb(30, 136, 229);      // MUI Blue 600
        public static readonly Color PrimaryPressed = Color.FromArgb(21, 101, 192);    // MUI Blue 800
        
        public static readonly Color SuccessColor = Color.FromArgb(76, 175, 80);       // MUI Green 500
        public static readonly Color SuccessHover = Color.FromArgb(67, 160, 71);       // MUI Green 600
        public static readonly Color SuccessPressed = Color.FromArgb(46, 125, 50);     // MUI Green 800

        public static readonly Color DangerColor = Color.FromArgb(244, 67, 54);        // MUI Red 500
        public static readonly Color DangerHover = Color.FromArgb(229, 57, 53);        // MUI Red 600
        public static readonly Color DangerPressed = Color.FromArgb(198, 40, 40);      // MUI Red 800

        public static readonly Color SurfaceColor = Color.White;
        public static readonly Color BackgroundColor = Color.FromArgb(245, 247, 250);
        
        public static readonly Color TextPrimary = Color.FromArgb(33, 33, 33);         // Gray 900
        public static readonly Color TextSecondary = Color.FromArgb(117, 117, 117);    // Gray 600
        public static readonly Color TextWhite = Color.White;

        public static readonly Color BorderColor = Color.FromArgb(224, 224, 224);      // Gray 300
        public static readonly Color GridHeaderBackground = Color.FromArgb(237, 242, 247); // Light gray-blue
        public static readonly Color GridRowAlternate = Color.FromArgb(250, 250, 250);

        // Notification Colors (30% Alpha borders)
        public static readonly Color InfoBorder = Color.FromArgb(77, 33, 150, 243);
        public static readonly Color SuccessBorder = Color.FromArgb(77, 76, 175, 80);
        public static readonly Color WarningBorder = Color.FromArgb(77, 255, 152, 0);
        public static readonly Color DangerBorder = Color.FromArgb(77, 244, 67, 54);
        public static readonly Color NotificationBg = Color.FromArgb(240, 255, 255, 255); // Semi-transparent white

        // Fonts
        public static readonly Font HeaderFont = new Font("Segoe UI", 12F, FontStyle.Bold);
        public static readonly Font SubHeaderFont = new Font("Segoe UI", 10F, FontStyle.Bold);
        public static readonly Font NormalFont = new Font("Segoe UI", 9.5F, FontStyle.Regular);
        public static readonly Font SmallFont = new Font("Segoe UI", 8.5F, FontStyle.Regular);
        
        // DataGridView Styling Utility
        public static void StyleModernGrid(DataGridView grid)
        {
            grid.BackgroundColor = SurfaceColor;
            grid.BorderStyle = BorderStyle.None;
            grid.CellBorderStyle = DataGridViewCellBorderStyle.SingleHorizontal;
            grid.ColumnHeadersBorderStyle = DataGridViewHeaderBorderStyle.None;
            grid.EnableHeadersVisualStyles = false;
            
            grid.ColumnHeadersDefaultCellStyle.BackColor = GridHeaderBackground;
            grid.ColumnHeadersDefaultCellStyle.ForeColor = TextPrimary;
            grid.ColumnHeadersDefaultCellStyle.Font = SubHeaderFont;
            grid.ColumnHeadersDefaultCellStyle.SelectionBackColor = GridHeaderBackground;
            grid.ColumnHeadersDefaultCellStyle.SelectionForeColor = TextPrimary;
            grid.ColumnHeadersDefaultCellStyle.Padding = new Padding(6, 10, 6, 10);
            grid.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.EnableResizing;
            grid.ColumnHeadersHeight = 45;

            grid.DefaultCellStyle.BackColor = SurfaceColor;
            grid.DefaultCellStyle.ForeColor = TextPrimary;
            grid.DefaultCellStyle.Font = NormalFont;
            grid.DefaultCellStyle.SelectionBackColor = Color.FromArgb(227, 242, 253); // Light blue selection
            grid.DefaultCellStyle.SelectionForeColor = TextPrimary;
            grid.DefaultCellStyle.Padding = new Padding(10, 8, 10, 8);
            
            grid.AlternatingRowsDefaultCellStyle.BackColor = GridRowAlternate;
            
            grid.RowTemplate.Height = 45;
            grid.RowHeadersVisible = false;
            grid.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grid.GridColor = BorderColor;
        }
    }
}
