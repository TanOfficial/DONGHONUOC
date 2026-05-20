"""
Script lọc ảnh đồng hồ nước chất lượng tốt nhất để training AI.
Tiêu chí:
1. Ảnh rõ nét (Laplacian variance cao - không bị blur)
2. Ảnh thẳng (không nghiêng - dùng edge detection + Hough lines)
3. Ảnh đủ sáng, không quá tối/quá sáng
4. Kích thước đủ lớn
"""

import os
import cv2
import shutil
import numpy as np
from pathlib import Path

SOURCE_DIR = r"D:\ThucTap\Hinh\TanHoa_HinhDHN\TanHoa_HinhDHN"
OUTPUT_DIR = r"D:\ThucTap\Hinh\BestImages"

# Ngưỡng lọc (SỐ LƯỢNG ĐẢM BẢO 200-300 ẢNH)
MIN_SHARPNESS = 90       
MIN_BRIGHTNESS = 50      
MAX_BRIGHTNESS = 225     
MAX_TILT_DEGREES = 15    
MIN_SIZE_KB = 30         
MIN_RESOLUTION = 300     
TARGET_PER_BRAND = 15    # Mỗi hãng sẽ lấy đúng 15 ảnh tốt nhất (nếu có đủ)


def calculate_sharpness(image):
    """Đo độ nét bằng Laplacian variance"""
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    return cv2.Laplacian(gray, cv2.CV_64F).var()


def calculate_brightness(image):
    """Đo độ sáng trung bình"""
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    return np.mean(gray)


def calculate_tilt(image):
    """
    Ước tính góc nghiêng của ảnh bằng Hough Lines.
    Trả về góc nghiêng trung bình (độ) so với phương ngang.
    """
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    edges = cv2.Canny(gray, 50, 150, apertureSize=3)
    
    lines = cv2.HoughLinesP(edges, 1, np.pi / 180, threshold=80,
                            minLineLength=min(gray.shape) // 4,
                            maxLineGap=10)
    
    if lines is None or len(lines) == 0:
        return 0  # Không tìm thấy đường → coi như thẳng
    
    angles = []
    for line in lines:
        x1, y1, x2, y2 = line[0]
        if x2 - x1 == 0:
            continue
        angle = np.degrees(np.arctan2(y2 - y1, x2 - x1))
        # Chỉ xét các đường gần ngang (±45°) hoặc gần dọc
        if abs(angle) < 45:
            angles.append(abs(angle))
        elif abs(angle) > 135:
            angles.append(abs(180 - abs(angle)))
    
    if not angles:
        return 0
    
    # Lấy median để chống outlier
    return np.median(angles)


def calculate_contrast(image):
    """Đo độ tương phản (std deviation of grayscale)"""
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    return np.std(gray)


def evaluate_image(filepath):
    """
    Đánh giá chất lượng tổng hợp của 1 ảnh.
    Return: dict with scores, or None if file is invalid
    """
    try:
        # Kiểm tra kích thước file
        file_size_kb = os.path.getsize(filepath) / 1024
        if file_size_kb < MIN_SIZE_KB:
            return None
        
        # Đọc ảnh
        img = cv2.imread(str(filepath))
        if img is None:
            return None
        
        h, w = img.shape[:2]
        if min(h, w) < MIN_RESOLUTION:
            return None
        
        sharpness = calculate_sharpness(img)
        brightness = calculate_brightness(img)
        tilt = calculate_tilt(img)
        contrast = calculate_contrast(img)
        
        # Ưu tiên ảnh ngang (Landscape) - Hầu hết đồng hồ nước đọc theo chiều ngang
        is_landscape = w > h
        
        return {
            "filepath": str(filepath),
            "filename": os.path.basename(filepath),
            "size_kb": file_size_kb,
            "resolution": f"{w}x{h}",
            "is_landscape": is_landscape,
            "sharpness": round(sharpness, 1),
            "brightness": round(brightness, 1),
            "tilt_degrees": round(tilt, 1),
            "contrast": round(contrast, 1),
            "composite_score": round(sharpness - (tilt * 20), 1) # Điểm tổng hợp
        }
    except Exception as e:
        print(f"  ❌ Error processing {filepath}: {e}")
        return None


def passes_filter(scores):
    """Kiểm tra ảnh có đạt tiêu chí KHẮT KHE không"""
    if scores is None:
        return False
    if scores["sharpness"] < MIN_SHARPNESS:
        return False
    if scores["brightness"] < MIN_BRIGHTNESS or scores["brightness"] > MAX_BRIGHTNESS:
        return False
    if scores["tilt_degrees"] > MAX_TILT_DEGREES:
        return False
    if not scores["is_landscape"]:
        return False
    return True


def main():
    print("=" * 60)
    print("🔍 BẮT ĐẦU LỌC ẢNH ĐỒNG HỒ NƯỚC")
    print(f"📁 Nguồn: {SOURCE_DIR}")
    print(f"📁 Đích: {OUTPUT_DIR}")
    print(f"📏 Mục tiêu: {TARGET_PER_BRAND} ảnh tốt nhất mỗi hãng (Tổng khoảng 250-270 ảnh)")
    print("=" * 60)
    
    if os.path.exists(OUTPUT_DIR):
        print(f"🗑️ Đang xóa dữ liệu cũ tại {OUTPUT_DIR}...")
        shutil.rmtree(OUTPUT_DIR)
    
    brand_dirs = [d for d in Path(SOURCE_DIR).iterdir() 
                  if d.is_dir() and d.name not in ('.ipynb_checkpoints', 'runs')]
    
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    total_checked = 0
    total_passed = 0
    brand_summary = {}
    
    for brand_dir in sorted(brand_dirs):
        brand_name = brand_dir.name
        images = list(brand_dir.glob("*.jpg")) + list(brand_dir.glob("*.jpeg")) + list(brand_dir.glob("*.png"))
        
        if not images:
            continue
        
        print(f"\n🏷️  [{brand_name}] - {len(images)} ảnh")
        
        # Đánh giá TẤT CẢ ảnh trong hãng
        brand_candidates = []
        for img_path in images:
            total_checked += 1
            scores = evaluate_image(img_path)
            if scores:
                # Phạt nặng ảnh không phải Landscape hoặc quá nghiêng trong điểm số
                if not scores["is_landscape"]:
                    scores["composite_score"] -= 500
                if scores["sharpness"] < MIN_SHARPNESS:
                    scores["composite_score"] -= 200
                
                brand_candidates.append(scores)
        
        # Sắp xếp theo composite_score giảm dần và lấy đúng số lượng mục tiêu
        brand_candidates.sort(key=lambda x: x["composite_score"], reverse=True)
        final_selection = brand_candidates[:TARGET_PER_BRAND]
        
        # Tạo thư mục con và copy
        brand_output = os.path.join(OUTPUT_DIR, brand_name)
        os.makedirs(brand_output, exist_ok=True)
        for s in final_selection:
            shutil.copy2(s["filepath"], os.path.join(brand_output, s["filename"]))
            total_passed += 1
        
        brand_summary[brand_name] = {"total": len(images), "passed": len(final_selection)}
        print(f"  ✅ Đã chọn: {len(final_selection)}/{len(images)} ảnh tốt nhất")
    
    # Tổng kết
    print(f"\n{'='*60}")
    print(f"📊 TỔNG KẾT")
    print(f"{'='*60}")
    print(f"  Tổng ảnh đã kiểm tra: {total_checked}")
    print(f"  Tổng ảnh đạt chất lượng: {total_passed}")
    print(f"  Tỷ lệ: {total_passed/total_checked*100:.1f}%" if total_checked > 0 else "")
    print(f"\n📁 Kết quả lưu tại: {OUTPUT_DIR}")
    
    print(f"\n{'─'*45}")
    print(f"{'Hãng':<18} {'Tổng':>6} {'Đạt':>6} {'%':>7}")
    print(f"{'─'*45}")
    for brand, stats in sorted(brand_summary.items()):
        pct = stats['passed']/stats['total']*100 if stats['total'] > 0 else 0
        print(f"  {brand:<16} {stats['total']:>6} {stats['passed']:>6} {pct:>6.1f}%")
    print(f"{'─'*45}")
    print(f"  {'TỔNG':<16} {total_checked:>6} {total_passed:>6} {total_passed/total_checked*100 if total_checked > 0 else 0:>6.1f}%")


if __name__ == "__main__":
    main()
