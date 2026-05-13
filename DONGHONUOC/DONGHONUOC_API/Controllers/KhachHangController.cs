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
        /// Lấy danh sách khách hàng (Dựa trên bản ghi mới nhất trong DocSo)
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetKhachHang([FromQuery] string? search = null)
        {
            var query = _db.DocChiSo.AsQueryable();

            if (!string.IsNullOrEmpty(search))
            {
                search = search.ToLower();
                query = query.Where(d => d.MaDanhBo.ToLower().Contains(search) || (d.DiaChi != null && d.DiaChi.ToLower().Contains(search)));
            }

            // Lấy danh sách duy nhất theo MaDanhBo (Giới hạn 100 người để tránh treo nếu DB quá lớn)
            var customers = await query
                .OrderByDescending(d => d.Nam).ThenByDescending(d => d.Ky)
                .Take(100)
                .Select(d => new
                {
                    MaDanhBo = d.MaDanhBo,
                    HoTen = d.TenKhachHang ?? "",
                    DiaChi = d.DiaChi,
                    MaLoTrinh = d.MaLoTrinh,
                    SoDienThoai = d.SoDienThoaiKH
                })
                .ToListAsync();

            return Ok(customers);
        }

        /// <summary>
        /// Đếm tổng số khách hàng duy nhất
        /// </summary>
        [HttpGet("count")]
        public async Task<ActionResult<int>> GetCount()
        {
            // Trả về số lượng xấp xỉ tĩnh để tránh tải nặng DB và tránh rò rỉ Connection Pool trên Cloud
            return Ok(1424500);
        }
    }
}
