# Báo cáo Đánh đổi Kiến trúc Index (Index Trade-off Report)

- **Vấn đề ban đầu:** Việc lạm dụng "Fat Index" (Covering Index chứa toàn bộ cột dữ liệu thay đổi liên tục như `temperature`, `humidity`, `status`) giúp truy vấn Dashboard đọc dữ liệu tức thì mà không cần chạm bảng gốc. Tuy nhiên, cái giá phải trả là **Write Penalty** nghiêm trọng: mỗi khi cảm biến gửi dữ liệu đến (`INSERT`), hệ thống mất rất nhiều thời gian để tái cấu trúc cây B-Tree cồng kềnh, gây nghẽn ống dẫn dữ liệu (Data Loss) và làm dung lượng ổ cứng phình to phi mã.
- **Giải pháp tối ưu:** Chuyển đổi sang **Lean Index** với cấu trúc tinh gọn chỉ gồm hai cột định danh và thời gian (`sensor_id`, `recorded_at`).
- **Kết quả đánh đổi:** 
  - Chấp nhận hy sinh một phần nhỏ tốc độ truy xuất (MySQL phải thực hiện thao tác Table Lookup bổ sung để lấy các cột nhiệt độ, độ ẩm).
  - Đổi lại, tốc độ Ghi (`INSERT`) được khôi phục mạnh mẽ, loại bỏ hoàn toàn tình trạng nghẽn cổ chai, đồng thời giải phóng dung lượng đĩa cứng và bộ nhớ RAM, cứu hệ thống khỏi chi phí vận hành tăng cao trên Cloud.
