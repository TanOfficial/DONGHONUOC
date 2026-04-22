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
NUMBER_REGION_CLASS = "number"


def create_image_variants(img_np):
    """
    Tạo nhiều phiên bản ảnh khác nhau để tăng cơ hội nhận diện:
    1. Ảnh gốc
    2. Tăng contrast + sharpness
    3. CLAHE (adaptive histogram equalization) - tốt cho LCD
    4. Tăng contrast mạnh hơn
    """
    variants = [("original", img_np)]

    # Variant 2: Tăng contrast + sharpness nhẹ
    try:
        pil = Image.fromarray(img_np)
        pil = ImageEnhance.Contrast(pil).enhance(1.5)
        pil = ImageEnhance.Sharpness(pil).enhance(2.0)
        pil = ImageEnhance.Brightness(pil).enhance(1.1)
        variants.append(("contrast_sharp", np.array(pil)))
    except Exception:
        pass

    # Variant 3: CLAHE - rất tốt cho LCD mờ
    try:
        lab = cv2.cvtColor(img_np, cv2.COLOR_RGB2LAB)
        clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8, 8))
        lab[:, :, 0] = clahe.apply(lab[:, :, 0])
        clahe_img = cv2.cvtColor(lab, cv2.COLOR_LAB2RGB)
        variants.append(("clahe", clahe_img))
    except Exception:
        pass

    # Variant 4: Tăng contrast rất mạnh (tốt cho LCD rất mờ)
    try:
        pil = Image.fromarray(img_np)
        pil = ImageEnhance.Contrast(pil).enhance(2.5)
        pil = ImageEnhance.Sharpness(pil).enhance(3.0)
        variants.append(("high_contrast", np.array(pil)))
    except Exception:
        pass

    return variants


def process_results(results):
    """
    Xử lý kết quả từ YOLO v2
    """
    boxes = results[0].boxes
    if len(boxes) == 0:
        return {"reading": "N/A", "brand": None, "brand_conf": None, "digit_count": 0}

    digits = []
    number_regions = []
    detected_brands = []

    for box in boxes:
        cls_id = int(box.cls[0])
        label = results[0].names[cls_id]
        conf = float(box.conf[0])
        coords = box.xyxy[0].tolist()

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

    # --- HÃNG ĐỒNG HỒ ---
    best_brand = None
    if detected_brands:
        detected_brands.sort(key=lambda x: x["conf"], reverse=True)
        best_brand = detected_brands[0]

    # --- VÙNG SỐ ---
    best_number_region = None
    if number_regions:
        number_regions.sort(key=lambda x: x["area"], reverse=True)
        best_number_region = number_regions[0]

    # Lọc digit trong vùng number (nếu có)
    if best_number_region:
        filtered = []
        for d in digits:
            if (best_number_region["x_min"] <= d["center_x"] <= best_number_region["x_max"] and
                best_number_region["y_min"] <= d["center_y"] <= best_number_region["y_max"]):
                filtered.append(d)
        digits = filtered

    # Loại bỏ digit trùng lặp (overlap > 50%) - giữ conf cao hơn
    if len(digits) > 1:
        digits.sort(key=lambda x: x["x_min"])
        deduped = [digits[0]]
        for d in digits[1:]:
            prev = deduped[-1]
            overlap = max(0, min(prev["x_max"], d["x_max"]) - max(prev["x_min"], d["x_min"]))
            min_w = min(prev["width"], d["width"])
            overlap_ratio = overlap / min_w if min_w > 0 else 0

            if overlap_ratio > 0.5:
                if d["conf"] > prev["conf"]:
                    deduped[-1] = d
            else:
                deduped.append(d)
        digits = deduped

    # Lọc kích thước (chỉ khi >= 4 digit)
    if len(digits) >= 4:
        heights = [d["height"] for d in digits]
        median_h = sorted(heights)[len(heights) // 2]
        digits = [d for d in digits if d["height"] >= median_h * 0.45]

    # Sắp xếp trái → phải
    digits.sort(key=lambda x: x["x_min"])
    reading = "".join(d["label"] for d in digits)

    return {
        "reading": reading if reading else "N/A",
        "brand": best_brand["label"] if best_brand else None,
        "brand_conf": round(best_brand["conf"], 2) if best_brand else None,
        "digit_count": len(digits),
        "digits": digits,
    }


@app.post("/api/doc-so-moi")
async def doc_so_moi(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        image = Image.open(io.BytesIO(contents)).convert("RGB")
        img_np = np.array(image)

        print(f"\n{'='*60}")
        print(f"📸 Received image: {file.filename} ({img_np.shape})")

        # Tạo nhiều phiên bản ảnh
        variants = create_image_variants(img_np)

        # Chạy predict trên TẤT CẢ các phiên bản, chọn kết quả tốt nhất
        best_result = None
        best_parsed = None
        best_variant_name = None
        best_score = -1

        for name, variant_img in variants:
            results = model.predict(variant_img, conf=0.10, iou=0.4)
            parsed = process_results(results)

            # Score = số digit tìm được + tổng confidence
            digit_count = parsed["digit_count"]
            avg_conf = (sum(d["conf"] for d in parsed.get("digits", [])) / digit_count) if digit_count > 0 else 0
            score = digit_count * 10 + avg_conf  # Ưu tiên nhiều digit hơn

            n_detections = len(results[0].boxes)
            print(f"   [{name}] detections={n_detections}, digits={digit_count}, "
                  f"reading='{parsed['reading']}', score={score:.2f}")

            if score > best_score:
                best_score = score
                best_result = results
                best_parsed = parsed
                best_variant_name = name

        print(f"🏆 Best variant: {best_variant_name} -> reading='{best_parsed['reading']}'")

        # Lưu debug image
        res_plotted = best_result[0].plot()
        cv2.imwrite("debug_ai.jpg", cv2.cvtColor(res_plotted, cv2.COLOR_RGB2BGR))
        print("💾 Saved debug_ai.jpg")

        # Log chi tiết
        if best_parsed.get("brand"):
            print(f"🏷️  Brand: {best_parsed['brand']} (conf={best_parsed['brand_conf']})")
        print(f"🔢 Digits: {best_parsed['digit_count']}")
        for d in best_parsed.get("digits", []):
            print(f"   [{d['label']}] x={d['x_min']:.0f}-{d['x_max']:.0f} "
                  f"conf={d['conf']:.2f} h={d['height']:.0f}")
        print(f"📊 Final: {best_parsed['reading']}")

        response = {
            "success": True,
            "result": best_parsed["reading"],
            "brand": best_parsed.get("brand"),
            "brand_conf": best_parsed.get("brand_conf"),
            "message": "Đã xử lý ảnh thành công"
        }

        print(f"✅ Response: reading={best_parsed['reading']}, brand={best_parsed.get('brand')}")
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
    print(f"🔄 Multi-variant processing: original + contrast_sharp + CLAHE + high_contrast")
    uvicorn.run(app, host="0.0.0.0", port=8001)
