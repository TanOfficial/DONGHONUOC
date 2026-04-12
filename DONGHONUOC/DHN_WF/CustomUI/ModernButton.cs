using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Windows.Forms;
using System.ComponentModel;

namespace DHN_WF.CustomUI
{
    public class ModernButton : Button
    {
        private int _borderRadius = 12;
        private Color _originalBackColor;
        private Color _hoverColor = UIConstants.PrimaryHover;
        private Color _pressedColor = UIConstants.PrimaryPressed;
        private bool _isHovering = false;
        private bool _isPressed = false;

        public ModernButton()
        {
            this.FlatStyle = FlatStyle.Flat;
            this.FlatAppearance.BorderSize = 0;
            this.Size = new Size(150, 40);
            this.BackColor = UIConstants.PrimaryColor;
            this.ForeColor = Color.White;
            this.Font = UIConstants.SubHeaderFont;
            this.Cursor = Cursors.Hand;
            _originalBackColor = this.BackColor;

            this.MouseEnter += (s, e) => { _isHovering = true; Invalidate(); };
            this.MouseLeave += (s, e) => { _isHovering = false; Invalidate(); };
            this.MouseDown += (s, e) => { _isPressed = true; Invalidate(); };
            this.MouseUp += (s, e) => { _isPressed = false; Invalidate(); };
        }

        [Category("Appearance")]
        [DefaultValue(12)]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public int BorderRadius
        {
            get => _borderRadius;
            set { _borderRadius = value; Invalidate(); }
        }

        [Category("Appearance")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public Color HoverColor
        {
            get => _hoverColor;
            set { _hoverColor = value; Invalidate(); }
        }

        [Category("Appearance")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public Color PressedColor
        {
            get => _pressedColor;
            set { _pressedColor = value; Invalidate(); }
        }

        public override Color BackColor
        {
            get => base.BackColor;
            set
            {
                base.BackColor = value;
                if (!_isHovering && !_isPressed)
                {
                    _originalBackColor = value;
                }
            }
        }

        private GraphicsPath GetRoundPath(RectangleF rect, int radius)
        {
            float r2 = radius / 2f;
            GraphicsPath path = new GraphicsPath();
            
            // Adjust to draw within bounds preventing clipping
            rect.Width -= 1;
            rect.Height -= 1;

            path.AddArc(rect.X, rect.Y, radius, radius, 180, 90);
            path.AddArc(rect.Right - radius, rect.Y, radius, radius, 270, 90);
            path.AddArc(rect.Right - radius, rect.Bottom - radius, radius, radius, 0, 90);
            path.AddArc(rect.X, rect.Bottom - radius, radius, radius, 90, 90);
            path.CloseFigure();
            return path;
        }

        protected override void OnPaint(PaintEventArgs pevent)
        {
            pevent.Graphics.SmoothingMode = SmoothingMode.AntiAlias;

            // Determine Background Color
            Color drawColor = _originalBackColor;
            if (_isPressed) drawColor = _pressedColor;
            else if (_isHovering) drawColor = _hoverColor;

            RectangleF rectSurface = new RectangleF(0, 0, this.Width, this.Height);
            
            // Background Area
            if (_borderRadius > 2)
            {
                using (GraphicsPath pathSurface = GetRoundPath(rectSurface, _borderRadius))
                using (SolidBrush brushSurface = new SolidBrush(drawColor))
                {
                    // Update the Region for clicking constraints
                    this.Region = new Region(pathSurface);
                    pevent.Graphics.FillPath(brushSurface, pathSurface);
                }
            }
            else
            {
                this.Region = new Region(rectSurface);
                using (SolidBrush brushSurface = new SolidBrush(drawColor))
                {
                    pevent.Graphics.FillRectangle(brushSurface, rectSurface);
                }
            }

            // Draw Text
            TextRenderer.DrawText(
                pevent.Graphics, 
                this.Text, 
                this.Font, 
                this.ClientRectangle, 
                this.ForeColor, 
                TextFormatFlags.HorizontalCenter | TextFormatFlags.VerticalCenter | TextFormatFlags.EndEllipsis
            );
        }
    }
}
