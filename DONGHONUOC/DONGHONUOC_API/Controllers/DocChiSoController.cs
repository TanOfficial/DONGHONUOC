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
            var query = from dc in _db.DocChiSo
                        join kh in _db.KhachHang on dc.MaDanhBo equals kh.MaDanhBo
                        where dc.MaKyDoc == maKyDoc
                        select new { dc, kh };

            if (!string.IsNullOrEmpty(maLoTrinh))
                query = query.Where(x => x.kh.MaLoTrinh == maLoTrinh);

            if (trangThai.HasValue)
                query = query.Where(x => x.dc.TrangThai == trangThai.Value);

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
                    DocChiSoId = x.dc.ID,
                    MaKyDoc = x.dc.MaKyDoc,
                    ChiSoCu = x.dc.ChiSoCu,
                    ChiSoMoi = x.dc.ChiSoMoi,
                    TieuThu = x.dc.TieuThu,
                    MaCode = x.dc.MaCode,
                    TBTT = x.dc.TBTT,
                    TrangThai = x.dc.TrangThai,
                    GhiChu = x.dc.GhiChu,
                    TinhTrang = x.dc.TinhTrang,
                    HinhAnh = x.dc.HinhAnh,
                    NgayDoc = x.dc.NgayDoc
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
                return NotFound(new { message = "Không tìm thấy bản ghi đọc số" });

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
