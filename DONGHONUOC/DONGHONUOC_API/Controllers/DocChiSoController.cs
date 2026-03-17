using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DONGHONUOC_API.Data;
using DONGHONUOC_API.Models;
using OfficeOpenXml;

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
        public async Task<ActionResult<List<DocSoItemResponse>>> GetByKy([FromRoute] int maKyDoc, [FromQuery] string? maLoTrinh = null, [FromQuery] int? trangThai = null, [FromQuery] string? search = null, [FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 0)
        {
            Console.WriteLine($"🔍 GetByKy called: maKyDoc={maKyDoc}, page={pageNumber}, size={pageSize}");
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

            var list = await pagedQuery.ToListAsync();

            var result = list.Select(d => new DocSoItemResponse
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
            }).ToList();

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

        [HttpPost("lichsu/bulk")]
        public async Task<ActionResult<Dictionary<string, List<LichSuItem>>>> GetLichSuBulk([FromBody] List<string> maDanhBos, [FromQuery] int limit = 3)
        {
            var result = await (from ls in _db.LichSuDocSo
                                join kd in _db.KyDoc on ls.MaKyDoc equals kd.MaKyDoc
                                where maDanhBos.Contains(ls.MaDanhBo) && ls.HanhDong == "DocMoi"
                                orderby ls.ThoiGian descending
                                select new
                                {
                                    MaDanhBo = ls.MaDanhBo,
                                    Item = new LichSuItem
                                    {
                                        Ky = kd.Ky,
                                        Nam = kd.Nam,
                                        ChiSo = ls.ChiSo,
                                        TieuThu = ls.TieuThu,
                                        MaCode = ls.MaCode,
                                        NgayDoc = ls.ThoiGian
                                    }
                                })
                               .ToListAsync();

            var grouped = result
                .GroupBy(x => x.MaDanhBo)
                .ToDictionary(
                    g => g.Key,
                    g => g.Select(x => x.Item).Take(limit).ToList()
                );

            return grouped;
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

        // ====== THỐNG KÊ THEO ĐỢT ======
        [HttpGet("thongke-dot/{maKyDoc}")]
        public async Task<ActionResult<List<ThongKeDotResponse>>> ThongKeDot(int maKyDoc)
        {
            var lichDoc = await _db.KyDoc.FindAsync(maKyDoc);
            if (lichDoc == null) return NotFound("Kỳ đọc không tồn tại");
            string kyStr = lichDoc.Ky.ToString("D2");

            var list = await _db.DocChiSo
                .Where(d => d.Nam == lichDoc.Nam && d.Ky == kyStr)
                .ToListAsync();

            var grouped = list
                .GroupBy(d => d.MaLoTrinh ?? "??")
                .OrderBy(g => g.Key)
                .Select(g =>
                {
                    var daDoc = g.Where(d => d.TrangThai >= 1).ToList();
                    var ngayBD = g.Min(d => d.NgayDoc);
                    var ngayTD = daDoc.Any() ? daDoc.Max(d => d.NgayDoc) : (DateTime?)null;
                    return new ThongKeDotResponse
                    {
                        MaDot = g.Key,
                        TongHDKyTruoc = g.Count(d => d.ChiSoCu.HasValue),
                        TongBD = g.Count(),
                        TongTD = daDoc.Count,
                        NgayLapBD = ngayBD?.ToString("d/M/yyyy h:mm tt"),
                        NgayLapTD = ngayTD?.ToString("d/M/yyyy h:mm tt"),
                    };
                })
                .ToList();

            return grouped;
        }


        // ====== CHI TIẾT 15 ĐỢT TRONG KỲ ======
        [HttpGet("dot/{maKyDoc}")]
        public async Task<ActionResult<List<ChiTietDotResponse>>> GetChiTietDot(int maKyDoc)
        {
            var kyDoc = await _db.KyDoc.FindAsync(maKyDoc);
            if (kyDoc == null) return NotFound("Không tìm thấy kỳ đọc");

            const int soBot = 15;
            var result = new List<ChiTietDotResponse>();

            DateTime tuNgay = kyDoc.TuNgay ?? new DateTime(kyDoc.Nam, kyDoc.Ky, 1);
            DateTime denNgay = kyDoc.DenNgay ?? tuNgay.AddDays(29);
            double totalDays = (denNgay - tuNgay).TotalDays;
            double dayPerDot = totalDays / soBot;

            for (int i = 0; i < soBot; i++)
            {
                DateTime ngayDoc = tuNgay.AddDays(Math.Round(i * dayPerDot));
                DateTime ngayKiemSoat = ngayDoc.AddDays(0);
                DateTime ngayChuyen = ngayDoc.AddDays(1);
                DateTime ngayThuTien = ngayDoc.AddDays(2);

                result.Add(new ChiTietDotResponse
                {
                    Dot = i + 1,
                    NgayDoc = ngayDoc.ToString("d/M/yyyy"),
                    NgayKiemSoat = ngayKiemSoat.ToString("d/M/yyyy"),
                    NgayChuyenListing = ngayChuyen.ToString("d/M/yyyy"),
                    NgayThuTien = ngayThuTien.ToString("d/M/yyyy"),
                    KiemTraNgayDoc = true
                });
            }

            return result;
        }

        // ====== UPLOAD FILE BIẾN ĐỘNG ======
        [HttpPost("upload-bien-dong")]
        public async Task<ActionResult> UploadBienDong([FromForm] IFormFile file, [FromForm] int maKyDoc)
        {
            if (file == null || file.Length == 0)
                return BadRequest("Vui lòng chọn file hợp lệ (.xlsx hoặc .csv)");

            var kyDoc = await _db.KyDoc.FindAsync(maKyDoc);
            if (kyDoc == null) return BadRequest("Không tìm thấy kỳ đọc");

            string kyStr = kyDoc.Ky.ToString("D2");
            var ext = Path.GetExtension(file.FileName).ToLower();
            var rows = new List<BienDongRow>();

            if (ext == ".xlsx" || ext == ".xls")
            {
                ExcelPackage.LicenseContext = LicenseContext.NonCommercial;
                using var stream = new MemoryStream();
                await file.CopyToAsync(stream);
                using var package = new ExcelPackage(stream);
                var ws = package.Workbook.Worksheets[0];
                if (ws == null) return BadRequest("File Excel không có sheet nào");

                // Đọc header row để map cột
                int rowCount = ws.Dimension?.Rows ?? 0;
                int colCount = ws.Dimension?.Columns ?? 0;
                var headers = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
                for (int c = 1; c <= colCount; c++)
                {
                    var h = ws.Cells[1, c].Text?.Trim() ?? "";
                    if (!string.IsNullOrEmpty(h)) headers[h] = c;
                }

                for (int r = 2; r <= rowCount; r++)
                {
                    string GetCell(params string[] keys)
                    {
                        foreach (var k in keys)
                            if (headers.TryGetValue(k, out int col))
                                return ws.Cells[r, col].Text?.Trim() ?? "";
                        return "";
                    }

                    var danhBa = GetCell("DanhBa", "DANHBA", "Danh Bộ", "MaDanhBo");
                    if (string.IsNullOrWhiteSpace(danhBa)) continue;

                    rows.Add(new BienDongRow
                    {
                        MaDanhBo = danhBa,
                        DiaChi = GetCell("SoNhaMoi", "DiaChi", "Địa Chỉ", "DiaChiMoi"),
                        CSCu = int.TryParse(GetCell("CSCu", "ChiSoCu", "CS Cu"), out int csCu) ? csCu : 0,
                        MaCode = GetCell("CodeMoi", "MaCode", "Code") is string c && !string.IsNullOrEmpty(c) ? c : "40",
                        MaDot = GetCell("Dot", "MaDot", "MaLoTrinh"),
                        Hieu = GetCell("HieuMoi", "Hieu"),
                        Co = GetCell("CoMoi", "Co"),
                        SoThan = GetCell("SoThanMoi", "SoThan"),
                        ViTri = GetCell("ViTriMoi", "ViTri"),
                        GB = GetCell("GB"),
                        DM = GetCell("DM"),
                        SDT = GetCell("SDT", "SoDienThoai"),
                    });
                }
            }
            else if (ext == ".csv")
            {
                using var reader = new StreamReader(file.OpenReadStream());
                var headerLine = await reader.ReadLineAsync();
                if (headerLine == null) return BadRequest("File CSV trống");

                var headers = headerLine.Split(',').Select(h => h.Trim()).ToArray();
                int IdxOf(params string[] keys)
                {
                    foreach (var k in keys)
                    {
                        int i = Array.FindIndex(headers, h => h.Equals(k, StringComparison.OrdinalIgnoreCase));
                        if (i >= 0) return i;
                    }
                    return -1;
                }

                int iDanhBa = IdxOf("DanhBa", "DANHBA", "MaDanhBo");
                int iDiaChi = IdxOf("SoNhaMoi", "DiaChi");
                int iCSCu = IdxOf("CSCu", "ChiSoCu");
                int iCode = IdxOf("CodeMoi", "MaCode", "Code");
                int iDot = IdxOf("Dot", "MaDot", "MaLoTrinh");

                string? line;
                while ((line = await reader.ReadLineAsync()) != null)
                {
                    var cols = line.Split(',');
                    if (cols.Length <= iDanhBa || iDanhBa < 0) continue;
                    var danhBa = cols[iDanhBa].Trim();
                    if (string.IsNullOrWhiteSpace(danhBa)) continue;

                    rows.Add(new BienDongRow
                    {
                        MaDanhBo = danhBa,
                        DiaChi = iDiaChi >= 0 ? cols.ElementAtOrDefault(iDiaChi)?.Trim() : null,
                        CSCu = iCSCu >= 0 && int.TryParse(cols.ElementAtOrDefault(iCSCu)?.Trim(), out int csCu2) ? csCu2 : 0,
                        MaCode = iCode >= 0 ? cols.ElementAtOrDefault(iCode)?.Trim() ?? "40" : "40",
                        MaDot = iDot >= 0 ? cols.ElementAtOrDefault(iDot)?.Trim() : null,
                    });
                }
            }
            else
            {
                return BadRequest($"Định dạng file '{ext}' không được hỗ trợ. Chỉ dùng .xlsx hoặc .csv");
            }

            if (rows.Count == 0)
                return BadRequest("File không có dữ liệu hợp lệ");

            int themMoi = 0, capNhat = 0;
            string docSoIdPrefix = $"{kyDoc.Nam}{kyStr}";

            foreach (var row in rows)
            {
                var existing = await _db.DocChiSo.FirstOrDefaultAsync(
                    d => d.MaDanhBo == row.MaDanhBo && d.Nam == kyDoc.Nam && d.Ky == kyStr);

                if (existing == null)
                {
                    var newDoc = new DocChiSo
                    {
                        ID = $"{docSoIdPrefix}{row.MaDanhBo}",
                        MaDanhBo = row.MaDanhBo,
                        Nam = kyDoc.Nam,
                        Ky = kyStr,
                        ChiSoCu = row.CSCu,
                        ChiSoMoi = null,
                        TieuThu = 0,
                        TrangThai = 0,
                        MaCode = row.MaCode,
                        DiaChi = row.DiaChi,
                        MaLoTrinh = row.MaDot,
                        Hieu = row.Hieu,
                        Co = row.Co,
                        SoThan = row.SoThan,
                        ViTri = row.ViTri,
                        GB = row.GB,
                        DM = row.DM,
                        SoDienThoaiKH = row.SDT,
                    };
                    _db.DocChiSo.Add(newDoc);
                    themMoi++;
                }
                else
                {
                    existing.ChiSoCu = row.CSCu;
                    if (!string.IsNullOrEmpty(row.DiaChi)) existing.DiaChi = row.DiaChi;
                    if (!string.IsNullOrEmpty(row.MaDot)) existing.MaLoTrinh = row.MaDot;
                    capNhat++;
                }
            }

            await _db.SaveChangesAsync();
            return Ok(new
            {
                message = $"Import thành công! Thêm mới: {themMoi}, Cập nhật: {capNhat}",
                themMoi,
                capNhat,
                tongCong = rows.Count
            });
        }
    }
}
