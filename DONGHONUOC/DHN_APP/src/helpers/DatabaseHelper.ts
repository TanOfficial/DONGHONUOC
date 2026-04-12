import * as SQLite from 'expo-sqlite';

class DatabaseHelper {
    private static instance: DatabaseHelper;
    private db: SQLite.SQLiteDatabase | null = null;

    private constructor() { }

    public static getInstance(): DatabaseHelper {
        if (!DatabaseHelper.instance) {
            DatabaseHelper.instance = new DatabaseHelper();
        }
        return DatabaseHelper.instance;
    }

    public async init() {
        if (this.db) return;
        this.db = await SQLite.openDatabaseAsync('tanhoa_water_v7.db');

        await this.db.execAsync(`
      PRAGMA journal_mode = WAL;
      CREATE TABLE IF NOT EXISTS khach_hang(
        ma_danh_bo TEXT PRIMARY KEY,
        ten_kh TEXT,
        dia_chi TEXT,
        chi_so_cu INTEGER,
        chi_so_moi INTEGER DEFAULT 0,
        hinh_anh TEXT,
        trang_thai INTEGER DEFAULT 0,
        ma_lo_trinh TEXT,
        dot TEXT,
        may TEXT,
        ma_ky_doc INTEGER,
        hieu TEXT,
        co TEXT,
        so_than TEXT,
        vi_tri TEXT,
        ngay_thay TEXT,
        gb INTEGER,
        dm INTEGER,
        dmhn INTEGER,
        tbtt INTEGER,
        ghi_chu TEXT,
        sdt TEXT,
        code TEXT DEFAULT '40',
        tinh_trang TEXT
      );

      CREATE TABLE IF NOT EXISTS users(
        username TEXT PRIMARY KEY,
        password TEXT,
        fullname TEXT
      );

      CREATE TABLE IF NOT EXISTS lich_su_doc(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ma_danh_bo TEXT,
        ky INTEGER,
        nam INTEGER,
        chi_so INTEGER,
        tieu_thu INTEGER,
        ngay_doc TEXT,
        code TEXT,
        FOREIGN KEY (ma_danh_bo) REFERENCES khach_hang(ma_danh_bo)
      );
    `);

        // Migration for existing DB
        try {
            await this.db.execAsync('ALTER TABLE khach_hang ADD COLUMN ma_ky_doc INTEGER;');
        } catch (e) { }
        try {
            await this.db.execAsync('ALTER TABLE khach_hang ADD COLUMN dot TEXT;');
        } catch (e) { }
        try {
            await this.db.execAsync('ALTER TABLE khach_hang ADD COLUMN may TEXT;');
        } catch (e) { }
    }

    public async luuDanhSachKhachHang(customers: any[], maKyDoc: number) {
        if (!this.db) await this.init();
        await this.db!.withTransactionAsync(async () => {
            // Xóa dữ liệu cũ của kỳ này trước khi lưu mới
            await this.db!.runAsync('DELETE FROM khach_hang WHERE ma_ky_doc = ?', [maKyDoc]);
            for (const c of customers) {
                // Fetch existing to preserve name if current batch is missing it
                const existing = await this.db!.getFirstAsync<any>(
                    'SELECT ten_kh, dia_chi FROM khach_hang WHERE ma_danh_bo = ?',
                    [c.ma_danh_bo]
                );

                const finalName = c.ten_kh || existing?.ten_kh || '';
                const finalDiaChi = c.dia_chi || existing?.dia_chi || '';

                await this.db!.runAsync(
                    `INSERT OR REPLACE INTO khach_hang (
                        ma_danh_bo, ten_kh, dia_chi, chi_so_cu, chi_so_moi, 
                        trang_thai, ma_lo_trinh, dot, may, ma_ky_doc, code, ghi_chu,
                        hieu, co, so_than, vi_tri, gb, dm, dmhn, tbtt
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
                    [
                        c.ma_danh_bo, finalName, finalDiaChi, c.chi_so_cu, c.chi_so_moi || 0,
                        c.trang_thai || 0, c.ma_lo_trinh, c.dot, c.may, maKyDoc, c.code || '40', c.ghi_chu || '',
                        c.hieu, c.co, c.so_than, c.vi_tri, c.gb, c.dm, c.dmhn, c.tbtt
                    ]
                );
            }
        });
    }

    public async layDanhSachTheoKy(maKyDoc: number) {
        if (!this.db) await this.init();
        return await this.db!.getAllAsync<any>(
            'SELECT * FROM khach_hang WHERE ma_ky_doc = ? ORDER BY ma_lo_trinh ASC, ma_danh_bo ASC',
            [maKyDoc]
        );
    }

    public async importFromCSV(content: string) {
        if (!this.db) await this.init();
        // Simple CSV parser for now
        const lines = content.split('\n');
        if (lines.length <= 1) return 0;

        let count = 0;
        await this.db!.withTransactionAsync(async () => {
            for (let i = 1; i < lines.length; i++) {
                const line = lines[i].trim();
                if (!line) continue;

                // Handle comma separated
                const cols = line.split(',');
                if (cols.length >= 4) {
                    const ma_danh_bo = cols[0].trim();
                    const ten_kh = cols[1].trim();
                    const dia_chi = cols[2].trim();
                    const chi_so_cu = parseInt(cols[3].trim()) || 0;

                    // Update only if name/address provided
                    await this.db!.runAsync(
                        `INSERT INTO khach_hang (ma_danh_bo, ten_kh, dia_chi, chi_so_cu) 
                         VALUES (?, ?, ?, ?)
                         ON CONFLICT(ma_danh_bo) DO UPDATE SET 
                            ten_kh = excluded.ten_kh,
                            dia_chi = excluded.dia_chi,
                            chi_so_cu = CASE WHEN excluded.chi_so_cu > 0 THEN excluded.chi_so_cu ELSE chi_so_cu END`,
                        [ma_danh_bo, ten_kh, dia_chi, chi_so_cu]
                    );
                    count++;
                }
            }
        });
        return count;
    }

    // ====== AUTH ======
    public async dangNhap(username: string, pass: string) {
        if (!this.db) await this.init();
        return await this.db!.getFirstAsync<any>(
            'SELECT * FROM users WHERE username = ? AND password = ?',
            [username, pass]
        );
    }

    public async dangKy(username: string, pass: string, fullname: string) {
        if (!this.db) await this.init();
        try {
            await this.db!.runAsync(
                'INSERT INTO users (username, password, fullname) VALUES (?, ?, ?)',
                [username, pass, fullname]
            );
            return true;
        } catch (e) {
            return false;
        }
    }

    // ====== KHÁCH HÀNG ======
    public async layDanhSach() {
        if (!this.db) await this.init();
        return await this.db!.getAllAsync<any>(
            'SELECT * FROM khach_hang ORDER BY ma_lo_trinh ASC, ma_danh_bo ASC'
        );
    }

    public async capNhatChiSo(maDB: string, chiSoMoi: number, hinh_anh: string, ghi_chu = '', code = '40') {
        if (!this.db) await this.init();
        await this.db!.runAsync(
            'UPDATE khach_hang SET chi_so_moi = ?, trang_thai = 1, hinh_anh = ?, ghi_chu = ?, code = ? WHERE ma_danh_bo = ?',
            [chiSoMoi, hinh_anh, ghi_chu, code, maDB]
        );
    }

    public async demTongKhach() {
        if (!this.db) await this.init();
        const result = await this.db!.getFirstAsync<any>('SELECT COUNT(*) as count FROM khach_hang');
        return result?.count || 0;
    }

    public async xoaToanBoKhachHang() {
        if (!this.db) await this.init();
        await this.db!.runAsync('DELETE FROM khach_hang');
    }

    // ====== LỊCH SỬ ======
    public async layLichSuDoc(maDB: string, limit = 3) {
        if (!this.db) await this.init();
        return await this.db!.getAllAsync<any>(
            'SELECT * FROM lich_su_doc WHERE ma_danh_bo = ? ORDER BY nam DESC, ky DESC LIMIT ?',
            [maDB, limit]
        );
    }

    public async luuLichSu(maDB: string, ky: number, nam: number, chiSo: number, tieuThu: number, code = '40') {
        if (!this.db) await this.init();
        await this.db!.runAsync(
            'INSERT INTO lich_su_doc (ma_danh_bo, ky, nam, chi_so, tieu_thu, ngay_doc, code) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [maDB, ky, nam, chiSo, tieuThu, new Date().toISOString(), code]
        );
    }

    public async resetTrangThaiLocal(maDB: string) {
        if (!this.db) await this.init();
        await this.db!.runAsync(
            'UPDATE khach_hang SET trang_thai = 0, chi_so_moi = 0, hinh_anh = NULL WHERE ma_danh_bo = ?',
            [maDB.trim()]
        );
    }

    public async tinhBatThuong(khachHang: any) {
        const { ma_danh_bo, chi_so_moi, chi_so_cu } = khachHang;
        const tieuThuHienTai = (chi_so_moi || 0) - (chi_so_cu || 0);

        if (tieuThuHienTai <= 0) return null;

        const lichSu = await this.layLichSuDoc(ma_danh_bo, 3);
        if (lichSu.length === 0) return null;

        const tongTieuThu = lichSu.reduce((sum, item) => sum + (item.tieu_thu || 0), 0);
        const trungBinh = tongTieuThu / lichSu.length;

        if (tieuThuHienTai > trungBinh * 1.5) return 'tang';
        if (tieuThuHienTai < trungBinh * 0.5) return 'giam';

        return null;
    }
}

export default DatabaseHelper.getInstance();
