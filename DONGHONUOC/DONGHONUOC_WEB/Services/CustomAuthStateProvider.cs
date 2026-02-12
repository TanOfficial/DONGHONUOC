using System.Security.Claims;
using System.Text.Json;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.JSInterop;
using DONGHONUOC_WEB.Models;

namespace DONGHONUOC_WEB.Services
{
    public class CustomAuthStateProvider : AuthenticationStateProvider
    {
        private readonly IJSRuntime _jsRequest;
        private readonly HttpClient _httpClient;

        public CustomAuthStateProvider(IJSRuntime jsRequest, HttpClient httpClient)
        {
            _jsRequest = jsRequest;
            _httpClient = httpClient;
        }

        public override async Task<AuthenticationState> GetAuthenticationStateAsync()
        {
            try
            {
                var userInfoJson = await _jsRequest.InvokeAsync<string>("localStorage.getItem", "user_info");

                if (string.IsNullOrEmpty(userInfoJson))
                {
                    return new AuthenticationState(new ClaimsPrincipal(new ClaimsIdentity()));
                }

                var userInfo = JsonSerializer.Deserialize<LoginResponse>(userInfoJson);
                var identity = new ClaimsIdentity(new[]
                {
                    new Claim(ClaimTypes.Name, userInfo?.Username ?? ""),
                    new Claim(ClaimTypes.Role, userInfo?.VaiTro ?? ""),
                    new Claim("HoTen", userInfo?.HoTen ?? ""),
                    new Claim("Avatar", userInfo?.Avatar ?? "")
                }, "apiauth");

                return new AuthenticationState(new ClaimsPrincipal(identity));
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Auth Error: {ex.Message}");
                // Return anonymous state on error so app doesn't crash
                return new AuthenticationState(new ClaimsPrincipal(new ClaimsIdentity()));
            }
        }

        public async Task MarkUserAsAuthenticated(LoginResponse user)
        {
            var json = JsonSerializer.Serialize(user);
            await _jsRequest.InvokeVoidAsync("localStorage.setItem", "user_info", json);

            var identity = new ClaimsIdentity(new[]
            {
                new Claim(ClaimTypes.Name, user.Username ?? ""),
                new Claim(ClaimTypes.Role, user.VaiTro ?? ""),
                new Claim("HoTen", user.HoTen ?? ""),
                new Claim("Avatar", user.Avatar ?? "")
            }, "apiauth");

            var userPrincipal = new ClaimsPrincipal(identity);
            NotifyAuthenticationStateChanged(Task.FromResult(new AuthenticationState(userPrincipal)));
        }

        public async Task MarkUserAsLoggedOut()
        {
            await _jsRequest.InvokeVoidAsync("localStorage.removeItem", "user_info");
            var identity = new ClaimsIdentity();
            var userPrincipal = new ClaimsPrincipal(identity);
            NotifyAuthenticationStateChanged(Task.FromResult(new AuthenticationState(userPrincipal)));
        }
    }
}
