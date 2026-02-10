using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DONGHONUOC_API.Data;
using DONGHONUOC_API.Models;

namespace DONGHONUOC_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class KhachHangController : ControllerBase
    {
        private readonly AppDbContext _db;

        public KhachHangController(AppDbContext db)
        {
            _db = db;
        }

        /// <summary>
        /// Lấy danh sách tất cả khách hàng
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<List<KhachHang>>> GetAll(
            [FromQuery] string? maLoTrinh = null,
            [FromQuery] string? search = null)
        {
            var query = _db.KhachHang.AsQueryable();

            if (!string.IsNullOrEmpty(maLoTrinh))
            {
                query = query.Where(k => k.MaLoTrinh == maLoTrinh);
            }

            if (!string.IsNullOrEmpty(search))
            {
                search = search.ToLower();
                query = query.Where(k =>
                    k.MaDanhBo.ToLower().Contains(search) ||
                    k.HoTen.ToLower().Contains(search) ||
                    (k.DiaChi != null && k.DiaChi.ToLower().Contains(search)) ||
                    (k.MaLoTrinh != null && k.MaLoTrinh.ToLower().Contains(search)));
            }

            return await query
                .OrderBy(k => k.MaLoTrinh)
                .ThenBy(k => k.MaDanhBo)
                .ToListAsync();
        }

        /// <summary>
        /// Lấy thông tin 1 khách hàng
        /// </summary>
        [HttpGet("{maDanhBo}")]
        public async Task<ActionResult<KhachHang>> GetOne(string maDanhBo)
        {
            var kh = await _db.KhachHang.FindAsync(maDanhBo);
            if (kh == null) return NotFound(new { message = "Không tìm thấy khách hàng" });
            return kh;
        }

        /// <summary>
        /// Đếm tổng số khách hàng
        /// </summary>
        [HttpGet("count")]
        public async Task<ActionResult<int>> Count()
        {
            return await _db.KhachHang.CountAsync();
        }
    }
}
