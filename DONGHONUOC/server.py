from fastapi import FastAPI, UploadFile, File
import uvicorn
import cv2
import numpy as np
from ultralytics import YOLO
import easyocr
import re

app = FastAPI()
model = YOLO('best.pt') 
# Khởi tạo reader (English) - Lần đầu chạy sẽ tải file trọng số khoảng 100MB
reader = easyocr.Reader(['en'], gpu=False) 

@app.post("/api/doc-so")
async def doc_so(file: UploadFile = File(...)):
    contents = await file.read()
    nparr = np.frombuffer(contents, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    
    if img is None:
        return {"success": False, "message": "Không thể giải mã hình ảnh"}

    results = model(img)
    boxes = results[0].boxes
    detected_digits = []
    final_number = ""

    # Duyệt qua các kết quả từ YOLO
    ocr_fragments = []
    for box in boxes:
        cls = int(box.cls[0])
        name = model.names[cls]
        xyxy = box.xyxy[0].tolist() # [x1, y1, x2, y2]
        
        if name == "numbers":
            x1, y1, x2, y2 = map(int, xyxy)
            crop = img[y1:y2, x1:x2]
            
            if crop.size > 0:
                # [NÂNG CẤP 1] Tiền xử lý: Phóng to vùng số để OCR chính xác hơn
                h, w = crop.shape[:2]
                target_h = 100
                target_w = int(w * target_h / h)
                crop_resized = cv2.resize(crop, (target_w, target_h), interpolation=cv2.INTER_CUBIC)
                
                # [NÂNG CẤP 2] OCR với allowlist (chỉ cho phép đọc số)
                # detail=1 để lấy tọa độ, dùng cho việc sắp xếp
                ocr_results = reader.readtext(crop_resized, allowlist='0123456789', detail=1)
                
                for (bbox, text, prob) in ocr_results:
                    if prob > 0.2: # Chỉ lấy kết quả có độ tin cậy > 20%
                        # Lấy x trung tâm của đoạn text để sắp xếp
                        x_center = (bbox[0][0] + bbox[1][0]) / 2
                        ocr_fragments.append({"text": text, "x": x_center})
        
        elif name.isdigit():
            detected_digits.append({"val": name, "x": float(xyxy[0])})

    # [NÂNG CẤP 3] Sắp xếp lại các cụm số từ trái sang phải
    if ocr_fragments:
        ocr_fragments.sort(key=lambda x: x['x'])
        final_number = "".join([f['text'] for f in ocr_fragments])
    
    # Nếu dùng cách nhận diện từng chữ số (xếp từ trái sang phải)
    if not final_number and detected_digits:
        detected_digits.sort(key=lambda x: x['x'])
        final_number = "".join([d['val'] for d in detected_digits])
    
    return {
        "success": True, 
        "result": final_number if final_number else "Không đọc được",
        "method": "OCR" if final_number and not detected_digits else "YOLO-Digits"
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)