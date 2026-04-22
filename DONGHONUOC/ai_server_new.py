import os
import io
import cv2
import numpy as np
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
from ultralytics import YOLO
from PIL import Image, ImageEnhance

app = FastAPI(title="AI Water Meter Reading Server v2")

# Load model YOLOv11 đã huấn luyện (phiên bản mới với nhận diện hãng)
MODEL_PATH = "best.pt"
if not os.path.exists(MODEL_PATH):
    print(f"❌ ERROR: Model file not found at {MODEL_PATH}")
model = YOLO(MODEL_PATH)

# Phân loại classes từ model
DIGIT_CLASSES = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
BRAND_CLASSES = {"ABB", "ACTARIS", "AICHI TOKEI", "ARAD", "BAYLAN", "DELTA", "DIEHL", "EMS"}
NUMBER_REGION_CLASS = "number"  # Vùng chứa số (thay cho "screen" của model cũ)


def enhance_image(img_np):
    """
    Tăng cường ảnh trước khi đưa vào model:
    - Tăng độ tương phản (contrast) để làm rõ chữ số LCD
    - Tăng độ sắc nét (sharpness)
    """
    # Convert to PIL for enhancement
    pil_img = Image.fromarray(img_np)
    
    # Tăng contrast 1.5x
    enhancer = ImageEnhance.Contrast(pil_img)
    pil_img = enhancer.enhance(1.5)
    
    # Tăng sharpness 2x
    enhancer = ImageEnhance.Sharpness(pil_img)
    pil_img = enhancer.enhance(2.0)
    
    # Tăng brightness nhẹ 1.1x
    enhancer = ImageEnhance.Brightness(pil_img)
    pil_img = enhancer.enhance(1.1)
    
    return np.array(pil_img)


def process_results(results):
    """
    Xử lý kết quả từ YOLO v2:
    - Tìm vùng 'number' lớn nhất (chứa chỉ số nước).
    - Tìm hãng đồng hồ nếu có.
    - Lấy các 'digit' nằm bên trong vùng 'number'.
    - Sắp xếp từ trái sang phải để ghép thành chỉ số.
    """
    boxes = results[0].boxes
    if len(boxes) == 0:
        return {"reading": "N/A", "brand": None, "brand_conf": None}

    # Phân loại các đối tượng phát hiện được
    digits = []
    number_regions = []
    detected_brands = []

    for box in boxes:
        cls_id = int(box.cls[0])
        label = results[0].names[cls_id]
        conf = float(box.conf[0])
        coords = box.xyxy[0].tolist()  # [x1, y1, x2, y2]

        obj = {
            "label": label,
            "conf": conf,
            "x_min": coords[0],
            "y_min": coords[1],
            "x_max": coords[2],
            "y_max": coords[3],
            "width": coords[2] - coords[0],
            "height": coords[3] - coords[1],
            "area": (coords[2] - coords[0]) * (coords[3] - coords[1]),
            "center_x": (coords[0] + coords[2]) / 2,
            "center_y": (coords[1] + coords[3]) / 2,
        }

        if label == NUMBER_REGION_CLASS:
            number_regions.append(obj)
        elif label in DIGIT_CLASSES:
            digits.append(obj)
        elif label in BRAND_CLASSES:
            detected_brands.append(obj)

    # --- XỬ LÝ HÃNG ĐỒNG HỒ ---
    best_brand = None
    if detected_brands:
        detected_brands.sort(key=lambda x: x["conf"], reverse=True)
        best_brand = detected_brands[0]
        print(f"🏷️  Brand detected: {best_brand['label']} (conf={best_brand['conf']:.2f})")

    # --- XỬ LÝ CHỈ SỐ NƯỚC ---
    # Tìm vùng 'number' lớn nhất
    best_number_region = None
    if number_regions:
        number_regions.sort(key=lambda x: x["area"], reverse=True)
        best_number_region = number_regions[0]
        print(f"📐 Number region found: area={best_number_region['area']:.0f}, "
              f"x=[{best_number_region['x_min']:.0f}-{best_number_region['x_max']:.0f}], "
              f"y=[{best_number_region['y_min']:.0f}-{best_number_region['y_max']:.0f}]")

    # Lọc digit: chỉ giữ digit nằm trong vùng 'number' (nếu có)
    if best_number_region:
        filtered_digits = []
        for d in digits:
            if (best_number_region["x_min"] <= d["center_x"] <= best_number_region["x_max"] and
                best_number_region["y_min"] <= d["center_y"] <= best_number_region["y_max"]):
                filtered_digits.append(d)
            else:
                print(f"✂️  Removed digit '{d['label']}' outside number region "
                      f"(cx={d['center_x']:.0f}, cy={d['center_y']:.0f}, conf={d['conf']:.2f})")
        digits = filtered_digits

    # KHÔNG lọc theo conf cao quá - model mới có conf thấp hơn model cũ
    # Chỉ bỏ những digit có conf cực thấp < 0.15
    low_conf = [d for d in digits if d["conf"] < 0.15]
    for d in low_conf:
        print(f"✂️  Removed very low conf digit '{d['label']}' (conf={d['conf']:.2f})")
    digits = [d for d in digits if d["conf"] >= 0.15]

    # Lọc theo kích thước: loại bỏ các số quá nhỏ (số seri, nhãn phụ)
    # Chỉ lọc nếu có ít nhất 3 digit để so sánh hợp lý
    if len(digits) > 2:
        heights = [d["height"] for d in digits]
        median_height = sorted(heights)[len(heights) // 2]
        min_height = median_height * 0.5  # Giảm ngưỡng từ 0.6 xuống 0.5 để giữ nhiều digit hơn

        final_digits = []
        for d in digits:
            if d["height"] >= min_height:
                final_digits.append(d)
            else:
                print(f"✂️  Removed small digit '{d['label']}' "
                      f"(h={d['height']:.1f}, min={min_height:.1f}, conf={d['conf']:.2f})")
        digits = final_digits

    # Loại bỏ digit trùng lặp (overlap) - giữ cái có conf cao hơn
    if len(digits) > 1:
        digits.sort(key=lambda x: x["x_min"])
        deduped = [digits[0]]
        for d in digits[1:]:
            prev = deduped[-1]
            # Kiểm tra overlap theo trục X
            overlap = max(0, min(prev["x_max"], d["x_max"]) - max(prev["x_min"], d["x_min"]))
            overlap_ratio = overlap / min(prev["width"], d["width"]) if min(prev["width"], d["width"]) > 0 else 0
            
            if overlap_ratio > 0.5:
                # Trùng lặp - giữ cái có conf cao hơn
                if d["conf"] > prev["conf"]:
                    print(f"🔄 Replaced overlapping '{prev['label']}' (conf={prev['conf']:.2f}) "
                          f"with '{d['label']}' (conf={d['conf']:.2f})")
                    deduped[-1] = d
                else:
                    print(f"🔄 Kept '{prev['label']}' (conf={prev['conf']:.2f}), "
                          f"removed overlapping '{d['label']}' (conf={d['conf']:.2f})")
            else:
                deduped.append(d)
        digits = deduped

    # Sắp xếp từ trái sang phải
    digits.sort(key=lambda x: x["x_min"])

    # Ghép chuỗi chỉ số
    reading = "".join(d["label"] for d in digits)

    # Log chi tiết
    print(f"🔢 Digits found: {len(digits)}")
    for d in digits:
        print(f"   [{d['label']}] x={d['x_min']:.0f}-{d['x_max']:.0f} "
              f"conf={d['conf']:.2f} h={d['height']:.0f} w={d['width']:.0f}")
    print(f"📊 Final Reading: {reading if reading else 'N/A'}")

    return {
        "reading": reading if reading else "N/A",
        "brand": best_brand["label"] if best_brand else None,
        "brand_conf": round(best_brand["conf"], 2) if best_brand else None,
    }


@app.post("/api/doc-so-moi")
async def doc_so_moi(file: UploadFile = File(...)):
    try:
        # Đọc ảnh từ request
        contents = await file.read()
        image = Image.open(io.BytesIO(contents)).convert("RGB")
        img_np = np.array(image)

        print(f"\n{'='*60}")
        print(f"📸 Received image: {file.filename} ({img_np.shape})")

        # Tăng cường ảnh trước khi đưa vào model
        enhanced = enhance_image(img_np)

        # Chạy predict trên CẢ ảnh gốc và ảnh tăng cường, lấy kết quả tốt hơn
        results_original = model.predict(img_np, conf=0.10, iou=0.4)
        results_enhanced = model.predict(enhanced, conf=0.10, iou=0.4)

        # Chọn kết quả nào có nhiều detection hơn
        n_orig = len(results_original[0].boxes)
        n_enh = len(results_enhanced[0].boxes)
        print(f"🔍 Original detections: {n_orig}, Enhanced detections: {n_enh}")

        if n_enh > n_orig:
            results = results_enhanced
            print("✨ Using ENHANCED image results")
            res_plotted = results[0].plot()
            cv2.imwrite("debug_ai.jpg", cv2.cvtColor(res_plotted, cv2.COLOR_RGB2BGR))
            cv2.imwrite("debug_ai_enhanced.jpg", cv2.cvtColor(enhanced, cv2.COLOR_RGB2BGR))
        else:
            results = results_original
            print("📷 Using ORIGINAL image results")
            res_plotted = results[0].plot()
            cv2.imwrite("debug_ai.jpg", cv2.cvtColor(res_plotted, cv2.COLOR_RGB2BGR))

        print("💾 Saved debug images")

        # Xử lý kết quả
        parsed = process_results(results)

        response = {
            "success": True,
            "result": parsed["reading"],
            "brand": parsed.get("brand"),
            "brand_conf": parsed.get("brand_conf"),
            "message": "Đã xử lý ảnh thành công"
        }

        print(f"✅ Response: reading={parsed['reading']}, brand={parsed.get('brand')}")
        print(f"{'='*60}\n")

        return response

    except Exception as e:
        print(f"❌ Server Error: {e}")
        import traceback
        traceback.print_exc()
        return JSONResponse(
            status_code=500,
            content={"success": False, "message": str(e)}
        )


@app.get("/health")
async def health():
    """API kiểm tra trạng thái server"""
    return {
        "status": "running",
        "model": MODEL_PATH,
        "classes": model.names,
        "brand_classes": list(BRAND_CLASSES),
        "digit_classes": list(DIGIT_CLASSES),
    }


if __name__ == "__main__":
    import uvicorn
    print("🚀 Starting AI Water Meter Server v2...")
    print(f"📦 Model: {MODEL_PATH}")
    print(f"🏷️  Supported brands: {', '.join(sorted(BRAND_CLASSES))}")
    print(f"🔢 Digit classes: 0-9")
    print(f"📐 Region class: {NUMBER_REGION_CLASS}")
    uvicorn.run(app, host="0.0.0.0", port=8001)
