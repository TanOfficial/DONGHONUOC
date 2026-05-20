namespace DONGHONUOC_API.Services
{
    public class WaterBillingService
    {
        public static (double TienNuoc, double ThueGTGT, double BVMT, double TongCong) TinhTienNuoc(double tieuThu, string gb, string dmStr, string dmhnStr)
        {
            if (tieuThu <= 0) return (0, 0, 0, 0);

            double tienNuocCoBan = 0;

            if (gb == "11" || gb == "11 ") // Giá biểu sinh hoạt
            {
                // Parse định mức
                double dm = double.TryParse(dmStr, out var d) ? d : 16; // Mặc định 16m3 nếu parse lỗi
                double dmhn = double.TryParse(dmhnStr, out var h) ? h : 0; // Hộ nghèo (thường là <= 16m3 hoặc 0)

                // Tính toán từng khung (Tier)
                double remaining = tieuThu;

                // Khung 1: Sinh hoạt nghèo (Tối đa = DMHN)
                if (dmhn > 0)
                {
                    double used_NhaNgheo = Math.Min(remaining, dmhn);
                    tienNuocCoBan += used_NhaNgheo * 6300;
                    remaining -= used_NhaNgheo;
                }

                // Khung 2: Sinh hoạt trong mức (Tối đa = DM - DMHN)
                // Lưu ý: SHTM chứa cả SHN. Tổng dung lượng trong mức là DM.
                double SHTM_Limit = Math.Max(0, dm - dmhn);
                if (remaining > 0 && SHTM_Limit > 0)
                {
                    double used_SHTM = Math.Min(remaining, SHTM_Limit);
                    tienNuocCoBan += used_SHTM * 6700;
                    remaining -= used_SHTM;
                }

                // Khung 3: Sinh hoạt vượt mức 1 (Thông thường Vượt mức 1 = 50% Định mức)
                // Theo luật cấp nước hcm: 0-4m3/người (Trong định mức), 4-6m3/người (VM1 -> block = 2m3 = 50% định mức)
                double SHVM1_Limit = dm / 2;
                if (remaining > 0 && SHVM1_Limit > 0)
                {
                    double used_SHVM1 = Math.Min(remaining, SHVM1_Limit);
                    tienNuocCoBan += used_SHVM1 * 12900;
                    remaining -= used_SHVM1;
                }

                // Khung 4: Sinh hoạt vượt mức 2 (Phần dư còn lại trên 6m3/người)
                if (remaining > 0)
                {
                    tienNuocCoBan += remaining * 14400;
                    remaining -= remaining; // Hết
                }
            }
            else
            {
                // Nếu không phải Giá Biểu 11 (Vd kinh doanh, hành chính), hiện tại tính đồng giá
                // Có thể mở rộng sau nếu có nhiều Giá biểu phức tạp hơn. Tạm dùng giá Căn bản: 11615 VNĐ/m3.
                tienNuocCoBan = tieuThu * 11615;
            }

            // Thuế GTGT 5%
            double thue = tienNuocCoBan * 0.05;
            // Phí Bảo vệ Môi trường 10%
            double bvmt = tienNuocCoBan * 0.10;
            
            // Tổng cộng
            double tongCong = tienNuocCoBan + thue + bvmt;

            return (tienNuocCoBan, thue, bvmt, tongCong);
        }
    }
}
