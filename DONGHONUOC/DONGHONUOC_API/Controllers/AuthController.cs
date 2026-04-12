using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DONGHONUOC_API.Data;
using DONGHONUOC_API.Models;
using System.Security.Cryptography;
using System.Text;
using BCrypt.Net;

namespace DONGHONUOC_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _db;

        public AuthController(AppDbContext db)
        {
            _db = db;
        }

        /// <summary>
        /// Đăng nhập
        /// </summary>
        [HttpPost("login")]
        public async Task<ActionResult<LoginResponse>> Login([FromBody] LoginRequest request)
        {
            var user = await _db.NguoiDung
                .FirstOrDefaultAsync(u => u.Username == request.Username && u.Khoa != true);

            if (user == null)
            {
                return Ok(new LoginResponse { Success = false, Message = "Sai tài khoản hoặc mật khẩu!" });
            }

            bool isValid = false;
            // Check if it is a BCrypt hash (usually starts with $2a$, $2b$, or $2y$)
            if (user.PasswordHash != null && user.PasswordHash.StartsWith("$2") && user.PasswordHash.Length > 50)
            {
                isValid = BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash);
            }
            else
            {
                // Legacy SHA256 verification
                if (user.PasswordHash == HashPasswordLegacy(request.Password))
                {
                    isValid = true;
                    // Auto-upgrade password hash to BCrypt seamlessly
                    user.PasswordHash = HashPassword(request.Password);
                    await _db.SaveChangesAsync();
                }
            }

            if (!isValid)
            {
                return Ok(new LoginResponse
                {
                    Success = false,
                    Message = "Sai tài khoản hoặc mật khẩu!"
                });
            }

            return Ok(new LoginResponse
            {
                Success = true,
                Message = "Đăng nhập thành công",
                Username = user.Username,
                HoTen = user.HoTen,
                VaiTro = user.VaiTro,
                Avatar = user.Avatar
            });
        }

        /// <summary>
        /// Cập nhật Avatar
        /// </summary>
        [HttpPost("avatar")]
        public async Task<ActionResult<bool>> UpdateAvatar([FromBody] UpdateAvatarRequest request)
        {
            Console.WriteLine($"[UpdateAvatar] Request received for User: {request.Username}");
            
            if (string.IsNullOrEmpty(request.Username))
            {
                Console.WriteLine("[UpdateAvatar] Username is empty!");
                return BadRequest("Username is required");
            }

            var user = await _db.NguoiDung.FirstOrDefaultAsync(u => u.Username == request.Username);
            if (user == null)
            {
                Console.WriteLine($"[UpdateAvatar] User not found: {request.Username}");
                return NotFound("Không tìm thấy người dùng!");
            }
            
            Console.WriteLine($"[UpdateAvatar] Updating avatar for {request.Username}...");

            user.Avatar = request.AvatarBase64;
            await _db.SaveChangesAsync();

            return Ok(true);
        }

        /// <summary>
        /// Đăng ký tài khoản mới (Có thể cấp luôn quyền Quản Lý nếu người tạo là Admin, mặc định là NhanVien)
        /// </summary>
        [HttpPost("register")]
        public async Task<ActionResult<LoginResponse>> Register([FromBody] RegisterRequest request)
        {
            // Kiểm tra username đã tồn tại
            var exists = await _db.NguoiDung.AnyAsync(u => u.Username == request.Username);
            if (exists)
            {
                return Ok(new LoginResponse
                {
                    Success = false,
                    Message = "Tên đăng nhập đã tồn tại!"
                });
            }

            // By default assign NhanVien, unless a specific Role (VaiTro) was requested
            var assignedRole = !string.IsNullOrEmpty(request.VaiTro) ? request.VaiTro : "NhanVien"; 
            
            var user = new NguoiDung
            {
                Username = request.Username,
                PasswordHash = HashPassword(request.Password),
                HoTen = request.HoTen,
                VaiTro = assignedRole,
                Khoa = false
            };

            try
            {
                _db.NguoiDung.Add(user);
                await _db.SaveChangesAsync();

                return Ok(new LoginResponse
                {
                    Success = true,
                    Message = "Đăng ký thành công!",
                    Username = user.Username,
                    HoTen = user.HoTen,
                    VaiTro = user.VaiTro
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Register] ERROR: {ex.Message}");
                if (ex.InnerException != null) Console.WriteLine($"[Register] Inner ERROR: {ex.InnerException.Message}");
                return Ok(new LoginResponse
                {
                    Success = false,
                    Message = "Lỗi hệ thống khi đăng ký tài khoản mới: " + ex.Message
                });
            }
        }

        private static string HashPassword(string password)
        {
            return BCrypt.Net.BCrypt.HashPassword(password, 12);
        }

        private static string HashPasswordLegacy(string password)
        {
            var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(password));
            return Convert.ToHexStringLower(bytes);
        }

        /// <summary>
        /// Lấy danh sách toàn bộ người dùng (Dành cho Web Admin)
        /// </summary>
        [HttpGet("users")]
        public async Task<ActionResult<IEnumerable<object>>> GetAllUsers()
        {
            var users = await _db.NguoiDung
                .Select(u => new 
                {
                    u.Username,
                    u.HoTen,
                    u.VaiTro,
                    u.Khoa
                })
                .ToListAsync();

            return Ok(users);
        }

        /// <summary>
        /// Cấp quyền / Đổi mật khẩu / Sửa thông tin tài khoản cho Admin
        /// </summary>
        [HttpPut("users/{username}")]
        public async Task<ActionResult<bool>> UpdateUserAdmin(string username, [FromBody] UpdateUserAdminRequest request)
        {
            var user = await _db.NguoiDung.FirstOrDefaultAsync(u => u.Username == username);
            if (user == null)
            {
                return NotFound("Không tìm thấy người dùng");
            }

            if (!string.IsNullOrEmpty(request.HoTen)) user.HoTen = request.HoTen;
            if (!string.IsNullOrEmpty(request.VaiTro)) user.VaiTro = request.VaiTro;
            if (request.Khoa.HasValue) user.Khoa = request.Khoa;
            
            if (!string.IsNullOrEmpty(request.Password)) 
            {
                user.PasswordHash = HashPassword(request.Password);
            }

            await _db.SaveChangesAsync();
            return Ok(true);
        }
    }

    public class UpdateUserAdminRequest 
    {
        public string? HoTen { get; set; }
        public string? VaiTro { get; set; } // "QuanLy" hoặc "NhanVien"
        public string? Password { get; set; }
        public bool? Khoa { get; set; }
    }
}
