using DHN_WF.Models;

namespace DHN_WF
{
    public static class AppSession
    {
        public static LoginResponse? CurrentUser { get; set; }

        public static void Clear()
        {
            CurrentUser = null;
        }

        public static bool IsManager => CurrentUser?.VaiTro == "QuanLy";
    }
}
