import os, statistics
from fastapi import FastAPI, UploadFile, File
from fastapi.responses import JSONResponse, HTMLResponse, FileResponse
from PIL import Image, ImageDraw
import uvicorn
from roboflow import Roboflow

app = FastAPI(title="AI Water Meter - Roboflow Cloud")

# Khởi tạo API Roboflow
API_KEY = "4DC46RD8qJjbHkFWpDn8"
rf = Roboflow(api_key=API_KEY)
project = rf.workspace("shunlys-workspace").project("dhn-lcd")
# SỬ DỤNG CHÍNH XÁC VERSION 9 SIÊU PHẨM (99.5% mAP) ĐANG CHẠY TRÊN LABEL ASSIST!
model = project.version(9).model

DIGIT_CLASSES = {"0","1","2","3","4","5","6","7","8","9"}
BRAND_CLASSES = {"ABB", "Actaris", "AquaMaster", "Sensus", "Zenner"} # Thêm các hãng của bạn vào đây

print(f"Da ket noi thanh cong voi Roboflow Cloud - Model v9")

def filter_y_cluster(digits: list) -> list:
    if not digits: return []
    
    # Sắp xếp các số từ trên xuống dưới theo tọa độ y của tâm để nhóm dòng
    sorted_by_y = sorted(digits, key=lambda x: x["y"])
    
    rows = []
    for d in sorted_by_y:
        placed = False
        for row in rows:
            row_y = sum(r["y"] for r in row) / len(row)
            row_h = sum(r["height"] for r in row) / len(row)
            # Nới lỏng khoảng cách đứng lên 60% chiều cao để gom đủ các số LCD lệch nền
            if abs(d["y"] - row_y) < row_h * 0.60:
                row.append(d)
                placed = True
                break
        if not placed:
            rows.append([d])
            
    # Sắp xếp từng dòng từ trái sang phải
    for row in rows:
        row.sort(key=lambda x: x["x"])
        
    # Sắp xếp các dòng từ trên xuống dưới
    rows.sort(key=lambda r: sum(x["y"] for x in r) / len(r))
    
    # Chỉ giữ các dòng có tối thiểu 3 chữ số để loại bỏ các chữ số nhận diện sai riêng lẻ (noise),
    # trừ khi tất cả các dòng đều ngắn hơn 3 chữ số.
    max_len = max(len(r) for r in rows)
    if max_len >= 3:
        valid_rows = [r for r in rows if len(r) >= 3]
    else:
        valid_rows = rows
        
    # Luôn ưu tiên lấy dòng trên cùng (dòng đầu tiên sau khi đã xếp từ trên xuống)
    best_row = valid_rows[0] if valid_rows else rows[0]
    return best_row


def filter_size(digits: list) -> list:
    if not digits: return []
    med_h = statistics.median([d["height"] for d in digits])
    return [d for d in digits if 0.4 < d["height"]/med_h < 2.5]

def filter_spacing(digits: list) -> list:
    if len(digits) <= 2: return digits
    digits = sorted(digits, key=lambda d: d["x"])
    gaps = [(digits[i+1]["x"] - digits[i]["width"]/2) - (digits[i]["x"] + digits[i]["width"]/2) for i in range(len(digits)-1)]
    if not gaps: return digits
    max_gap = max(statistics.median([d["width"] for d in digits]) * 6.0, statistics.median(gaps) * 4.0)
    groups = [[digits[0]]]
    for i, gap in enumerate(gaps):
        if gap <= max_gap: groups[-1].append(digits[i+1])
        else: groups.append([digits[i+1]])
    return max(groups, key=len)

def filter_small_trailing_digits(digits: list) -> list:
    if len(digits) <= 2: return digits
    digits = sorted(digits, key=lambda d: d["x"])
    # Lấy chiều cao trung bình của 3 số nguyên to đầu tiên bên trái làm chuẩn
    main_h = sum(d["height"] for d in digits[:3]) / min(3, len(digits))
    
    result = []
    for d in digits:
        # Nếu chiều cao tụt xuống dưới 80% so với các số to ở đầu, cắt bỏ toàn bộ phần đuôi sau
        if d["height"] < main_h * 0.80:
            break
        result.append(d)
    return result if result else digits

import uuid

@app.post("/api/doc-so-moi")
async def doc_so_moi(file: UploadFile = File(...)):
    temp_path = f"temp_{uuid.uuid4().hex}.jpg"
    try:
        contents = await file.read()
        with open(temp_path, "wb") as f:
            f.write(contents)
        
        print(f"\n{'='*60}")
        print(f"Dang gui anh len Roboflow Cloud API...")
        
        # Gửi ảnh lên Cloud, lấy tất cả với conf=20%
        res = model.predict(temp_path, confidence=20, overlap=40).json()
        predictions = res.get("predictions", [])
        
        digits = []
        dots = []
        brands = []
        screens = []
        
        # Lọc theo ngưỡng cứng (50% cho số, 35% cho dấu chấm)
        for p in predictions:
            cls = p["class"]
            conf = p["confidence"]
            
            obj = {
                "label": cls, "conf": conf,
                "x": p["x"], "y": p["y"], 
                "width": p["width"], "height": p["height"],
                "x_min": p["x"] - p["width"]/2, "y_min": p["y"] - p["height"]/2,
                "x_max": p["x"] + p["width"]/2, "y_max": p["y"] + p["height"]/2,
            }
            
            target_conf = 0.35 if cls == "dot" else 0.50
            if cls not in DIGIT_CLASSES and cls != "dot":
                target_conf = 0.40
                
            if conf >= target_conf:
                if cls in DIGIT_CLASSES: digits.append(obj)
                elif cls == "dot": dots.append(obj)
                elif cls == "screen": screens.append(obj)
                else: brands.append(obj)

        print(f"🔹 Truoc khi loc: {[d['label'] for d in sorted(digits, key=lambda x: x['x'])]}")

        best_brand = max(brands, key=lambda x: x["conf"]) if brands else None
        best_screen = max(screens, key=lambda x: x["conf"]) if screens else None

        # Áp dụng bộ lọc
        digits = filter_y_cluster(digits)
        print(f"🔹 Sau filter_y_cluster: {[d['label'] for d in sorted(digits, key=lambda x: x['x'])]}")
        
        digits = filter_size(digits)
        print(f"🔹 Sau filter_size: {[d['label'] for d in sorted(digits, key=lambda x: x['x'])]}")
        
        digits = filter_spacing(digits)
        print(f"🔹 Sau filter_spacing: {[d['label'] for d in sorted(digits, key=lambda x: x['x'])]}")
        
        digits = filter_small_trailing_digits(digits)
        print(f"🔹 Sau filter_small_trailing_digits: {[d['label'] for d in sorted(digits, key=lambda x: x['x'])]}")
        
        final_digits = digits.copy()
        
        if dots and final_digits:
            valid_dots = []
            med_y = statistics.median([d["y"] for d in final_digits])
            med_h = statistics.median([d["height"] for d in final_digits])
            min_x = min([d["x_min"] for d in final_digits])
            max_x = max([d["x_max"] for d in final_digits])
            
            for dot in dots:
                if min_x - med_h <= dot["x"] <= max_x + med_h:
                    if med_y - med_h <= dot["y"] <= med_y + med_h:
                        valid_dots.append(dot)
            if valid_dots:
                best_dot = max(valid_dots, key=lambda x: x["conf"])
                final_digits.append(best_dot)

        final_digits.sort(key=lambda x: x["x"])
        raw_reading = "".join("." if d["label"] == "dot" else d["label"] for d in final_digits)
        
        # CHỈ LẤY SỐ TRƯỚC DẤU CHẤM
        reading = raw_reading.split(".")[0] if "." in raw_reading else raw_reading
        
        print(f"Roboflow Cloud Final -> Raw: '{raw_reading}' | Clean: '{reading}'")
        for d in final_digits:
            print(f"   [{d['label']}] conf={d['conf']:.2f}")

        # Render ảnh kết quả
        image = Image.open(temp_path).convert("RGB")
        draw = ImageDraw.Draw(image)
        
        if best_screen:
            s = best_screen
            draw.rectangle([s["x_min"], s["y_min"], s["x_max"], s["y_max"]], outline="magenta", width=3)
            
        for d in final_digits + [best_brand] if best_brand else final_digits:
            if not d: continue
            color = "cyan" if d["label"] in ["2","5"] else "yellow" if d["label"]=="dot" else "green"
            if d["label"] not in DIGIT_CLASSES and d["label"] != "dot": color = "purple"
            draw.rectangle([d["x_min"], d["y_min"], d["x_max"], d["y_max"]], outline=color, width=3)
            draw.text((d["x_min"], d["y_min"]-20), f"{d['label']} {d['conf']:.2f}", fill=color)

        image.save("debug_ai.jpg")
        print(f"{'='*60}")

        return JSONResponse({
            "status": "success",
            "reading": reading,
            "brand": best_brand["label"] if best_brand else None,
            "confidence": round(sum(d["conf"] for d in digits)/len(digits), 2) if digits else 0.0
        })
    except Exception as e:
        print(f"Error: {e}")
        return JSONResponse({"status": "error", "message": str(e)}, status_code=500)
    finally:
        if os.path.exists(temp_path):
            try:
                os.remove(temp_path)
            except:
                pass

@app.get("/debug-image")
def get_debug_image():
    if os.path.exists("debug_ai.jpg"):
        return FileResponse("debug_ai.jpg", media_type="image/jpeg", headers={"Cache-Control": "no-store"})
    return HTMLResponse("Không tìm thấy ảnh debug")

@app.get("/test", response_class=HTMLResponse)
def test_ui():
    html_content = """
    <!DOCTYPE html>
    <html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>AI Water Meter - Roboflow API</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
        <style>body { font-family: 'Inter', sans-serif; background-color: #0f172a; color: white; }</style>
    </head>
    <body class="min-h-screen flex items-center justify-center p-4">
        <div class="bg-slate-800 p-8 rounded-2xl shadow-2xl w-full max-w-md border border-slate-700">
            <h1 class="text-3xl font-extrabold text-center text-transparent bg-clip-text bg-gradient-to-r from-purple-400 to-pink-500 mb-6">AI Đọc Đồng Hồ v9<br/><span class="text-lg text-purple-300">(Roboflow Cloud Engine)</span></h1>
            
            <input type="file" id="fileInput" accept="image/*" class="hidden">
            <label for="fileInput" class="flex flex-col items-center justify-center w-full h-40 border-2 border-slate-600 border-dashed rounded-xl cursor-pointer bg-slate-700/50 hover:bg-slate-700 transition-all group">
                <div class="flex flex-col items-center justify-center pt-5 pb-6">
                    <svg class="w-10 h-10 mb-3 text-slate-400 group-hover:text-purple-400 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"></path></svg>
                    <p class="mb-2 text-sm text-slate-400"><span class="font-semibold text-purple-400">Nhấn để tải ảnh lên</span></p>
                </div>
            </label>

            <button onclick="uploadImage()" class="mt-6 w-full py-3 px-4 bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-500 hover:to-pink-500 text-white rounded-xl font-bold text-lg shadow-lg transform transition-all active:scale-95 flex items-center justify-center gap-2">
                🚀 Truyền lên Roboflow API
            </button>
            
            <div id="loading" class="hidden mt-6 text-center text-purple-400 font-semibold animate-pulse">Đang kết nối tới máy chủ Roboflow...</div>
            
            <div id="resultBox" class="mt-8 hidden">
                <div class="bg-slate-900 rounded-xl p-6 text-center shadow-inner border border-slate-700">
                    <h2 class="text-5xl font-black text-purple-400 tracking-widest mb-2" id="resReading"></h2>
                    <p class="text-slate-400 text-sm mb-4 font-bold" id="resBrand"></p>
                    <img id="resImage" class="w-full rounded-lg border-2 border-slate-700 shadow-lg object-contain" style="max-height: 400px;"/>
                </div>
            </div>
        </div>

        <script>
            async function uploadImage() {
                const file = document.getElementById('fileInput').files[0];
                if (!file) { alert('Vui lòng chọn ảnh trước!'); return; }
                
                document.getElementById('loading').classList.remove('hidden');
                document.getElementById('resultBox').classList.add('hidden');
                
                const formData = new FormData();
                formData.append('file', file);
                
                try {
                    const res = await fetch('/api/doc-so-moi', { method: 'POST', body: formData });
                    const data = await res.json();
                    
                    document.getElementById('resReading').innerText = data.reading || "Trống";
                    document.getElementById('resBrand').innerText = data.brand ? "Hãng: " + data.brand : "Không nhận ra hãng";
                    document.getElementById('resImage').src = '/debug-image?' + new Date().getTime();
                    
                    document.getElementById('loading').classList.add('hidden');
                    document.getElementById('resultBox').classList.remove('hidden');
                } catch (e) {
                    alert('Lỗi kết nối máy chủ!');
                    document.getElementById('loading').classList.add('hidden');
                }
            }
        </script>
    </body>
    </html>
    """
    return html_content

if __name__ == "__main__":
    uvicorn.run("ai_server_roboflow:app", host="0.0.0.0", port=8001, reload=True)
