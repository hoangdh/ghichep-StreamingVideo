## Hướng dẫn cài đặt và cấu hình Wowza Streaming Engine (Bản Trail)

### Menu
1. Tải bộ cài đặt
2. Cài đặt
3. Khởi động Wowza Engine
4. Thêm live video từ broadcaster

### 1. Tải bộ cài đặt

Để tải bộ cài đặt Wowza Streaming Engine, chúng ta vào trang chủ tại

```
https://www.wowza.com/
```

Sau đó, bấm vào `Trail` để tải bản cài đặt dùng thử 180 ngày.

<img src="http://image.prntscr.com/image/3edb9ef94bb94a3685695caaa619c9f0.png" />

Chọn `Wowza Engine Streaming`

<img src="http://image.prntscr.com/image/bb71074791634d809c0582fbfbba831c.png" />

Điền thông tin cá nhân của bạn, key trail sẽ được gửi và email của bạn

<img src="http://image.prntscr.com/image/458ec33c35394efa9c83db962590f702.png" />

Một bảng chọn platform hiện ra, chúng ta chọn Linux 64 bit

<img src="http://image.prntscr.com/image/7cf85d8e951645d8983946da3f3cee4d.png" />

Click chuột phải vào nút `Download` và chọn `Sao chép địa chỉ liên kết` (Đối với trình duyệt tiếng Việt)

<img src="http://image.prntscr.com/image/61148c8d95aa4a36ab32eccc4642f7f4.png" />

Sau đó, dùng `wget` để tải về trên Terminal

<img src="http://image.prntscr.com/image/b6a58c6dbac54429a7ec42cce8b09497.png" />

Chúng ta check mail để lấy key mà Wowza đã gửi

<img src="http://image.prntscr.com/image/7787fb1c59a847a7a072b415bbd34327.png" />

Email gửi về với nội dung chính là `License Key`, Thông tin của chủ key và ngày hết hạn

### 2. Cài đặt

#### 2.1 Chuẩn bị môi trường cài đặt

Wowza cần Java để thực thi các hoạt động, vì vậy chúng ta cần cài đặt Java JDK hoặc JRE Server, khuyến cáo từ trang chủ là dùng bản 8.

##### Tải JAVA mới nhất từ trang chủ:

```
http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
```

##### Cài đặt

Hiện tại, bản Java mới nhất là `jdk-8u111`. Sau khi tải về, chúng ta sẽ chạy cài đặt bằng lệnh `rpm` và cà đặt biến môi trường:

<img src="http://image.prntscr.com/image/d950623d6c61405094f075ba7a64f30e.png" />

```

rpm -ivh jdk-8u111-linux-x64.rpm
java -version
export JAVA_HOME=/usr/java/jdk1.8.0_111/jre
sh -c "echo export JAVA_HOME=/usr/java/jdk1.8.0_111/jre >> /etc/environment"

```

#### 2.2 Cài đặt Wowza Streaming Engine

Sau khi tải xong bản setup của Wowza, chúng ta phân quyền cho nó bằng lệnh `chmod` và chạy cài đặt

```
chmod +x WowzaStreamingEngine-4.5.0-linux-x64-installer.run
./WowzaStreamingEngine-4.5.0-linux-x64-installer.run
```

Sau khi chạy file, setup sẽ hỏi chúng ta có muốn tiếp tục. Bấm `Enter` để đồng ý.

<img src="http://image.prntscr.com/image/4985db65903042ab9415b0c084001498.png" />

Wowza sẽ đưa ra các điều khoản sử dụng, bấm `Enter` để cuộn trang.

<img src="http://image.prntscr.com/image/3e7e979e6a5d48b1ad1e16992992eab7.png" />

Chọn `Y` để Đồng ý với các điều khoản sử dụng

<img src="http://image.prntscr.com/image/5e231e15112c4351a43f480320562304.png"

Điền key trail mà Wowza đã gửi cho bạn vào mail khi đăng kí dùng thử

<img src="http://image.prntscr.com/image/c25fffd030d84ce99da653d18dddb371.png" />

Tạo tài khoản quản trị Wowza Streaming Engine

<img src="http://image.prntscr.com/image/731bebce74774281ad8c77142ace33af.png" />

Chúng ta chọn `Wowza Streaming Engine 4.5.0` và cho nó khởi động cùng với hệ thống

<img src="http://image.prntscr.com/image/236b30f8128b4960af518b332f660548.png" />

Tiếp tục chọn `Y` và quá trình cài đặt sẽ diễn ra trong vài phút. Khi có thông báo như phần bôi đỏ trong hình thì quá trình cài đặt diễn ra thành công.

<img src="http://image.prntscr.com/image/d518181ca2a84dbf9e4301a2db67aea9.png" />

Như vậy, chúng ta đã cài đặt xong Wowza.

### 3. Khởi động Wowza Engine

Từ trình duyệt Web, chúng truy cập vào Wowza qua địa chỉ IP của Server và port `8088` và bấm `Next`

<img src="http://image.prntscr.com/image/e6dbf2cec4d843efbcabf0e21bad7ccc.png" />

**Chú ý**: Nếu không truy cập được, hãy kiểm tra lại `SELinux` và `iptables`.

```
sed -i s/SELINUX=enforcing/SELINUX=permissive/g /etc/selinux/config
iptables -A INPUT -p tcp -m tcp --dport 8088 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 1935 -j ACCEPT
service iptables save
service iptables reload
```

Tiếp theo, Wowza giới thiệu qua về workflow. Bấm `Next` để tiếp tục

<img src="http://image.prntscr.com/image/84a682d544794cd7a280572fce061897.png" />

Đăng nhập bằng tài khoản quản lý mà chúng ta vừa tạo ở trên.

<img src="http://i1363.photobucket.com/albums/r714/HoangLove9z/84a682d544794cd7a280572fce061897_zpsxzvzbzvb.png" />

Tạo user publisher để public các livestream, Bấm `Done` để vào Dashboard

<img src="http://image.prntscr.com/image/3b15fd86e2af44199bbdbfd9a1097702.png" />

Giao diện Dashboard của Wowza, chúng ta có thể xem trạng thái của nó ở đây.

<img src="http://image.prntscr.com/image/7ab84ea8fc454f2f948f9ccab7e75744.png" />




### 4. Thêm live video từ broadcaster
