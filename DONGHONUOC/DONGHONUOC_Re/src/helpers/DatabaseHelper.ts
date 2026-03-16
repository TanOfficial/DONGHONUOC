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
