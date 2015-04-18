1. install MonogoDB
2. run mongod (on default port 27017)
3. npm install
4. grunt watch
5. 在浏览器中输入localhost:5000

6. 上传的文件在 /bin/public/uploads/目录下, grunt中的clean会忽略掉该文件夹
7. 截止日期的限制暂时只在前端进行了限制, 接口处并没有做验证
8. 所有接口的调用都有对调用者的身份进行验证, 比如学生哪怕输入修改作业的url, 也进入不了
