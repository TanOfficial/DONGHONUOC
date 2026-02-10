using Microsoft.EntityFrameworkCore;
using DONGHONUOC_API.Models;

namespace DONGHONUOC_API.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<KhachHang> KhachHang { get; set; }
        public DbSet<DocChiSo> DocChiSo { get; set; }
        public DbSet<NguoiDung> NguoiDung { get; set; }
        public DbSet<KyDoc> KyDoc { get; set; }
        public DbSet<LichSuDocSo> LichSuDocSo { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // DocChiSo - computed column TieuThu
            modelBuilder.Entity<DocChiSo>()
                .Property(d => d.TieuThu)
                .HasComputedColumnSql(null); // Let SQL Server handle it

            // DocChiSo -> KhachHang relationship
            modelBuilder.Entity<DocChiSo>()
                .HasOne(d => d.KhachHang)
                .WithMany()
                .HasForeignKey(d => d.MaDanhBo);

            // Unique constraint: 1 khách hàng chỉ đọc 1 lần/kỳ
            modelBuilder.Entity<DocChiSo>()
                .HasIndex(d => new { d.MaDanhBo, d.MaKyDoc })
                .IsUnique();
        }
    }
}
