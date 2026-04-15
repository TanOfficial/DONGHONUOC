import os
import io
import cv2
import numpy as np
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
from ultralytics import YOLO
from PIL import Image

app = FastAPI(title="AI Water Meter Reading Server")

# Load model YOLOv11 đã huấn luyện
MODEL_PATH = "best.pt"
if not os.path.exists(MODEL_PATH):
    print(f"ERROR: Model file not found at {MODEL_PATH}")
    # Initialize with a dummy or raise error later
model = YOLO(MODEL_PATH)

def process_results(results):
    """
    Xử lý kết quả từ YOLO:
    - Tìm vùng 'screen' lớn nhất.
    - Lấy các 'digit' và 'dot' nằm bên trong 'screen'.
    - Sắp xếp từ trái sang phải.
    """
    boxes = results[0].boxes
    if len(boxes) == 0:
        return "N/A"

    # Lấy danh sách các đối tượng
    detected_objects = []
    screen_box = None
    max_screen_area = 0

    for box in boxes:
        cls_id = int(box.cls[0])
        label = results[0].names[cls_id]
        conf = float(box.conf[0])
        coords = box.xyxy[0].tolist() # [x1, y1, x2, y2]
        
        obj = {
            "label": label,
            "conf": conf,
            "coords": coords,
            "x_min": coords[0],
            "y_min": coords[1],
            "x_max": coords[2],
            "y_max": coords[3],
            "area": (coords[2] - coords[0]) * (coords[3] - coords[1])
        }

        if label == "screen":
            if obj["area"] > max_screen_area:
                max_screen_area = obj["area"]
                screen_box = obj
        else:
            detected_objects.append(obj)

    # Nếu tìm thấy screen, lọc bớt các đối tượng nằm ngoài screen
    if screen_box:
        filtered_objects = []
        for obj in detected_objects:
            # Kiểm tra xem tâm của obj có nằm trong screen không
            center_x = (obj["x_min"] + obj["x_max"]) / 2
            center_y = (obj["y_min"] + obj["y_max"]) / 2
            
            if (screen_box["x_min"] <= center_x <= screen_box["x_max"] and 
                screen_box["y_min"] <= center_y <= screen_box["y_max"]):
                filtered_objects.append(obj)
        detected_objects = filtered_objects

    # Lọc nâng cao: Chỉ giữ các chữ số có độ tin cậy > 0.4
    all_digits = [obj for obj in detected_objects if obj["label"] in "0123456789" and obj["conf"] > 0.4]
    
    # Lọc theo kích thước: Chỉ giữ các số có chiều cao xấp xỉ nhau (để loại bỏ số seri nhỏ)
    if len(all_digits) > 0:
        heights = [(obj["y_max"] - obj["y_min"]) for obj in all_digits]
        median_height = sorted(heights)[len(heights) // 2]
        
        # Chỉ giữ những số có chiều cao ít nhất 70% chiều cao trung vị
        final_digits = []
        for obj in all_digits:
            obj_height = obj["y_max"] - obj["y_min"]
            if obj_height >= (median_height * 0.7):
                final_digits.append(obj)
            else:
                print(f"✂️ Removed small digit '{obj['label']}' (height={obj_height:.1f}, median={median_height:.1f})")
        
        # Cập nhật danh sách đối tượng để chuẩn bị sắp xếp và xử lý dot
        # (Vẫn giữ lại dot để xử lý cắt chuỗi)
        dots = [obj for obj in detected_objects if obj["label"] == "dot"]
        detected_objects = final_digits + dots
    else:
        detected_objects = [obj for obj in detected_objects if obj["label"] == "dot"]

    # Sắp xếp các đối tượng từ trái sang phải
    detected_objects.sort(key=lambda x: x["x_min"])

    # Xây dựng chuỗi kết quả
    result_str = ""
    found_dot = False
    for obj in detected_objects:
        # CHỈ CHẤP NHẬN DẤU CHẤM NẾU ĐỘ TIN CẬY CAO (>0.4) VÀ NẰM SAU ÍT NHẤT 3 CHỮ SỐ
        if obj["label"] == "dot":
            if obj["conf"] > 0.4 and len(result_str) >= 3:
                print(f"📍 Found VALID DOT at x={obj['x_min']} with conf={obj['conf']:.2f}")
                found_dot = True
                break
            else:
                print(f"⚠️ Ignored weak/early DOT at x={obj['x_min']} with conf={obj['conf']:.2f}")
                continue
        
        if obj["label"] in "0123456789":
            result_str += obj["label"]

    print(f"🔢 Final Result: {result_str} (Has Dot: {found_dot})")
    return result_str if result_str else "N/A"

@app.post("/api/doc-so-moi")
async def doc_so_moi(file: UploadFile = File(...)):
    try:
        # Đọc ảnh từ request
        contents = await file.read()
        image = Image.open(io.BytesIO(contents)).convert("RGB")
        img_np = np.array(image)

        # Dự đoán bài toán Object Detection
        # Sử dụng conf thấp (0.15) để bắt được mọi thứ, sau đó lọc lại trong process_results
        results = model.predict(img_np, conf=0.15)

        # LƯU ẢNH DEBUG ĐỂ KIỂM TRA
        res_plotted = results[0].plot()
        cv2.imwrite("debug_ai.jpg", cv2.cvtColor(res_plotted, cv2.COLOR_RGB2BGR))
        print("📸 Saved debug image to debug_ai.jpg")

        # Xử lý lấy chỉ số
        result_value = process_results(results)

        return {
            "success": True,
            "result": result_value,
            "message": "Đã nhận được ảnh và đang xử lý..."
        }
    except Exception as e:
        print(f"❌ Server Error: {e}")
        return JSONResponse(
            status_code=500,
            content={"success": False, "message": str(e)}
        )

if __name__ == "__main__":
    import uvicorn
    # Chạy trên port 8001
    uvicorn.run(app, host="0.0.0.0", port=8001)
