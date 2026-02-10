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

        /// <summary>
        /// Lấy danh sách đọc số theo kỳ (gồm thông tin KH)
        /// </summary>
        [HttpGet("ky/{maKyDoc}")]
        public async Task<ActionResult<List<DocSoItemResponse>>> GetByKy(
            int maKyDoc,
            [FromQuery] string? maLoTrinh = null,
            [FromQuery] int? trangThai = null,
            [FromQuery] string? search = null)
        {
            // 1. Lấy tất cả khách hàng (LEFT JOIN DocChiSo hiện tại)
            // 2. Lấy chỉ số mới nhất của kỳ trước (prev) để làm ChiSoCu dự kiến
            var query = from kh in _db.KhachHang
                        join dc in _db.DocChiSo.Where(d => d.MaKyDoc == maKyDoc)
                        on kh.MaDanhBo equals dc.MaDanhBo into gj
                        from dc in gj.DefaultIfEmpty()
                        let prev = _db.DocChiSo
                                     .Where(p => p.MaDanhBo == kh.MaDanhBo && p.MaKyDoc < maKyDoc && p.TrangThai >= 1)
                                     .OrderByDescending(p => p.MaKyDoc)
                                     .FirstOrDefault()
                        select new { kh, dc, prev };

            if (!string.IsNullOrEmpty(maLoTrinh))
                query = query.Where(x => x.kh.MaLoTrinh == maLoTrinh);

            if (trangThai.HasValue)
            {
                if (trangThai == 0)
                    query = query.Where(x => x.dc == null || x.dc.TrangThai == 0);
                else
                    query = query.Where(x => x.dc != null && x.dc.TrangThai == trangThai.Value);
            }

            if (!string.IsNullOrEmpty(search))
            {
                search = search.ToLower();
                query = query.Where(x =>
                    x.kh.MaDanhBo.ToLower().Contains(search) ||
                    x.kh.HoTen.ToLower().Contains(search) ||
                    (x.kh.DiaChi != null && x.kh.DiaChi.ToLower().Contains(search)));
            }

            var result = await query
                .OrderBy(x => x.kh.MaLoTrinh)
                .ThenBy(x => x.kh.MaDanhBo)
                .Select(x => new DocSoItemResponse
                {
                    MaDanhBo = x.kh.MaDanhBo,
                    HoTen = x.kh.HoTen,
                    DiaChi = x.kh.DiaChi,
                    DiaChiDHN = x.kh.DiaChiDHN,
                    MaLoTrinh = x.kh.MaLoTrinh,
                    Hieu = x.kh.Hieu,
                    Co = x.kh.Co,
                    SoThan = x.kh.SoThan,
                    ViTri = x.kh.ViTri,
                    SoDienThoai = x.kh.SoDienThoai,
                    GB = x.kh.GB,
                    DM = x.kh.DM,
                    DMHN = x.kh.DMHN,
                    // Nếu đã có bản ghi -> dùng ID bản ghi. Nếu chưa -> 0
                    DocChiSoId = x.dc != null ? x.dc.ID : 0,
                    MaKyDoc = maKyDoc, 
                    
                    // Ưu tiên: 1. Bản ghi hiện tại -> 2. Kỳ trước -> 3. Chỉ số gốc ở KH -> 4. 0
                    ChiSoCu = x.dc != null ? x.dc.ChiSoCu : (x.prev != null && x.prev.ChiSoMoi.HasValue ? x.prev.ChiSoMoi.Value : (x.kh.ChiSo ?? 0)),
                    
                    ChiSoMoi = x.dc != null ? x.dc.ChiSoMoi : null,
                    TieuThu = x.dc != null ? x.dc.TieuThu : null,
                    MaCode = x.dc != null ? x.dc.MaCode : "40",
                    TBTT = x.dc != null ? x.dc.TBTT : 0,
                    TrangThai = x.dc != null ? x.dc.TrangThai : 0,
                    GhiChu = x.dc != null ? x.dc.GhiChu : null,
                    TinhTrang = x.dc != null ? x.dc.TinhTrang : null,
                    HinhAnh = x.dc != null ? x.dc.HinhAnh : null,
                    NgayDoc = x.dc != null ? x.dc.NgayDoc : null
                })
                .ToListAsync();

            return result;
        }

        /// <summary>
        /// Ghi chỉ số nước
        /// </summary>
        [HttpPost("ghi")]
        public async Task<ActionResult> GhiChiSo([FromBody] GhiChiSoRequest request)
        {
            var docCS = await _db.DocChiSo
                .FirstOrDefaultAsync(d => d.MaDanhBo == request.MaDanhBo && d.MaKyDoc == request.MaKyDoc);

            if (docCS == null)
            {
                // Tự động tạo mới nếu chưa có (Lazy Initialization)
                // Lấy chỉ số mới nhất của kỳ trước đó làm chỉ số cũ
                var lastReading = await _db.DocChiSo
                    .Where(d => d.MaDanhBo == request.MaDanhBo && d.TrangThai >= 1)
                    .OrderByDescending(d => d.MaKyDoc)
                    .FirstOrDefaultAsync();

                int chiSoCu = lastReading != null && lastReading.ChiSoMoi.HasValue ? lastReading.ChiSoMoi.Value : 0;

                docCS = new DocChiSo
                {
                    MaDanhBo = request.MaDanhBo,
                    MaKyDoc = request.MaKyDoc,
                    ChiSoCu = chiSoCu,
                    TBTT = 0,
                    TrangThai = 0,
                    MaCode = "40" // Mặc định
                };

                _db.DocChiSo.Add(docCS);
            }

            // Cập nhật chỉ số
            docCS.ChiSoMoi = request.ChiSoMoi;
            docCS.MaCode = request.MaCode;
            docCS.GhiChu = request.GhiChu;
            docCS.TinhTrang = request.TinhTrang;
            docCS.HinhAnh = request.HinhAnh;
            docCS.NguoiDoc = request.NguoiDoc;
            docCS.NgayDoc = DateTime.Now;
            docCS.TrangThai = 1; // Đã đọc

            // Lưu lịch sử
            var lichSu = new LichSuDocSo
            {
                MaDanhBo = request.MaDanhBo,
                MaKyDoc = request.MaKyDoc,
                ChiSo = request.ChiSoMoi,
                TieuThu = request.ChiSoMoi > docCS.ChiSoCu ? request.ChiSoMoi - docCS.ChiSoCu : 0,
                MaCode = request.MaCode,
                HanhDong = "DocMoi",
                NguoiThucHien = request.NguoiDoc,
                ThoiGian = DateTime.Now
            };
            _db.LichSuDocSo.Add(lichSu);

            await _db.SaveChangesAsync();

            return Ok(new { message = "Đã lưu chỉ số thành công!", tieuThu = lichSu.TieuThu });
        }

        /// <summary>
        /// Cập nhật code cho khách hàng
        /// </summary>
        [HttpPut("code")]
        public async Task<ActionResult> CapNhatCode([FromBody] CapNhatCodeRequest request)
        {
            var docCS = await _db.DocChiSo
                .FirstOrDefaultAsync(d => d.MaDanhBo == request.MaDanhBo && d.MaKyDoc == request.MaKyDoc);

            if (docCS == null)
                return NotFound(new { message = "Không tìm thấy bản ghi" });

            docCS.MaCode = request.MaCode;
            await _db.SaveChangesAsync();

            return Ok(new { message = "Đã cập nhật code" });
        }

        /// <summary>
        /// Lấy lịch sử đọc số (3 kỳ gần nhất)
        /// </summary>
        [HttpGet("lichsu/{maDanhBo}")]
        public async Task<ActionResult<List<LichSuItem>>> GetLichSu(string maDanhBo, [FromQuery] int limit = 3)
        {
            var result = await (from dc in _db.DocChiSo
                                join kd in _db.KyDoc on dc.MaKyDoc equals kd.MaKyDoc
                                where dc.MaDanhBo == maDanhBo && dc.TrangThai >= 1
                                orderby kd.Nam descending, kd.Ky descending
                                select new LichSuItem
                                {
                                    Ky = kd.Ky,
                                    Nam = kd.Nam,
                                    ChiSo = dc.ChiSoMoi ?? 0,
                                    TieuThu = dc.TieuThu ?? 0,
                                    MaCode = dc.MaCode,
                                    NgayDoc = dc.NgayDoc
                                })
                               .Take(limit)
                               .ToListAsync();

            return result;
        }

        /// <summary>
        /// Lấy danh sách kỳ đọc
        /// </summary>
        [HttpGet("kydoc")]
        public async Task<ActionResult<List<KyDoc>>> GetKyDoc()
        {
            return await _db.KyDoc
                .OrderByDescending(k => k.Nam)
                .ThenByDescending(k => k.Ky)
                .ToListAsync();
        }

        /// <summary>
        /// Thống kê kỳ đọc
        /// </summary>
        [HttpGet("thongke/{maKyDoc}")]
        public async Task<ActionResult<ThongKeResponse>> ThongKe(int maKyDoc)
        {
            var list = await _db.DocChiSo
                .Where(d => d.MaKyDoc == maKyDoc)
                .ToListAsync();

            var daDoc = list.Where(d => d.TrangThai >= 1).ToList();

            return new ThongKeResponse
            {
                TongSo = list.Count,
                DaDoc = daDoc.Count,
                ChuaDoc = list.Count(d => d.TrangThai == 0),
                DongHoHong = list.Count(d => d.MaCode == "F"),
                KhoaNuoc = list.Count(d => d.MaCode == "6"),
                NhaTrong = list.Count(d => d.MaCode == "20"),
                TongTieuThu = daDoc.Sum(d => d.TieuThu ?? 0),
                TrungBinhTieuThu = daDoc.Where(d => (d.TieuThu ?? 0) > 0).Average(d => (double)(d.TieuThu ?? 0))
            };
        }
    }
}
