-- ========================================================
-- HỆ THỐNG SMARTFACTORY - TỐI ƯU HÓA INDEX (REINDEX STRATEGY)
-- ========================================================

CREATE DATABASE IF NOT EXISTS smartfactory_db;
USE smartfactory_db;

-- 1. Khởi tạo bảng SensorLogs (Mô phỏng bảng lưu trữ dữ liệu cảm biến)
DROP TABLE IF EXISTS SensorLogs;
CREATE TABLE SensorLogs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sensor_id INT NOT NULL,
    recorded_at DATETIME NOT NULL,
    temperature DECIMAL(5,2),
    humidity DECIMAL(5,2),
    status VARCHAR(20) -- 'NORMAL', 'WARNING', 'CRITICAL'
);

-- Tình trạng ban đầu: Lập trình viên cũ gây thảm họa với "Fat Index" (Covering Index quá khổ)
CREATE INDEX idx_fat_covering ON SensorLogs(sensor_id, recorded_at, temperature, humidity, status);

-- ========================================================
-- 2. KIỂM TRA DUNG LƯỢNG VÀ KẾ HOẠCH THỰC THI TRƯỚC KHI TỐI ƯU
-- ========================================================
SHOW TABLE STATUS LIKE 'SensorLogs';

-- Kiểm tra EXPLAIN trước khi tối ưu (Cột Extra sẽ xuất hiện "Using index" - Covering Index)
EXPLAIN 
SELECT temperature, humidity, status 
FROM SensorLogs 
WHERE sensor_id = 105 AND recorded_at >= '2026-06-20';


-- ========================================================
-- 3. TRIỂN KHAI GIẢI PHÁP: GỠ BỎ "FAT INDEX" VÀ THẾ BẰNG "LEAN INDEX"
-- ========================================================

-- Xóa bỏ Index cũ cồng kềnh gây nghẽn luồng Ghi (Write Penalty)
ALTER TABLE SensorLogs DROP INDEX idx_fat_covering;

-- Tạo Lean Index tinh gọn mới: Chỉ chứa các cột thực sự cần thiết cho việc lọc (WHERE) và sắp xếp
CREATE INDEX idx_lean_search ON SensorLogs(sensor_id, recorded_at);


-- ========================================================
-- 4. KIỂM TRA LẠI DUNG LƯỢNG VÀ HIỆN TRẠNG THỰC THI SAU KHI TỐI ƯU
-- ========================================================
SHOW TABLE STATUS LIKE 'SensorLogs';

-- Kiểm tra EXPLAIN sau khi tối ưu 
-- (Cột key chuyển sang idx_lean_search, cột Extra mất chữ "Using index" do cần lookup bảng gốc, 
-- nhưng type vẫn giữ nguyên mức tối ưu 'range')
EXPLAIN 
SELECT temperature, humidity, status 
FROM SensorLogs 
WHERE sensor_id = 105 AND recorded_at >= '2026-06-20';
