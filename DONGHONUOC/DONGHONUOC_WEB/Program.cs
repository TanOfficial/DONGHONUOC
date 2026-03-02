using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using Microsoft.AspNetCore.Components.Authorization;
using DONGHONUOC_WEB;
using DONGHONUOC_WEB.Services;

try 
{
    var builder = WebAssemblyHostBuilder.CreateDefault(args);
    builder.RootComponents.Add<App>("#app");
    builder.RootComponents.Add<HeadOutlet>("head::after");
    builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri("http://192.168.1.189:5000") });

    // Auth Services
    builder.Services.AddAuthorizationCore();
    builder.Services.AddScoped<CustomAuthStateProvider>();
    builder.Services.AddScoped<AuthenticationStateProvider>(sp => sp.GetRequiredService<CustomAuthStateProvider>());
    builder.Services.AddScoped<AuthService>();

    await builder.Build().RunAsync();
}
catch (Exception ex)
{
    Console.WriteLine($"CRITICAL ERROR: {ex}");
    throw;
}
