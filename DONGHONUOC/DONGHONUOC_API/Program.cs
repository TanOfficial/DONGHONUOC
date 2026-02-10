using Microsoft.EntityFrameworkCore;
using DONGHONUOC_API.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = null; // Giữ nguyên tên property (PascalCase)
    });

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "Đồng Hồ Nước API", Version = "v1" });
});

// Database connection
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// CORS - cho phép Flutter app kết nối
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Swagger luôn bật (dùng cho dev)
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "Đồng Hồ Nước API v1");
});

app.UseCors("AllowAll");
app.MapControllers();

// Lắng nghe trên tất cả các IP (quan trọng cho mobile kết nối qua WiFi)
app.Urls.Add("http://0.0.0.0:5000");

Console.WriteLine("===========================================");
Console.WriteLine("  🚀 ĐỒNG HỒ NƯỚC API đang chạy!");
Console.WriteLine("  📡 http://localhost:5000");
Console.WriteLine("  📋 Swagger: http://localhost:5000/swagger");
Console.WriteLine("===========================================");

app.Run();
