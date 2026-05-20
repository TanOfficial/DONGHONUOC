using System;
using System.Drawing;
using System.Windows.Forms;

namespace DHN_WF.CustomUI
{
    public enum NotificationType { Success, Info, Warning, Error }

    public static class NotificationManager
    {
        public static void Show(string title, string message, NotificationType type = NotificationType.Info)
        {
            var icon = type switch {
                NotificationType.Success => MessageBoxIcon.Information,
                NotificationType.Error => MessageBoxIcon.Error,
                NotificationType.Warning => MessageBoxIcon.Warning,
                _ => MessageBoxIcon.Information
            };

            MessageBox.Show(message, title, MessageBoxButtons.OK, icon);
        }

        public static DialogResult Confirm(string title, string message, MessageBoxButtons buttons = MessageBoxButtons.YesNo, NotificationType type = NotificationType.Warning)
        {
            var icon = type switch {
                NotificationType.Warning => MessageBoxIcon.Warning,
                NotificationType.Error => MessageBoxIcon.Error,
                _ => MessageBoxIcon.Question
            };

            return MessageBox.Show(message, title, buttons, icon);
        }
    }
}
