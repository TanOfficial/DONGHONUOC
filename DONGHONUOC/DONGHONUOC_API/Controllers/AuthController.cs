using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DONGHONUOC_API.Data;
using DONGHONUOC_API.Models;
using System.Security.Cryptography;
using System.Text;

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
            var hash = HashPassword(request.Password);

            var user = await _db.NguoiDung
                .FirstOrDefaultAsync(u => u.Username == request.Username
                                      && u.PasswordHash == hash
                                      && u.TrangThai);

            if (user == null)
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
        /// Đăng ký tài khoản mới
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

            var user = new NguoiDung
            {
                Username = request.Username,
                PasswordHash = HashPassword(request.Password),
                HoTen = request.HoTen,
                VaiTro = "NhanVien",
                TrangThai = true
            };

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

        private static string HashPassword(string password)
        {
            var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(password));
            return Convert.ToHexStringLower(bytes);
        }
    }
}
