using System.Net.Http.Json;
using DONGHONUOC_WEB.Models;

namespace DONGHONUOC_WEB.Services
{
    public class AuthService
    {
        private readonly HttpClient _httpClient;
        private readonly CustomAuthStateProvider _authStateProvider;

        public AuthService(HttpClient httpClient, CustomAuthStateProvider authStateProvider)
        {
            _httpClient = httpClient;
            _authStateProvider = authStateProvider;
        }

        public async Task<LoginResponse> Login(LoginRequest loginRequest)
        {
            // Corrected endpoint from AuthController to Auth
            var response = await _httpClient.PostAsJsonAsync("api/Auth/login", loginRequest);
            
            if (response.IsSuccessStatusCode)
            {
                var result = await response.Content.ReadFromJsonAsync<LoginResponse>();
                if (result != null && result.Success)
                {
                    await _authStateProvider.MarkUserAsAuthenticated(result);
                    return result;
                }
                return new LoginResponse { Success = false, Message = result?.Message ?? "Đăng nhập thất bại" };
            }

            return new LoginResponse { Success = false, Message = "Lỗi kết nối server" };
        }

        public async Task<LoginResponse> Register(RegisterRequest registerRequest)
        {
            try
            {
                var response = await _httpClient.PostAsJsonAsync("api/Auth/register", registerRequest);
                if (response.IsSuccessStatusCode)
                {
                    var result = await response.Content.ReadFromJsonAsync<LoginResponse>();
                    return result ?? new LoginResponse { Success = false, Message = "Đăng ký thất bại" };
                }
                return new LoginResponse { Success = false, Message = "Lỗi kết nối server hoặc tài khoản đã tồn tại" };
            }
            catch (Exception ex)
            {
                return new LoginResponse { Success = false, Message = ex.Message };
            }
        }

        public async Task Logout()
        {
            await _authStateProvider.MarkUserAsLoggedOut();
        }
    }
}
