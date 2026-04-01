using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DONGHONUOC_API.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "DocSo",
                columns: table => new
                {
                    DocSoID = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    DanhBa = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Nam = table.Column<int>(type: "int", nullable: true),
                    Ky = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CSCu = table.Column<int>(type: "int", nullable: true),
                    CSMoi = table.Column<int>(type: "int", nullable: true),
                    TieuThuMoi = table.Column<int>(type: "int", nullable: true),
                    CodeMoi = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    TBTT = table.Column<int>(type: "int", nullable: true),
                    HinhAnh = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    GhiChuDS = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    TrangThai_API = table.Column<int>(type: "int", nullable: true),
                    GIOGHI = table.Column<DateTime>(type: "datetime2", nullable: true),
                    NVGHI = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SoNhaMoi = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SDT = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    GB = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    DM = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Dot = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    HieuMoi = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CoMoi = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SoThanMoi = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ViTriMoi = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    DMHN = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DocSo", x => x.DocSoID);
                });

            migrationBuilder.CreateTable(
                name: "Lich_DocSo",
                columns: table => new
                {
                    ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Ky = table.Column<int>(type: "int", nullable: false),
                    Nam = table.Column<int>(type: "int", nullable: false),
                    TuNgay = table.Column<DateTime>(type: "datetime2", nullable: true),
                    DenNgay = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Lich_DocSo", x => x.ID);
                });

            migrationBuilder.CreateTable(
                name: "LichSuDocSo",
                columns: table => new
                {
                    ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MaDanhBo = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    MaKyDoc = table.Column<int>(type: "int", nullable: false),
                    ChiSo = table.Column<int>(type: "int", nullable: false),
                    TieuThu = table.Column<int>(type: "int", nullable: false),
                    MaCode = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    HanhDong = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    NguoiThucHien = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    GhiChu = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ThoiGian = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LichSuDocSo", x => x.ID);
                });

            migrationBuilder.CreateTable(
                name: "NguoiDungB",
                columns: table => new
                {
                    MaND = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Username = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PasswordHash = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    HoTen = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    DienThoai = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ChucVu = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Khoa = table.Column<bool>(type: "bit", nullable: true),
                    Avatar = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_NguoiDungB", x => x.MaND);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "DocSo");

            migrationBuilder.DropTable(
                name: "Lich_DocSo");

            migrationBuilder.DropTable(
                name: "LichSuDocSo");

            migrationBuilder.DropTable(
                name: "NguoiDungB");
        }
    }
}
