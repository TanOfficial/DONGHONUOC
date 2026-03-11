using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DONGHONUOC_API.Data;
using DONGHONUOC_API.Models;

namespace DONGHONUOC_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DocChiSoController : ControllerBase
    {
        private readonly AppDbContext _db;

        public DocChiSoController(AppDbContext db)
        {
            _db = db;
        }

        [HttpGet("ky/{maKyDoc}")]
        public async Task<ActionResult<List<DocSoItemResponse>>> GetByKy(int maKyDoc, [FromQuery] string? maLoTrinh = null, [FromQuery] int? trangThai = null, [FromQuery] string? search = null, [FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 0)
        {
            var lichDoc = await _db.KyDoc.FindAsync(maKyDoc);
            if (lichDoc == null) return NotFound("Không tìm thấy kỳ đọc");

            string kyStr = lichDoc.Ky.ToString("D2");
            var query = _db.DocChiSo.Where(d => d.Nam == lichDoc.Nam && d.Ky == kyStr);

            if (!string.IsNullOrEmpty(maLoTrinh))
                query = query.Where(d => d.MaLoTrinh == maLoTrinh);

            if (trangThai.HasValue)
            {
                if (trangThai == 0)
                    query = query.Where(d => d.TrangThai == 0 || d.TrangThai == null);
                else
                    query = query.Where(d => d.TrangThai == trangThai.Value);
            }

            if (!string.IsNullOrEmpty(search))
            {
                search = search.ToLower();
                // Chỉ tìm theo MaDanhBo (DanhBa) - TenKhachHang là [NotMapped] nên EF Core không dịch được sang SQL
                query = query.Where(d => d.MaDanhBo.ToLower().Contains(search) || d.DiaChi!.ToLower().Contains(search));
            }

            var pagedQuery = query.OrderBy(d => d.MaLoTrinh).ThenBy(d => d.MaDanhBo).AsQueryable();
            if (pageSize > 0)
            {
                pagedQuery = pagedQuery.Skip((pageNumber - 1) * pageSize).Take(pageSize);
            }

            var result = await pagedQuery.Select(d => new DocSoItemResponse
            {
                MaDanhBo = d.MaDanhBo,
                HoTen = d.TenKhachHang ?? "",
                DiaChi = d.DiaChi,
                MaLoTrinh = d.MaLoTrinh,
                Hieu = d.Hieu,
                Co = d.Co,
                SoThan = d.SoThan,
                ViTri = d.ViTri,
                SoDienThoai = d.SoDienThoaiKH,
                GB = d.GB,
                DM = d.DM,
                DMHN = d.DMHN,
                DocChiSoId = !string.IsNullOrEmpty(d.ID) ? d.ID.GetHashCode() : 0, 
                MaKyDoc = maKyDoc,
                ChiSoCu = d.ChiSoCu ?? 0,
                ChiSoMoi = d.ChiSoMoi,
                TieuThu = d.TieuThu,
                MaCode = d.MaCode ?? "40",
                TBTT = d.TBTT ?? 0,
                TrangThai = d.TrangThai ?? 0,
                GhiChu = d.GhiChu,
                HinhAnh = d.HinhAnh,
                NgayDoc = d.NgayDoc
            }).ToListAsync();

            return result;
        }

        // ====== TÌM KIẾM TOÀN BỘ (Không lọc theo kỳ) ======
        [HttpGet("search")]
        public async Task<ActionResult<List<DocSoItemResponse>>> SearchAllKy(
            [FromQuery] string q = "",
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 50)
        {
            if (string.IsNullOrWhiteSpace(q))
                return BadRequest("Cần nhập từ khóa tìm kiếm");

            var keyword = q.ToLower().Trim();

            // Tìm trong toàn bộ bảng DocSo, lấy bản ghi gần nhất của mỗi DanhBa
            var query = _db.DocChiSo
                .Where(d => d.MaDanhBo.ToLower().Contains(keyword) ||
                            (d.DiaChi != null && d.DiaChi.ToLower().Contains(keyword)))
                .OrderByDescending(d => d.Nam)
                .ThenByDescending(d => d.Ky)
                .ThenBy(d => d.MaDanhBo);

            // Lấy bản ghi mới nhất của mỗi DanhBa (distinct)
            var distinct = await query
                .GroupBy(d => d.MaDanhBo)
                .Select(g => g.First())
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var result = distinct.Select(d => new DocSoItemResponse
            {
                MaDanhBo = d.MaDanhBo,
                HoTen = d.TenKhachHang ?? "",
                DiaChi = d.DiaChi,
                MaLoTrinh = d.MaLoTrinh,
                Hieu = d.Hieu,
                Co = d.Co,
                SoThan = d.SoThan,
                ViTri = d.ViTri,
                SoDienThoai = d.SoDienThoaiKH,
                GB = d.GB,
                DM = d.DM,
                DMHN = d.DMHN,
                DocChiSoId = !string.IsNullOrEmpty(d.ID) ? d.ID.GetHashCode() : 0,
                MaKyDoc = 0, // Không thuộc kỳ cụ thể
                ChiSoCu = d.ChiSoCu ?? 0,
                ChiSoMoi = d.ChiSoMoi,
                TieuThu = d.TieuThu,
                MaCode = d.MaCode ?? "40",
                TBTT = d.TBTT ?? 0,
                TrangThai = d.TrangThai ?? 0,
                GhiChu = d.GhiChu,
                HinhAnh = d.HinhAnh,
                NgayDoc = d.NgayDoc
            }).ToList();

            return result;
        }

        [HttpPost("ghi")]
        public async Task<ActionResult> GhiChiSo([FromBody] GhiChiSoRequest request)
        {
            var lichDoc = await _db.KyDoc.FindAsync(request.MaKyDoc);
            if (lichDoc == null) return NotFound("Không tìm thấy kỳ đọc");

            string kyStr = lichDoc.Ky.ToString("D2");
            var docCS = await _db.DocChiSo.FirstOrDefaultAsync(d => d.MaDanhBo == request.MaDanhBo && d.Nam == lichDoc.Nam && d.Ky == kyStr);

            if (docCS == null) return NotFound("Không tìm thấy danh bộ này trong kỳ");

            docCS.ChiSoMoi = request.ChiSoMoi;
            docCS.MaCode = request.MaCode;
            docCS.GhiChu = request.GhiChu;
            docCS.HinhAnh = request.HinhAnh;
            docCS.NguoiDoc = request.NguoiDoc;
            docCS.NgayDoc = DateTime.Now;
            docCS.TrangThai = 1;
            docCS.TieuThu = request.ChiSoMoi >= docCS.ChiSoCu ? (request.ChiSoMoi - docCS.ChiSoCu) : 0;

            var lichSu = new LichSuDocSo
            {
                MaDanhBo = request.MaDanhBo,
                MaKyDoc = request.MaKyDoc,
                ChiSo = request.ChiSoMoi,
                TieuThu = docCS.TieuThu ?? 0,
                MaCode = request.MaCode,
                HanhDong = "DocMoi",
                NguoiThucHien = request.NguoiDoc,
                ThoiGian = DateTime.Now
            };
            _db.LichSuDocSo.Add(lichSu);

            await _db.SaveChangesAsync();
            return Ok(new { message = "Đã lưu chỉ số thành công!", tieuThu = lichSu.TieuThu });
        }

        [HttpPut("code")]
        public async Task<ActionResult> CapNhatCode([FromBody] CapNhatCodeRequest request)
        {
            var lichDoc = await _db.KyDoc.FindAsync(request.MaKyDoc);
            if (lichDoc == null) return NotFound("Kỳ đọc không tồn tại");
            string kyStr = lichDoc.Ky.ToString("D2");
            var docCS = await _db.DocChiSo.FirstOrDefaultAsync(d => d.MaDanhBo == request.MaDanhBo && d.Nam == lichDoc.Nam && d.Ky == kyStr);
            if (docCS == null) return NotFound(new { message = "Không tìm thấy bản ghi" });

            docCS.MaCode = request.MaCode;
            await _db.SaveChangesAsync();
            return Ok(new { message = "Đã cập nhật code" });
        }

        [HttpPut("note")]
        public async Task<ActionResult> CapNhatGhiChu([FromBody] CapNhatGhiChuRequest request)
        {
            var lichDoc = await _db.KyDoc.FindAsync(request.MaKyDoc);
            if (lichDoc == null) return NotFound("Kỳ đọc không tồn tại");
            string kyStr = lichDoc.Ky.ToString("D2");
            var docCS = await _db.DocChiSo.FirstOrDefaultAsync(d => d.MaDanhBo == request.MaDanhBo && d.Nam == lichDoc.Nam && d.Ky == kyStr);
            if (docCS == null) return NotFound(new { message = "Không tìm thấy bản ghi" });

            docCS.GhiChu = request.GhiChu;
            await _db.SaveChangesAsync();
            return Ok(new { message = "Đã cập nhật ghi chú" });
        }

        [HttpPut("image")]
        public async Task<ActionResult> CapNhatHinhAnh([FromBody] CapNhatHinhAnhRequest request)
        {
            var lichDoc = await _db.KyDoc.FindAsync(request.MaKyDoc);
            if (lichDoc == null) return NotFound("Kỳ đọc không tồn tại");
            string kyStr = lichDoc.Ky.ToString("D2");
            var docCS = await _db.DocChiSo.FirstOrDefaultAsync(d => d.MaDanhBo == request.MaDanhBo && d.Nam == lichDoc.Nam && d.Ky == kyStr);
            if (docCS == null) return NotFound(new { message = "Không tìm thấy bản ghi" });

            docCS.HinhAnh = request.HinhAnh;
            await _db.SaveChangesAsync();
            return Ok(new { message = "Đã cập nhật hình ảnh" });
        }

        [HttpPut("reset")]
        public async Task<ActionResult> HuyDocSo([FromBody] ResetDocSoRequest request)
        {
            var lichDoc = await _db.KyDoc.FindAsync(request.MaKyDoc);
            if (lichDoc == null) return NotFound("Kỳ đọc không tồn tại");
            string kyStr = lichDoc.Ky.ToString("D2");
            var docCS = await _db.DocChiSo.FirstOrDefaultAsync(d => d.MaDanhBo == request.MaDanhBo && d.Nam == lichDoc.Nam && d.Ky == kyStr);
            if (docCS == null) return NotFound(new { message = "Chưa có dữ liệu" });

            docCS.TrangThai = 0;
            docCS.ChiSoMoi = null;
            docCS.TieuThu = 0;

            var lichSu = new LichSuDocSo
            {
                MaDanhBo = request.MaDanhBo,
                MaKyDoc = request.MaKyDoc,
                ChiSo = 0,
                TieuThu = 0,
                MaCode = docCS.MaCode ?? "40",
                HanhDong = "HuyDoc",
                NguoiThucHien = "System",
                ThoiGian = DateTime.Now
            };
            _db.LichSuDocSo.Add(lichSu);

            await _db.SaveChangesAsync();
            return Ok(new { message = "Đã hủy đọc số", data = docCS });
        }

        [HttpGet("lichsu/{maDanhBo}")]
        public async Task<ActionResult<List<LichSuItem>>> GetLichSu(string maDanhBo, [FromQuery] int limit = 3)
        {
            var result = await (from ls in _db.LichSuDocSo
                                join kd in _db.KyDoc on ls.MaKyDoc equals kd.MaKyDoc
                                where ls.MaDanhBo == maDanhBo && ls.HanhDong == "DocMoi"
                                orderby ls.ThoiGian descending
                                select new LichSuItem
                                {
                                    Ky = kd.Ky,
                                    Nam = kd.Nam,
                                    ChiSo = ls.ChiSo,
                                    TieuThu = ls.TieuThu,
                                    MaCode = ls.MaCode,
                                    NgayDoc = ls.ThoiGian
                                })
                               .Take(limit)
                               .ToListAsync();
            return result;
        }

        [HttpGet("kydoc")]
        public async Task<ActionResult<List<KyDoc>>> GetKyDoc()
        {
            return await _db.KyDoc.OrderByDescending(k => k.Nam).ThenByDescending(k => k.Ky).ToListAsync();
        }

        [HttpPost("kydoc")]
        public async Task<ActionResult<KyDoc>> PostKyDoc([FromBody] KyDoc kyDoc)
        {
            _db.KyDoc.Add(kyDoc);
            await _db.SaveChangesAsync();
            return CreatedAtAction(nameof(GetKyDoc), new { id = kyDoc.MaKyDoc }, kyDoc);
        }

        [HttpPut("kydoc/{id}")]
        public async Task<IActionResult> PutKyDoc(int id, [FromBody] KyDoc kyDoc)
        {
            if (id != kyDoc.MaKyDoc) return BadRequest("ID không khớp");
            _db.Entry(kyDoc).State = EntityState.Modified;
            await _db.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("kydoc/{id}")]
        public async Task<IActionResult> DeleteKyDoc(int id)
        {
            var kyDoc = await _db.KyDoc.FindAsync(id);
            if (kyDoc == null) return NotFound("Không tìm thấy kỳ");
            _db.KyDoc.Remove(kyDoc);
            await _db.SaveChangesAsync();
            return Ok("Đã xóa");
        }

        [HttpGet("thongke/{maKyDoc}")]
        public async Task<ActionResult<ThongKeResponse>> ThongKe(int maKyDoc)
        {
            var lichDoc = await _db.KyDoc.FindAsync(maKyDoc);
            if (lichDoc == null) return NotFound("Kỳ đọc không tồn tại");
            string kyStr = lichDoc.Ky.ToString("D2");

            var list = await _db.DocChiSo.Where(d => d.Nam == lichDoc.Nam && d.Ky == kyStr).ToListAsync();
            var daDoc = list.Where(d => d.TrangThai >= 1).ToList();

            return new ThongKeResponse
            {
                TongSo = list.Count,
                DaDoc = daDoc.Count,
                ChuaDoc = list.Count(d => d.TrangThai == 0 || d.TrangThai == null),
                DongHoHong = list.Count(d => d.MaCode == "F"),
                KhoaNuoc = list.Count(d => d.MaCode == "6"),
                NhaTrong = list.Count(d => d.MaCode == "20"),
                TongTieuThu = daDoc.Sum(d => d.TieuThu ?? 0),
                TrungBinhTieuThu = daDoc.Any(d => (d.TieuThu ?? 0) > 0) ? daDoc.Where(d => (d.TieuThu ?? 0) > 0).Average(d => (double)(d.TieuThu ?? 0)) : 0
            };
        }
    }
}
