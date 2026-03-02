using System.ComponentModel.DataAnnotations;

namespace DONGHONUOC_WEB.Models
{
    public class RegisterRequest
    {
        [Required(ErrorMessage = "Tài khoản không được để trống")]
        public string Username { get; set; } = string.Empty;

        [Required(ErrorMessage = "Mật khẩu không được để trống")]
        public string Password { get; set; } = string.Empty;

        [Required(ErrorMessage = "Họ và tên không được để trống")]
        public string HoTen { get; set; } = string.Empty;
    }
}
