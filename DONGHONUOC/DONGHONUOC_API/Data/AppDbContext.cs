using Microsoft.EntityFrameworkCore;
using DONGHONUOC_API.Models;

namespace DONGHONUOC_API.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<DocChiSo> DocChiSo { get; set; }
        public DbSet<NguoiDung> NguoiDung { get; set; }
        public DbSet<KyDoc> KyDoc { get; set; }
        public DbSet<LichSuDocSo> LichSuDocSo { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // DocSoID is primary key, no complex configs needed since we mapped directly
        }
    }
}
