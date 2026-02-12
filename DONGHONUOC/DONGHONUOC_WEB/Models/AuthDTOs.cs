
namespace DONGHONUOC_WEB.Models
{
    public class LoginRequest
    {
        public string Username { get; set; } = "";
        public string Password { get; set; } = "";
    }

    public class LoginResponse
    {
        public bool Success { get; set; }
        public string? Message { get; set; }
        public string? Username { get; set; }
        public string? HoTen { get; set; }
        public string? VaiTro { get; set; }
        public string? Avatar { get; set; }
    }
}
