using System;
using System.Data.SqlClient;

class Program
{
    static void Main()
    {
        string password = "123";
        string hash = BCrypt.Net.BCrypt.HashPassword(password, 12);
        Console.WriteLine($"Generated BCrypt hash for '{password}': {hash}");

        string connString = "Server=sql1001.site4now.net;Database=db_ac901d_docsoth;User Id=db_ac901d_docsoth_admin;Password=0932778405zZ;TrustServerCertificate=True;";
        using (SqlConnection connection = new SqlConnection(connString))
        {
            connection.Open();
            using (SqlCommand command = connection.CreateCommand())
            {
                command.CommandText = "UPDATE NguoiDungB SET PasswordHash = @hash WHERE Username = 'dang'";
                command.Parameters.AddWithValue("@hash", hash);
                int rows = command.ExecuteNonQuery();
                Console.WriteLine($"Database updated successfully! Affected rows: {rows}");
            }
        }
    }
}
