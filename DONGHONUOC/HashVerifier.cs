using System;
using System.Security.Cryptography;
using System.Text;

class Program
{
    static void Main()
    {
        string[] passwords = { "123", "123456", "admin", "password" };
        foreach (var pass in passwords)
        {
            var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(pass));
            var hash = Convert.ToHexStringLower(bytes);
            Console.WriteLine($"Password: {pass} -> Hash: {hash}");
        }
    }
}
