
```properties
location /manage/ {  
    alias   D:/data/dsjoa/;
    autoindex on;
    error_page 405 =200 http://$host$request_uri;
    # 当请求参数有attname时，将响应的文件名命名为 attname的值
    if ($arg_attname ~ "^(.+)") {
    add_header Content-Type application/x-download;
    add_header Content-Disposition "attachment;filename=$arg_attname";
    charset                 utf-8,gbk,ISO8859-1; 
    }
}


请求路径：http://localhost:8888/manage/temp.jpg?attname=test.jpg
```
