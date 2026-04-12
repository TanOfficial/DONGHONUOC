using DHN_WF.Models;
using Newtonsoft.Json;
using System.Net.Http.Headers;
using System.Text;

namespace DHN_WF.Services
{
    public class ApiService
    {
        private static readonly HttpClient _client = new HttpClient
        {
            // Use 127.0.0.1 to avoid ipv6 resolution issues with 'localhost'
            BaseAddress = new Uri("http://127.0.0.1:5000/api/"),
            Timeout = TimeSpan.FromSeconds(30)
        };

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
    }
}
