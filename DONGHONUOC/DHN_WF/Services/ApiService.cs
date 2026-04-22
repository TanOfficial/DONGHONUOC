using DHN_WF.Models;
using Newtonsoft.Json;
using System.Net.Http.Headers;
using System.Text;

namespace DHN_WF.Services
{
    public class ApiService
    {
        private static HttpClient _client = null!;
        private static string _baseUrl = "http://127.0.0.1:5000/api/";
        private static readonly string _configPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "api_config.json");

        static ApiService()
        {
            LoadConfig();
            InitializeClient();
        }

        private static void InitializeClient()
        {
            _client = new HttpClient
            {
                BaseAddress = new Uri(_baseUrl),
                Timeout = TimeSpan.FromSeconds(30)
            };
        }

        public static string GetBaseUrl() => _baseUrl;

        public static void UpdateBaseUrl(string newUrl)
        {
            if (string.IsNullOrWhiteSpace(newUrl)) return;
            
            // Ensure trailing slash
            if (!newUrl.EndsWith("/")) newUrl += "/";
            if (!newUrl.EndsWith("api/")) newUrl += "api/";

            _baseUrl = newUrl;
            SaveConfig();
            InitializeClient();
        }

        private static void LoadConfig()
        {
            try
            {
                if (File.Exists(_configPath))
                {
                    var json = File.ReadAllText(_configPath);
                    var config = JsonConvert.DeserializeObject<dynamic>(json);
                    if (config?.BaseUrl != null)
                    {
                        _baseUrl = (string)config.BaseUrl;
                    }
                }
            }
            catch { /* Fallback to default */ }
        }

        private static void SaveConfig()
        {
            try
            {
                var json = JsonConvert.SerializeObject(new { BaseUrl = _baseUrl });
                File.WriteAllText(_configPath, json);
            }
            catch { }
        }

        private static StringContent Json(object obj)
            => new StringContent(JsonConvert.SerializeObject(obj), Encoding.UTF8, "application/json");

        // ==================== AUTH ====================

        public async Task<LoginResponse?> LoginAsync(string username, string password)
        {
            // Use PascalCase properties to match the API's LoginRequest DTO exactly
            var res = await _client.PostAsync("Auth/login", Json(new { Username = username, Password = password }));
            var json = await res.Content.ReadAsStringAsync();
            
            if (!res.IsSuccessStatusCode)
                throw new Exception($"API Error ({res.StatusCode}): {json}");

            return JsonConvert.DeserializeObject<LoginResponse>(json);
        }

        public async Task<List<UserModel>> GetUsersAsync()
        {
            var res = await _client.GetStringAsync("Auth/users");
            return JsonConvert.DeserializeObject<List<UserModel>>(res) ?? new();
        }

        public async Task<(bool Success, string Message)> RegisterUserAsync(string username, string password, string hoTen, string vaiTro)
        {
            var res = await _client.PostAsync("Auth/register", Json(new { username, password, hoTen, vaiTro }));
            var json = await res.Content.ReadAsStringAsync();
            var obj = JsonConvert.DeserializeObject<dynamic>(json);
            bool success = obj?.Success ?? false;
            string msg = obj?.Message ?? "";
            return (success, msg);
        }

        public async Task UpdateUserAsync(string username, string? password, string hoTen, string vaiTro)
        {
            var payload = new { hoTen, vaiTro, password = string.IsNullOrEmpty(password) ? null : password };
            await _client.PutAsync($"Auth/users/{username}", Json(payload));
        }

        // ==================== KY DOC ====================

        public async Task<List<KyDocModel>> GetKyDocAsync()
        {
            var res = await _client.GetStringAsync("DocChiSo/kydoc");
            return JsonConvert.DeserializeObject<List<KyDocModel>>(res) ?? new();
        }

        public async Task CreateKyDocAsync(int ky, int nam, string? tuNgay, string? denNgay)
        {
            await _client.PostAsync("DocChiSo/kydoc", Json(new
            {
                ky,
                nam,
                tuNgay = string.IsNullOrEmpty(tuNgay) ? null : (object)tuNgay,
                denNgay = string.IsNullOrEmpty(denNgay) ? null : (object)denNgay
            }));
        }

        public async Task UpdateKyDocAsync(int maKyDoc, int ky, int nam, string? tuNgay, string? denNgay)
        {
            await _client.PutAsync($"DocChiSo/kydoc/{maKyDoc}", Json(new
            {
                maKyDoc,
                ky,
                nam,
                tuNgay = string.IsNullOrEmpty(tuNgay) ? null : (object)tuNgay,
                denNgay = string.IsNullOrEmpty(denNgay) ? null : (object)denNgay
            }));
        }

        public async Task DeleteKyDocAsync(int maKyDoc)
        {
            await _client.DeleteAsync($"DocChiSo/kydoc/{maKyDoc}");
        }

        // ==================== THONG KE ====================

        public async Task<List<ThongKeDotResponse>> GetThongKeDotAsync(int maKyDoc)
        {
            var res = await _client.GetStringAsync($"DocChiSo/thongke-dot/{maKyDoc}");
            return JsonConvert.DeserializeObject<List<ThongKeDotResponse>>(res) ?? new();
        }

        public async Task<ThongKeResponse?> GetThongKeAsync(int maKyDoc)
        {
            var res = await _client.GetStringAsync($"DocChiSo/thongke/{maKyDoc}");
            return JsonConvert.DeserializeObject<ThongKeResponse>(res);
        }

        public async Task<List<ChiTietDotResponse>> GetChiTietDotAsync(int maKyDoc)
        {
            var res = await _client.GetStringAsync($"DocChiSo/dot/{maKyDoc}");
            return JsonConvert.DeserializeObject<List<ChiTietDotResponse>>(res) ?? new();
        }

        public async Task<List<DocSoItemResponse>> GetDocSoByKyAsync(int maKyDoc)
        {
            var res = await _client.GetStringAsync($"DocChiSo/ky/{maKyDoc}");
            return JsonConvert.DeserializeObject<List<DocSoItemResponse>>(res) ?? new();
        }

        public async Task<(int count, double tongTien, string message)> ChotHoaDonThangAsync(int maKyDoc)
        {
            var res = await _client.PostAsync($"DocChiSo/chot-hoa-don/{maKyDoc}", null);
            var json = await res.Content.ReadAsStringAsync();
            var obj = JsonConvert.DeserializeObject<dynamic>(json);
            
            if (res.IsSuccessStatusCode)
            {
                return (
                    (int)(obj?.count ?? 0), 
                    (double)(obj?.tongTienQuyetToan ?? 0), 
                    (string)(obj?.message ?? "Thành công")
                );
            }
            throw new Exception((string)(obj?.title ?? obj?.message ?? json));
        }

        // ==================== UPLOAD ====================

        public async Task<string> UploadBienDongAsync(string filePath, int maKyDoc)
        {
            using var form = new MultipartFormDataContent();
            using var fileStream = File.OpenRead(filePath);
            var fileContent = new StreamContent(fileStream);
            fileContent.Headers.ContentType = MediaTypeHeaderValue.Parse("application/octet-stream");
            form.Add(fileContent, "file", Path.GetFileName(filePath));
            form.Add(new StringContent(maKyDoc.ToString()), "maKyDoc");

            var res = await _client.PostAsync("DocChiSo/upload-bien-dong", form);
            var json = await res.Content.ReadAsStringAsync();

            if (res.IsSuccessStatusCode)
            {
                dynamic? obj = JsonConvert.DeserializeObject(json);
                return obj?.message ?? "Thành công!";
            }
            throw new Exception(json);
        }

        // ==================== AI OCR ====================

        public async Task<string?> DocSoAIAsync(string hinhAnhBase64)
        {
            try
            {
                // Server AI mới chạy trên port 8001
                var ip = _client.BaseAddress?.Host ?? "127.0.0.1";
                var aiUrl = $"http://{ip}:8001/api/doc-so-moi";

                using var content = new MultipartFormDataContent();
                
                // Chuyển Base64 về bytes để upload
                byte[] imageBytes = Convert.FromBase64String(hinhAnhBase64.Contains(",") ? hinhAnhBase64.Split(',')[1] : hinhAnhBase64);
                var byteContent = new ByteArrayContent(imageBytes);
                byteContent.Headers.ContentType = MediaTypeHeaderValue.Parse("image/jpeg");
                content.Add(byteContent, "file", "photo.jpg");

                var res = await _client.PostAsync(aiUrl, content);
                if (res.IsSuccessStatusCode)
                {
                    var json = await res.Content.ReadAsStringAsync();
                    dynamic? obj = JsonConvert.DeserializeObject(json);
                    bool success = obj?.success ?? false;
                    return success ? (string?)obj?.result : null;
                }
                return null;
            }
            catch (Exception ex)
            {
                Console.WriteLine("❌ AI Error: " + ex.Message);
                return null;
            }
        }
    }
}
